import SwiftUI
import RealityKit
import UIKit

// MARK: - 首页的 3D 版：金字塔、圆桌、天堂、罗马神殿
//
// 风格：简约、纯粹——素白的石与玻璃、一点金色、柔和的光，不加多余装饰。
// 拖动环绕，双指缩放，点人物打开评分页。

let gold3D = UIColor(red: 0.84, green: 0.68, blue: 0.36, alpha: 1)
let ivory = UIColor(red: 0.97, green: 0.96, blue: 0.93, alpha: 1)

func mat(_ c: UIColor, opacity: Float = 1, rough: Float = 0.5, metal: Float = 0, glow: Float = 0) -> PhysicallyBasedMaterial {
    var m = PhysicallyBasedMaterial()
    m.baseColor = .init(tint: c)
    m.roughness = .init(floatLiteral: rough)
    m.metallic = .init(floatLiteral: metal)
    if glow > 0 { m.emissiveColor = .init(color: c); m.emissiveIntensity = glow }
    if opacity < 1 { m.blending = .transparent(opacity: .init(floatLiteral: opacity)) }
    return m
}

func model(_ mesh: MeshResource, _ m: any RealityKit.Material, at p: SIMD3<Float> = .zero, name: String = "") -> ModelEntity {
    let e = ModelEntity(mesh: mesh, materials: [m])
    e.position = p
    e.name = name
    return e
}

func text3D(_ s: String, size: CGFloat, color: UIColor = UIColor(white: 0.12, alpha: 1)) -> Entity {
    let holder = Entity()
    let mesh = MeshResource.generateText(s, extrusionDepth: Float(size) * 0.1, font: .systemFont(ofSize: size * 1.35, weight: .medium),
                                         containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
    let t = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: color)])
    t.position = -mesh.bounds.center
    holder.addChild(t)
    holder.components.set(BillboardComponent())
    return holder
}

let champagne3D = UIColor(red: 0.93, green: 0.84, blue: 0.68, alpha: 1)
let pureGold3D = UIColor(red: 0.92, green: 0.72, blue: 0.18, alpha: 1)
let diamond3D = UIColor(red: 0.84, green: 0.95, blue: 1.0, alpha: 1)

func colorFor(_ t: Thinker) -> UIColor {
    switch FameTier(fameTotal(t)) {
    case .pure: return champagne3D
    case .fine: return pureGold3D
    case .plain: return diamond3D
    case .unrated: return ivory
    }
}

/// 分级材质：至纯香槟金（缎面金属）、精致纯金（亮面金属）、专业钻石（清透、带一点光）
func tierMat(_ t: Thinker) -> PhysicallyBasedMaterial {
    switch FameTier(fameTotal(t)) {
    case .pure: return mat(champagne3D, rough: 0.28, metal: 0.85)
    case .fine: return mat(pureGold3D, rough: 0.12, metal: 1)
    case .plain: return mat(diamond3D, opacity: 0.72, rough: 0.02, glow: 0.35)
    case .unrated: return mat(ivory, rough: 0.6)
    }
}


// MARK: - 场景状态：建场时记下引用；交互状态也放在这里，逐帧动画直接读取

final class Stage3DRefs {
    /// 人物 id → 可点的实体（位置用于聚焦与点选判断）
    var people: [String: Entity] = [:]
    /// 额外的点选目标（例如神殿光里的金块，与柱子是同一个人）
    var extra: [(Entity, String)] = []
    var named: [String: Entity] = [:]
    var lists: [String: [Entity]] = [:]
    var homes: [String: [SIMD3<Float>]] = [:]
    /// 交互：当前时刻、镜头位置、选中的人、选中的“组”（塔层 / 天环 / 穹顶剖视）
    var now = 0.0
    var camPos = SIMD3<Float>(0, 1, 2)
    var selected: String?
    var group: Int?
    var groupSince = 0.0
    var values: [String: Float] = [:]
    /// 人物名字：平时只显示排名靠前的人，选中、相关、展开时再显示其余的人，避免挤成一团
    var labels: [String: Entity] = [:]
    var reveal: Set<String> = []
    subscript(_ n: String) -> Entity? {
        get { named[n] }
        set { named[n] = newValue }
    }
}

/// 登记一个人物。点选按屏幕上的投影位置判断（模型和头上的名字都算），不依赖碰撞体
func tappable(_ e: Entity, id: String, _ refs: Stage3DRefs) {
    e.name = "t:" + id
    refs.people[id] = e
}

func ease3(_ x: Double) -> Float { let c = Float(min(1, max(0, x))); return c * c * (3 - 2 * c) }
func fade3(_ e: Entity?, _ a: Float) { e?.components.set(OpacityComponent(opacity: max(0, min(1, a)))) }
func wrapAngle(_ a: Float) -> Float { var x = a; while x > .pi { x -= 2 * .pi }; while x < -.pi { x += 2 * .pi }; return x }

/// 一整圈细环（替代成百上千个小球）
func ringMesh(radius r: Float, width w: Float, segments: Int = 144) -> MeshResource? {
    var pos: [SIMD3<Float>] = [], idx: [UInt32] = []
    for i in 0...segments {
        let a = Float(i) / Float(segments) * 2 * .pi
        pos.append([cos(a) * (r - w), 0, sin(a) * (r - w)])
        pos.append([cos(a) * (r + w), 0, sin(a) * (r + w)])
    }
    for i in 0..<segments {
        let b = UInt32(i * 2)
        idx += [b, b + 1, b + 2, b + 1, b + 3, b + 2]
        idx += [b, b + 2, b + 1, b + 1, b + 2, b + 3]   // 背面也画
    }
    var d = MeshDescriptor(name: "ring")
    d.positions = MeshBuffers.Positions(pos)
    d.primitives = .triangles(idx)
    return try? MeshResource.generate(from: [d])
}

/// 把多条折线一次做成一个管状网格（替代成百上千段小圆柱）。radius 为每条线首尾的半径
func tubesMesh(_ paths: [[SIMD3<Float>]], radius: [(Float, Float)], sides: Int = 7) -> MeshResource? {
    var pos: [SIMD3<Float>] = [], nor: [SIMD3<Float>] = [], idx: [UInt32] = []
    for (pi, path) in paths.enumerated() where path.count >= 2 {
        let (r0, r1) = radius[min(pi, radius.count - 1)]
        let base = UInt32(pos.count)
        for (i, p) in path.enumerated() {
            let dir = simd_normalize(path[min(i + 1, path.count - 1)] - path[max(i - 1, 0)])
            var up = SIMD3<Float>(0, 1, 0)
            if abs(simd_dot(up, dir)) > 0.9 { up = [1, 0, 0] }
            let a = simd_normalize(simd_cross(dir, up)), b = simd_cross(dir, a)
            let r = r0 + (r1 - r0) * Float(i) / Float(path.count - 1)
            for k in 0..<sides {
                let ang = Float(k) / Float(sides) * 2 * .pi
                let n = a * cos(ang) + b * sin(ang)
                pos.append(p + n * r)
                nor.append(n)
            }
        }
        for i in 0..<(path.count - 1) {
            for k in 0..<sides {
                let a0 = base + UInt32(i * sides + k), a1 = base + UInt32(i * sides + (k + 1) % sides)
                let b0 = a0 + UInt32(sides), b1 = a1 + UInt32(sides)
                idx += [a0, b0, a1, a1, b0, b1]
            }
        }
    }
    guard !idx.isEmpty else { return nil }
    var d = MeshDescriptor(name: "tubes")
    d.positions = MeshBuffers.Positions(pos)
    d.normals = MeshBuffers.Normals(nor)
    d.primitives = .triangles(idx)
    return try? MeshResource.generate(from: [d])
}

/// 管状网格用的双面材质（不依赖三角形绕向）
func tubeMat(_ c: UIColor, opacity: Float = 1, rough: Float = 0.5, metal: Float = 0) -> PhysicallyBasedMaterial {
    var m = mat(c, opacity: opacity, rough: rough, metal: metal)
    m.faceCulling = .none
    return m
}

// MARK: - 镜头：围绕一个目标点的球面坐标

struct CamState: Equatable {
    var target: SIMD3<Float>
    var yaw: Float
    var pitch: Float
    var dist: Float
    init(eye: SIMD3<Float>, target: SIMD3<Float>) {
        let d = eye - target
        self.target = target
        dist = simd_length(d)
        yaw = atan2(d.x, d.z)
        pitch = asin(d.y / max(0.001, dist))
    }
    var position: SIMD3<Float> {
        target + SIMD3<Float>(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * dist
    }
}

/// 逐帧状态（引用类型，更新闭包里可以直接改）
final class StageRuntime {
    var last = 0.0
    var t = 0.0
    var cur: CamState?
    var size: CGSize = .zero
}

/// 场景可以提供的交互钩子
struct StageHooks {
    /// 点到的不是人时，判断是否点中了某个“组”（塔层、天环、穹顶），返回组号
    var groupHit: ((Stage3DRefs, CGPoint, (SIMD3<Float>) -> CGPoint?) -> Int?)? = nil
    /// 组被选中或取消时调整镜头（返回新的目标点与距离，nil 表示不动）
    var groupCamera: ((Stage3DRefs, Int) -> (SIMD3<Float>, Float)?)? = nil
    /// 选中组时拖动交给场景（例如拨动天环）；ended 时可返回要选中的人
    var groupDrag: ((Stage3DRefs, CGFloat, Bool) -> String?)? = nil
    /// 选中某人时的镜头姿态（俯仰、距离），nil 用默认
    var focusPose: ((Stage3DRefs, String) -> (Float, Float)?)? = nil
    /// 信息条左右切换的相邻人物
    var neighbors: ((String) -> (String?, String?))? = nil
    /// 选中的人或组变化时由场景高亮（只在变化时调用）
    var highlight: ((Stage3DRefs) -> Void)? = nil
    /// 组的说明（显示在底部提示里）
    var groupHint: ((Stage3DRefs, Int) -> String)? = nil
}

/// 共用舞台：拖动环绕、双指拉近、点人物聚焦；选中后旋转中心切到这个人，点空白回到选中前的视角，“全景”回到初始构图。
/// 点选按屏幕投影判断：离手指最近的人；几个人挤在一起时先给出候选姓名。
struct HomeStage3D: View {
    let title: String
    let subtitle: String
    var eye: SIMD3<Float> = [0, 0.55, 1.5]
    var target: SIMD3<Float> = [0, 0.1, 0]
    /// 入场动画时长：在这之前即使选中了人，动画也照常播完
    var entrance: Double = 4
    /// 信息条里列出影响关系（圆桌）
    var relations = false
    var hint = "点人物聚焦 · 拖动环绕 · 双指拉近"
    var hooks = StageHooks()
    let build: (Entity, Stage3DRefs) -> Void
    var animate: ((Stage3DRefs, Double) -> Void)? = nil

    @State private var refs = Stage3DRefs()
    @State private var rt = StageRuntime()
    @State private var goal: CamState?
    @State private var saved: CamState?
    @State private var groupSaved: CamState?
    @State private var dragBase: CamState?
    @State private var pinchBase: Float?
    @State private var selected: String?
    @State private var group: Int?
    @State private var candidates: [String] = []
    @State private var candidateAt: CGPoint = .zero
    @State private var detail: Thinker?
    @State private var prototype: Thinker?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var initial: CamState { CamState(eye: eye, target: target) }

    var body: some View {
        TimelineView(.animation(paused: detail != nil)) { tl in
            let now = tl.date.timeIntervalSinceReferenceDate
            RealityView { content in
                let root = Entity()
                root.name = "root"
                build(root, refs)
                updateLabels()
                let halo = ModelEntity(mesh: .generateSphere(radius: 0.035), materials: [UnlitMaterial(color: UIColor(white: 1, alpha: 0.35))])
                halo.components.set(OpacityComponent(opacity: 0))
                root.addChild(halo)
                refs["halo"] = halo
                content.add(root)
                let cam = PerspectiveCamera()
                cam.camera.fieldOfViewInDegrees = 40
                cam.look(at: target, from: eye, relativeTo: nil)
                content.add(cam)
                refs["cam"] = cam
                for (from, k, tint) in [(SIMD3<Float>(0.8, 1.4, 1.0), Float(3200), UIColor.white),
                                        (SIMD3<Float>(-1.1, 0.5, 0.6), Float(1100), UIColor(red: 0.85, green: 0.9, blue: 1, alpha: 1)),
                                        (SIMD3<Float>(0, 0.8, -1.3), Float(1500), UIColor(red: 1, green: 0.9, blue: 0.72, alpha: 1))] {
                    let l = DirectionalLight()
                    l.light.intensity = k
                    l.light.color = tint
                    l.look(at: .zero, from: from, relativeTo: nil)
                    content.add(l)
                }
            } update: { _ in
                step(now)
            }
            .onGeometryChange(for: CGSize.self) { $0.size } action: { rt.size = $0 }
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { v in
                        candidates = []
                        if group != nil, let gd = hooks.groupDrag {
                            _ = gd(refs, v.translation.width, false); return
                        }
                        if dragBase == nil { dragBase = goal ?? initial }
                        guard var g = dragBase else { return }
                        g.yaw -= Float(v.translation.width) * 0.008
                        g.pitch = max(-0.2, min(1.35, g.pitch + Float(v.translation.height) * 0.005))
                        goal = g
                    }
                    .onEnded { v in
                        if group != nil, let gd = hooks.groupDrag {
                            if let id = gd(refs, v.translation.width, true) { select(id, keepDistance: true) }
                            return
                        }
                        dragBase = nil
                    }
            )
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { v in
                        var g = goal ?? initial
                        if pinchBase == nil { pinchBase = g.dist }
                        let lo: Float = selected == nil ? initial.dist * 0.3 : 0.14   // 聚焦时不穿入人物
                        g.dist = max(lo, min(initial.dist * 1.8, (pinchBase ?? g.dist) / Float(v.magnification)))
                        goal = g
                    }
                    .onEnded { _ in pinchBase = nil }
            )
            .simultaneousGesture(SpatialTapGesture().onEnded { v in tap(v.location) })
            .overlay(alignment: .topLeading) { candidatePicker }
            // VoiceOver：上下滑动切换人物，另有“返回全景”“人物详情”“查看原型”操作
            .accessibilityElement()
            .accessibilityLabel(title)
            .accessibilityValue(selected.flatMap { id in thinkers.first { $0.id == id }.map(fullName) } ?? "未选中人物，上下滑动选择")
            .accessibilityAdjustableAction { dir in
                let list = rankedThinkers.map(\.id)
                let i = selected.flatMap { list.firstIndex(of: $0) } ?? -1
                let j = dir == .increment ? min(list.count - 1, i + 1) : max(0, i - 1)
                select(list[j])
            }
            .accessibilityAction(named: "返回全景") { overview() }
            .accessibilityAction(named: "人物详情") { if let id = selected { detail = thinkers.first { $0.id == id } } }
            .accessibilityAction(named: "查看原型") { if let id = selected, statueRecord(id) != nil { prototype = thinkers.first { $0.id == id } } }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTitle(title: title, subtitle: subtitle).padding(.bottom, 8)
        }
        .overlay(alignment: .topTrailing) {
            if selected != nil || group != nil || (goal ?? initial) != initial {
                Button { overview() } label: {
                    Label("全景", systemImage: "arrow.up.left.and.arrow.down.right").font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.glass)
                .padding(.trailing, 16).padding(.top, 70)
                .transition(.opacity)
                .accessibilityIdentifier("stage.overview")
            }
        }
        .overlay(alignment: .bottom) {
            if let id = selected, let t = thinkers.first(where: { $0.id == id }) {
                infoBar(t).transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Label(group.flatMap { g in hooks.groupHint?(refs, g) } ?? hint, systemImage: "hand.tap")
                    .font(.caption2).foregroundStyle(Color.primary.opacity(0.6))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .glassEffect(.regular, in: .capsule)
                    .padding(.bottom, 16)
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.2), value: selected)
        .animation(.spring(duration: 0.3, bounce: 0.2), value: candidates)
        .onAppear {
            // 截图用：-stageSelect <人物 id> 在入场后自动聚焦
            let args = ProcessInfo.processInfo.arguments
            if let i = args.firstIndex(of: "-stageSelect"), i + 1 < args.count {
                let id = args[i + 1]
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) { if refs.people[id] != nil { select(id) } }
            }
        }
        .sheet(item: $detail) { FameSheet(thinker: $0) }
        .sheet(item: $prototype) { t in
            if let r = statueRecord(t.id) { PrototypeSheet(record: r, thinker: t) }
        }
    }

    // MARK: 逐帧

    private func step(_ now: Double) {
        let dt = rt.last == 0 ? 0 : min(0.2, now - rt.last)
        rt.last = now
        refs.now = now
        // 触摸、选中人或组时暂停自转（入场动画照常播完），被看的东西不会从镜头里转走
        if reduceMotion { rt.t = max(rt.t, entrance) }   // 减少动态效果：跳过入场与自转
        else if (selected == nil && group == nil && dragBase == nil && pinchBase == nil) || rt.t < entrance { rt.t += dt }
        animate?(refs, rt.t)
        var g = goal ?? initial
        if let id = selected, let e = refs.people[id] {
            // 目标点略低于人物：人物落在画面偏上，避开底部信息条
            g.target = e.position(relativeTo: nil) - SIMD3<Float>(0, g.dist * 0.16, 0)
        }
        var c = rt.cur ?? g
        let k: Float = reduceMotion ? 1 : 0.12
        c.target += (g.target - c.target) * k
        c.yaw += wrapAngle(g.yaw - c.yaw) * k
        c.pitch += (g.pitch - c.pitch) * k
        c.dist += (g.dist - c.dist) * k
        rt.cur = c
        refs.camPos = c.position
        refs["cam"]?.look(at: c.target, from: c.position, relativeTo: nil)
        if let halo = refs["halo"] {
            if let id = selected, let e = refs.people[id] {
                halo.position = e.position(relativeTo: nil)
                halo.scale = .init(repeating: 1 + 0.12 * sin(Float(now) * 3))
                fade3(halo, 0.9)
            } else { fade3(halo, 0) }
        }
    }

    // MARK: 点选：按屏幕投影找离手指最近的人

    private func project(_ p: SIMD3<Float>) -> CGPoint? {
        guard let c = rt.cur, rt.size.height > 0 else { return nil }
        let pos = c.position
        let f = simd_normalize(c.target - pos)
        let r = simd_normalize(simd_cross(f, [0, 1, 0]))
        let u = simd_cross(r, f)
        let d = p - pos
        let z = simd_dot(d, f)
        guard z > 0.01 else { return nil }
        let s = Float(rt.size.height / 2) / tan(20 * .pi / 180)
        return CGPoint(x: rt.size.width / 2 + CGFloat(simd_dot(d, r) / z * s), y: rt.size.height / 2 - CGFloat(simd_dot(d, u) / z * s))
    }

    private func hits(_ pt: CGPoint) -> [(String, CGFloat)] {
        var best: [String: CGFloat] = [:]
        let targets = refs.people.map { ($0.value, $0.key) } + refs.extra
        for (e, id) in targets {
            if let o = e.components[OpacityComponent.self], o.opacity < 0.05 { continue }
            // 模型中心与头上名字（包围盒顶部）都算
            let b = e.visualBounds(relativeTo: nil)
            let pts = [e.position(relativeTo: nil), SIMD3<Float>(b.center.x, b.max.y, b.center.z)]
            for p in pts {
                guard let q = project(p) else { continue }
                let d = hypot(q.x - pt.x, q.y - pt.y)
                if d < 30 { best[id] = min(best[id] ?? .infinity, d) }
            }
        }
        return best.sorted { $0.value < $1.value }.map { ($0.key, $0.value) }
    }

    private func tap(_ pt: CGPoint) {
        if !candidates.isEmpty { candidates = []; return }
        let h = hits(pt)
        if let first = h.first {
            // 最近的明显更近就直接选；几个人挤在一起时给出候选
            if h.count == 1 || first.1 < h[1].1 * 0.55 || first.0 == selected { choose(first.0) }
            else { candidates = Array(h.prefix(5).map(\.0)); candidateAt = pt }
            return
        }
        if let gh = hooks.groupHit, let g = gh(refs, pt, project) {
            setGroup(g == group ? nil : g); return
        }
        if selected != nil { deselect() } else if group != nil { setGroup(nil) }
    }

    private func choose(_ id: String) {
        candidates = []
        if id == selected { detail = thinkers.first { $0.id == id } } else { select(id) }
    }

    private var candidatePicker: some View {
        Group {
            if !candidates.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("这里有几位，选哪一位？").font(.caption2).foregroundStyle(Color.primary.opacity(0.55))
                    ForEach(candidates, id: \.self) { id in
                        if let t = thinkers.first(where: { $0.id == id }) {
                            Button { choose(id) } label: {
                                HStack(spacing: 8) {
                                    Circle().fill(LinearGradient(colors: FameTier(fameTotal(t)).sheen, startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 9, height: 9)
                                    Text(fullName(t)).font(.system(size: 15, weight: .semibold, design: .serif))
                                    Spacer(minLength: 8)
                                    Text("\(fameTotal(t))").font(.caption.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.5))
                                }
                                .foregroundStyle(Color.primary)
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(12)
                .frame(width: 190)
                .glassEffect(.regular, in: .rect(cornerRadius: 18))
                .offset(x: min(max(8, candidateAt.x - 95), max(8, rt.size.width - 198)), y: min(candidateAt.y + 18, max(0, rt.size.height - 220)))
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
    }

    // MARK: 选中人与组

    private func select(_ id: String, keepDistance: Bool = false) {
        if selected == nil { saved = goal ?? initial }
        if let old = selected { refs.people[old]?.scale = .one }
        selected = id
        refs.selected = id
        refs.people[id]?.scale = .init(repeating: 1.3)
        var g = goal ?? initial
        if let pose = hooks.focusPose?(refs, id) {
            g.pitch = pose.0; g.dist = pose.1
        } else if !keepDistance {
            g.dist = min(g.dist, initial.dist * 0.45)
        }
        goal = g
        hooks.highlight?(refs)
        updateLabels()
    }

    private func deselect() {
        if let old = selected { refs.people[old]?.scale = .one }
        selected = nil
        refs.selected = nil
        goal = saved ?? initial
        saved = nil
        hooks.highlight?(refs)
        updateLabels()
    }

    private func setGroup(_ g: Int?) {
        if let old = selected { refs.people[old]?.scale = .one }
        selected = nil
        refs.selected = nil
        saved = nil
        if group == nil, g != nil { groupSaved = goal ?? initial }
        group = g
        refs.group = g
        refs.groupSince = refs.now
        if let g, let cam = hooks.groupCamera?(refs, g) {
            var c = goal ?? initial
            c.target = cam.0; c.dist = cam.1
            goal = c
        } else if g == nil {
            goal = groupSaved ?? initial
            groupSaved = nil
        }
        hooks.highlight?(refs)
        updateLabels()
    }

    private func overview() {
        if let old = selected { refs.people[old]?.scale = .one }
        selected = nil; refs.selected = nil
        group = nil; refs.group = nil; refs.groupSince = refs.now
        saved = nil; groupSaved = nil
        candidates = []
        goal = initial
        hooks.highlight?(refs)
        updateLabels()
    }

    /// 名字显示规则：排名前 24 位常驻；选中的人与他直接相关的人、场景展开的那一组（塔层、天环）临时显示
    private func updateLabels() {
        let top = Set(rankedThinkers.prefix(24).map(\.id))
        var show = top.union(refs.reveal)
        if let id = selected {
            show.insert(id)
            for i in influences where i.from == id || i.to == id { show.insert(i.from); show.insert(i.to) }
        }
        for (id, l) in refs.labels { fade3(l, show.contains(id) ? 1 : 0) }
    }

    // MARK: 信息条

    private func infoBar(_ t: Thinker) -> some View {
        let s = fameTotal(t)
        let tier = FameTier(s)
        let from = influences.filter { $0.to == t.id }.compactMap { i in thinkers.first { $0.id == i.from }.map { ($0, i.critical) } }
        let to = influences.filter { $0.from == t.id }.compactMap { i in thinkers.first { $0.id == i.to }.map { ($0, i.critical) } }
        let nb = hooks.neighbors?(t.id)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                if let nb {
                    Button { if let p = nb.0 { select(p, keepDistance: true) } } label: { Image(systemName: "chevron.left").frame(width: 22, height: 30) }
                        .buttonStyle(.plain).disabled(nb.0 == nil).opacity(nb.0 == nil ? 0.3 : 1)
                }
                CartoonAvatar(thinker: t, size: 40)
                FameRing(score: s, size: 34)
                VStack(alignment: .leading, spacing: 2) {
                    Text(fullName(t)).font(.system(size: 19, weight: .semibold, design: .serif)).lineLimit(1).minimumScaleFactor(0.7)
                    Text("\(tier.name) · \(t.region.title) · \(t.approx ? "约" : "")\(yearText(t.born))–\(yearText(t.died))")
                        .font(.caption2).foregroundStyle(tier.deep).lineLimit(1).minimumScaleFactor(0.75)
                    if relations {
                        Text(seatDisclaimer(t.id)).font(.system(size: 10)).foregroundStyle(Color.primary.opacity(0.45)).lineLimit(1)
                    }
                }
                Spacer(minLength: 4)
                VStack(spacing: 6) {
                    Button("人物详情") { detail = t }.buttonStyle(.glassProminent)
                    if statueRecord(t.id) != nil {
                        Button("查看原型") { prototype = t }.buttonStyle(.glass).font(.caption)
                    }
                }
                if let nb {
                    Button { if let n = nb.1 { select(n, keepDistance: true) } } label: { Image(systemName: "chevron.right").frame(width: 22, height: 30) }
                        .buttonStyle(.plain).disabled(nb.1 == nil).opacity(nb.1 == nil ? 0.3 : 1)
                }
            }
            if relations && !(from.isEmpty && to.isEmpty) {
                relationRow("承自", from)
                relationRow("影响", to)
            }
        }
        .padding(14)
        .modifier(FameCardStyle(tier: tier, region: t.region, radius: 24))
        .padding(.horizontal, 14).padding(.bottom, 12)
    }

    @ViewBuilder
    private func relationRow(_ label: String, _ people: [(Thinker, Bool)]) -> some View {
        if !people.isEmpty {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.primary.opacity(0.55))
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(people, id: \.0.id) { p, critical in
                            Button { select(p.id, keepDistance: true) } label: {
                                Text(shortName(p) + (critical ? " · 批判" : ""))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(critical ? Color(red: 0.75, green: 0.28, blue: 0.2) : pureGoldDeep)
                                    .padding(.horizontal, 9).padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .glassEffect(.regular.interactive(), in: .capsule)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

/// 逐帧把一个数平滑地推向目标值，存在 refs.values 里
@discardableResult
func approach(_ refs: Stage3DRefs, _ key: String, _ target: Float, _ k: Float = 0.14) -> Float {
    let v = refs.values[key] ?? target
    let n = v + (target - v) * k
    refs.values[key] = abs(n - target) < 0.001 ? target : n
    return refs.values[key]!
}
