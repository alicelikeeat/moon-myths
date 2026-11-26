import SwiftUI
import RealityKit
import UIKit

// MARK: - 首页的 3D 版：金字塔、圆桌、天堂、罗马神殿
//
// 风格：简约、纯粹——素白的石与玻璃、一点金色、柔和的光，不加多余装饰。
// 拖动环绕，双指缩放，点人物打开评分页。

private let gold3D = UIColor(red: 0.84, green: 0.68, blue: 0.36, alpha: 1)
private let ivory = UIColor(red: 0.97, green: 0.96, blue: 0.93, alpha: 1)

private func mat(_ c: UIColor, opacity: Float = 1, rough: Float = 0.5, metal: Float = 0, glow: Float = 0) -> PhysicallyBasedMaterial {
    var m = PhysicallyBasedMaterial()
    m.baseColor = .init(tint: c)
    m.roughness = .init(floatLiteral: rough)
    m.metallic = .init(floatLiteral: metal)
    if glow > 0 { m.emissiveColor = .init(color: c); m.emissiveIntensity = glow }
    if opacity < 1 { m.blending = .transparent(opacity: .init(floatLiteral: opacity)) }
    return m
}

private func model(_ mesh: MeshResource, _ m: any RealityKit.Material, at p: SIMD3<Float> = .zero, name: String = "") -> ModelEntity {
    let e = ModelEntity(mesh: mesh, materials: [m])
    e.position = p
    e.name = name
    return e
}

private func text3D(_ s: String, size: CGFloat, color: UIColor = UIColor(white: 0.12, alpha: 1)) -> Entity {
    let holder = Entity()
    let mesh = MeshResource.generateText(s, extrusionDepth: Float(size) * 0.1, font: .systemFont(ofSize: size * 1.35, weight: .medium),
                                         containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
    let t = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: color)])
    t.position = -mesh.bounds.center
    holder.addChild(t)
    holder.components.set(BillboardComponent())
    return holder
}

private let champagne3D = UIColor(red: 0.93, green: 0.84, blue: 0.68, alpha: 1)
private let pureGold3D = UIColor(red: 0.92, green: 0.72, blue: 0.18, alpha: 1)
private let diamond3D = UIColor(red: 0.84, green: 0.95, blue: 1.0, alpha: 1)

private func colorFor(_ t: Thinker) -> UIColor {
    switch FameTier(fameTotal(t)) {
    case .pure: return champagne3D
    case .fine: return pureGold3D
    case .plain: return diamond3D
    }
}

/// 分级材质：至纯香槟金（缎面金属）、精致纯金（亮面金属）、专业钻石（清透、带一点光）
private func tierMat(_ t: Thinker) -> PhysicallyBasedMaterial {
    switch FameTier(fameTotal(t)) {
    case .pure: return mat(champagne3D, rough: 0.28, metal: 0.85)
    case .fine: return mat(pureGold3D, rough: 0.12, metal: 1)
    case .plain: return mat(diamond3D, opacity: 0.72, rough: 0.02, glow: 0.35)
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
    subscript(_ n: String) -> Entity? {
        get { named[n] }
        set { named[n] = newValue }
    }
}

/// 登记一个人物。点选按屏幕上的投影位置判断（模型和头上的名字都算），不依赖碰撞体
private func tappable(_ e: Entity, id: String, _ refs: Stage3DRefs) {
    e.name = "t:" + id
    refs.people[id] = e
}

private func ease(_ x: Double) -> Float { let c = Float(min(1, max(0, x))); return c * c * (3 - 2 * c) }
private func fade(_ e: Entity?, _ a: Float) { e?.components.set(OpacityComponent(opacity: max(0, min(1, a)))) }
private func wrapAngle(_ a: Float) -> Float { var x = a; while x > .pi { x -= 2 * .pi }; while x < -.pi { x += 2 * .pi }; return x }

/// 一整圈细环（替代成百上千个小球）
private func ringMesh(radius r: Float, width w: Float, segments: Int = 144) -> MeshResource? {
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
            .accessibilityValue(selected.flatMap { id in thinkers.first { $0.id == id }?.name } ?? "未选中人物，上下滑动选择")
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
                fade(halo, 0.9)
            } else { fade(halo, 0) }
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
                                    Text(t.name).font(.system(size: 15, weight: .semibold, design: .serif))
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
    }

    private func deselect() {
        if let old = selected { refs.people[old]?.scale = .one }
        selected = nil
        refs.selected = nil
        goal = saved ?? initial
        saved = nil
        hooks.highlight?(refs)
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
    }

    private func overview() {
        if let old = selected { refs.people[old]?.scale = .one }
        selected = nil; refs.selected = nil
        group = nil; refs.group = nil; refs.groupSince = refs.now
        saved = nil; groupSaved = nil
        candidates = []
        goal = initial
        hooks.highlight?(refs)
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
                FameRing(score: s, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text(t.name).font(.system(size: 19, weight: .semibold, design: .serif))
                    Text("\(tier.name) · \(t.region.title) · \(t.approx ? "约" : "")\(yearText(t.born))–\(yearText(t.died))")
                        .font(.caption2).foregroundStyle(tier.deep)
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
private func approach(_ refs: Stage3DRefs, _ key: String, _ target: Float, _ k: Float = 0.14) -> Float {
    let v = refs.values[key] ?? target
    let n = v + (target - v) * k
    refs.values[key] = abs(n - target) < 0.001 ? target : n
    return refs.values[key]!
}

// MARK: - 金字塔 3D：点某一层，这一层向外展开成一圈，上面各层淡化；再点人聚焦

private let pyramidRows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 16]

struct Pyramid3DView: View {
    private static let H: Float = 0.042
    private static func layerY(_ l: Int) -> Float { 0.42 - Float(l) * H }
    private static func side(_ l: Int) -> Float { 0.10 + Float(l) * 0.068 }

    var body: some View {
        let n = pyramidRows.count
        let entranceEnd = Double(n) * 0.09 + 1.2
        HomeStage3D(title: "金字塔", subtitle: "按总分分层：越高越少，塔尖是得分最高者", eye: [0, 1.0, 2.7], target: [0, 0.12, 0],
                    entrance: entranceEnd, hint: "点某一层展开 · 点人物聚焦 · 拖动环绕",
                    hooks: StageHooks(
                        groupHit: { refs, pt, project in
                            var best: (Int, CGFloat)?
                            for l in 0..<n {
                                let h = Self.side(l) / 2, y = Self.layerY(l)
                                let pts: [SIMD3<Float>] = [[-h, y, h], [0, y, h], [h, y, h], [h, y, 0], [h, y, -h], [0, y, -h], [-h, y, -h], [-h, y, 0]]
                                for p in pts {
                                    guard let q = project(p) else { continue }
                                    let d = hypot(q.x - pt.x, q.y - pt.y)
                                    if d < 34, d < (best?.1 ?? .infinity) { best = (l, d) }
                                }
                            }
                            return best?.0
                        },
                        groupCamera: { _, l in ([0, Self.layerY(l), 0], 1.9) },
                        groupHint: { refs, l in "第 \(l + 1) 层 · \(refs.lists["P\(l)"]?.count ?? 0) 人 · 点人物聚焦，点空白收起" }
                    )) { root, refs in
            var i = 0
            for (layer, cnt) in pyramidRows.enumerated() where i < rankedThinkers.count {
                let L = Entity()
                let side = Self.side(layer), y = Self.layerY(layer)
                L.addChild(model(.generateBox(size: [side, Self.H, side], cornerRadius: 0.004),
                                 mat(layer == 0 ? champagne3D : ivory, rough: layer == 0 ? 0.3 : 0.75, metal: layer == 0 ? 0.8 : 0), at: [0, y - Self.H / 2, 0]))
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + cnt)])
                i += cnt
                let crowd = Entity()
                var holders: [Entity] = [], homes: [SIMD3<Float>] = []
                for (k, t) in people.enumerated() {
                    let u = (Float(k) + 0.5) / Float(people.count) * 4
                    let edge = Int(u), f = u - Float(edge)
                    let h = side / 2 + 0.012
                    var px: Float = 0, pz: Float = 0
                    switch min(edge, 3) {
                    case 0: px = -h + f * 2 * h; pz = h
                    case 1: px = h; pz = h - f * 2 * h
                    case 2: px = h - f * 2 * h; pz = -h
                    default: px = -h; pz = -h + f * 2 * h
                    }
                    let tier = FameTier(fameTotal(t))
                    let block = model(.generateBox(size: .init(repeating: tier == .pure ? 0.03 : 0.022), cornerRadius: 0.004), tierMat(t))
                    let label = text3D(shortName(t), size: tier == .pure ? 0.024 : 0.016)
                    label.position = [0, tier == .pure ? 0.04 : 0.028, 0]
                    block.addChild(label)
                    tappable(block, id: t.id, refs)
                    // 父实体负责位置与动画，子实体负责点选
                    let holder = Entity()
                    let home = SIMD3<Float>(layer == 0 ? 0 : px, y + 0.016, layer == 0 ? 0 : pz)
                    holder.position = home
                    holder.addChild(block)
                    crowd.addChild(holder)
                    holders.append(holder); homes.append(home)
                    if layer == 0 { refs["apex"] = holder }
                }
                L.addChild(crowd)
                root.addChild(L)
                refs["L\(layer)"] = L
                refs["P\(layer)"] = crowd
                refs.lists["P\(layer)"] = holders
                refs.homes["P\(layer)"] = homes
            }
            root.addChild(model(.generateCylinder(height: 0.004, radius: 1.1), mat(UIColor(red: 0.95, green: 0.92, blue: 0.86, alpha: 1), rough: 0.95),
                                at: [0, Self.layerY(n) - 0.002, 0]))
        } animate: { refs, t in
            if t < entranceEnd {
                for layer in 0..<n {
                    let k = ease((t - Double(n - 1 - layer) * 0.09) / 0.7)
                    refs["L\(layer)"]?.position.y = -0.35 * (1 - k)
                    fade(refs["L\(layer)"], k)
                    let pk = ease((t - Double(n - 1 - layer) * 0.09 - 0.45) / 0.5)
                    refs["P\(layer)"]?.position.y = 0.06 * (1 - pk)
                    fade(refs["P\(layer)"], pk)
                }
            } else {
                // 展开：选中的一层沿外沿排成一圈；它上面的层淡化
                for layer in 0..<n {
                    let e = approach(refs, "exp\(layer)", refs.group == layer ? 1 : 0)
                    let op = approach(refs, "op\(layer)", (refs.group.map { layer < $0 } ?? false) ? 0.12 : 1)
                    if refs.values["opSet\(layer)"] != op { fade(refs["L\(layer)"], op); refs.values["opSet\(layer)"] = op }
                    guard e > 0 || refs.values["expSet\(layer)"] != 0, let hs = refs.lists["P\(layer)"], let homes = refs.homes["P\(layer)"] else { continue }
                    refs.values["expSet\(layer)"] = e
                    let ringR: Float = max(0.32, Self.side(layer) / 2 + 0.18) + Float(hs.count) * 0.01
                    for (k, h) in hs.enumerated() where layer > 0 {
                        let a = Float(k) / Float(hs.count) * 2 * .pi + .pi / 2
                        let ringP = SIMD3<Float>(cos(a) * ringR, Self.layerY(layer) + 0.05, sin(a) * ringR)
                        h.position = homes[k] + (ringP - homes[k]) * e
                    }
                }
            }
            if let apex = refs["apex"] {
                apex.orientation = simd_quatf(angle: Float(t) * 0.5, axis: [0, 1, 0])
                apex.position.y = 0.436 + 0.006 * sin(Float(t) * 1.6)
            }
        }
    }
}

// MARK: - 圆桌 3D：选中一人，与他直接相关的弧线亮起、其余淡出；信息条里点相连的人，镜头沿桌沿转过去

struct RoundTable3DView: View {
    private static let order = thinkers.sorted { $0.born < $1.born }

    var body: some View {
        let n = Self.order.count
        let count = statueCount(Self.order.map(\.id))
        HomeStage3D(title: "圆桌", subtitle: "按年代围坐，人人平等；点一个人，只看与他相连的关系 · 正式雕像 \(count.statues) 尊，卡通示意 \(count.plaques) 席（不代表真实相貌）", eye: [0, 1.75, 2.35], target: [0, 0, 0],
                    entrance: Double(n) * 0.025 + 1.8, relations: true, hint: "点一个人看他的关系 · 拖动环绕 · 双指拉近",
                    hooks: StageHooks(
                        neighbors: { id in
                            guard let i = Self.order.firstIndex(where: { $0.id == id }) else { return (nil, nil) }
                            return (Self.order[(i - 1 + n) % n].id, Self.order[(i + 1) % n].id)
                        },
                        highlight: { refs in
                            let id = refs.selected
                            var linked: Set<String> = []
                            for (k, inf) in influences.enumerated() {
                                let on = id == nil || inf.from == id || inf.to == id
                                if on, id != nil { linked.insert(inf.from); linked.insert(inf.to) }
                                fade(refs["arc\(k)"], on ? 1 : 0.04)
                            }
                            for (i, t) in Self.order.enumerated() {
                                guard let seat = refs["seat\(i)"]?.children.first else { continue }
                                fade(seat, id == nil || linked.contains(t.id) || t.id == id ? 1 : 0.22)
                            }
                        }
                    )) { root, refs in
            let spin = Entity()
            let R: Float = 0.64
            spin.addChild(model(.generateCylinder(height: 0.02, radius: R - 0.16), mat(.white, opacity: 0.5, rough: 0.05), at: [0, -0.01, 0]))
            spin.addChild(model(.generateCylinder(height: 0.004, radius: R - 0.155), mat(champagne3D, rough: 0.3, metal: 0.8), at: [0, -0.022, 0]))
            var pos: [String: SIMD3<Float>] = [:]
            for (i, t) in Self.order.enumerated() {
                let a = Float(i) / Float(n) * 2 * .pi
                let r = i % 2 == 0 ? R : R - 0.1
                let p = SIMD3<Float>(cos(a) * r, 0.015, sin(a) * r)
                pos[t.id] = p
                let tier = FameTier(fameTotal(t))
                // 刻名基座：白石座身，顶沿是评分对应的金属色；有合格雕像时，雕像立在座顶的槽位上
                let pr: Float = tier == .pure ? 0.017 : 0.013
                let h: Float = 0.026
                let seat = model(.generateCylinder(height: h, radius: pr), mat(ivory, rough: 0.7))
                seat.addChild(model(.generateCylinder(height: 0.003, radius: pr + 0.0015), tierMat(t), at: [0, h / 2, 0]))
                let slot = Entity()
                slot.position = [0, h / 2 + 0.0015, 0]
                // 没有合格雕像时先放卡通示意小人；雕像加载成功会替换它
                slot.addChild(cartoonFigure(for: t))
                seat.addChild(slot)
                let label = text3D(shortName(t), size: 0.014)
                label.position = [0, h / 2 + (i % 2 == 0 ? 0.062 : 0.078), 0]
                seat.addChild(label)
                tappable(seat, id: t.id, refs)
                StatueLoader.shared.load(t.id, into: slot)
                seat.components.set(OpacityComponent(opacity: 0))
                let holder = Entity()
                holder.position = p
                holder.addChild(seat)
                spin.addChild(holder)
                refs["seat\(i)"] = holder
            }
            let arcs = Entity()
            for (k, inf) in influences.enumerated() {
                guard let p = pos[inf.from], let q = pos[inf.to] else { continue }
                let col = inf.critical ? UIColor(red: 0.8, green: 0.32, blue: 0.24, alpha: 1) : pureGold3D
                let m = mat(col, opacity: 0.55, rough: 0.3, metal: 0.6)
                let lift = 0.03 + 0.05 * simd_length(p - q)
                let arc = Entity()
                var last = p
                for s in 1...6 {
                    let u = Float(s) / 6
                    var c = p + (q - p) * u
                    c.y += 4 * lift * u * (1 - u)
                    c.x *= 1 - 0.3 * 4 * u * (1 - u)
                    c.z *= 1 - 0.3 * 4 * u * (1 - u)
                    let d = c - last
                    // 越接近被影响者一端越粗，看得出方向
                    let seg = model(.generateCylinder(height: simd_length(d), radius: 0.0009 + 0.0009 * u), m, at: (c + last) / 2)
                    seg.orientation = simd_quatf(from: [0, 1, 0], to: simd_normalize(d))
                    arc.addChild(seg)
                    last = c
                }
                arcs.addChild(arc)
                refs["arc\(k)"] = arc
            }
            spin.addChild(arcs)
            root.addChild(spin)
            refs["spin"] = spin
            refs["arcs"] = arcs
        } animate: { refs, t in
            if t < Double(n) * 0.025 + 0.6 {
                for i in 0..<n {
                    guard let h = refs["seat\(i)"], let seat = h.children.first else { continue }
                    let k = ease((t - Double(i) * 0.025) / 0.5)
                    fade(seat, k)
                    h.position.y = 0.015 + 0.08 * (1 - k)
                }
            }
            fade(refs["arcs"], ease((t - Double(n) * 0.025) / 1.2) * (0.8 + 0.2 * sin(Float(refs.now) * 1.2)))
            refs["spin"]?.orientation = simd_quatf(angle: Float(t) * 0.04, axis: [0, 1, 0])
        }
    }
}

// MARK: - 天堂 3D：点一重天，这一环停转高亮、其余淡化；沿环拖动，人物依次经过正前方，松手后最近的人停在前方

struct Heaven3DView: View {
    private static let ringSizes = [2, 3, 5, 7, 8, 10, 12, 15, 20]
    private static let names = ["原动天", "恒星天", "土星天", "木星天", "火星天", "太阳天", "金星天", "水星天", "月亮天"]
    private static func radius(_ r: Int) -> Float { 0.17 + Float(r) * 0.065 }
    private static func baseAngle(_ r: Int, _ t: Double) -> Float {
        let dir: Float = r % 2 == 0 ? 1 : -1
        return Float(r) * 0.4 + dir * Float(t) * 0.12 / (1 + Float(r) * 0.35)
    }

    var body: some View {
        let rings = Self.ringSizes.count
        HomeStage3D(title: "天堂", subtitle: "仿但丁《天堂篇》九重天：分数越高，越靠近中心的光", eye: [0, 1.3, 2.5], target: [0, 0, 0],
                    entrance: 2.6, hint: "点一重天拨动它 · 点人物聚焦 · 拖动环绕",
                    hooks: StageHooks(
                        groupHit: { refs, pt, project in
                            var best: (Int, CGFloat)?
                            for r in 0..<rings {
                                guard let ring = refs["ring\(r)"] else { continue }
                                let rad = Self.radius(r)
                                for j in 0..<36 {
                                    let a = Float(j) / 36 * 2 * .pi
                                    let p = ring.convert(position: [cos(a) * rad, 0, sin(a) * rad], to: nil)
                                    guard let q = project(p) else { continue }
                                    let d = hypot(q.x - pt.x, q.y - pt.y)
                                    if d < 22, d < (best?.1 ?? .infinity) { best = (r, d) }
                                }
                            }
                            return best?.0
                        },
                        groupCamera: { _, _ in ([0, 0, 0], 2.1) },
                        groupDrag: { refs, dx, ended in
                            guard let r = refs.group else { return nil }
                            if refs.values["dragging"] != 1 { refs.values["dragBase"] = refs.values["offT\(r)"] ?? 0; refs.values["dragging"] = 1 }
                            refs.values["offT\(r)"] = (refs.values["dragBase"] ?? 0) - Float(dx) * 0.006
                            guard ended else { return nil }
                            refs.values["dragging"] = 0
                            // 松手：转到离镜头正前方最近的那个人
                            let pending = (refs.values["offT\(r)"] ?? 0) - (refs.values["off\(r)"] ?? 0)
                            let phiC = atan2(refs.camPos.x, refs.camPos.z)
                            var best: (String, Float)?
                            for (id, e) in refs.people where refs.lists["R\(r)"]?.contains(where: { $0 === e }) == true {
                                let p = e.position(relativeTo: nil)
                                let d = wrapAngle(phiC - (atan2(p.x, p.z) + pending))
                                if abs(d) < abs(best?.1 ?? .infinity) { best = (id, d) }
                            }
                            guard let pick = best else { return nil }
                            refs.values["offT\(r)"] = (refs.values["offT\(r)"] ?? 0) + pick.1
                            return pick.0
                        },
                        highlight: { _ in },
                        groupHint: { _, r in "\(Self.names[r]) · 沿环左右拖动，松手后最近的人停在正前方" }
                    )) { root, refs in
            let sun = model(.generateSphere(radius: 0.045), mat(UIColor(red: 1, green: 0.97, blue: 0.88, alpha: 1), glow: 9))
            let halo = model(.generateSphere(radius: 0.075), mat(champagne3D, opacity: 0.15, rough: 0.02, glow: 2))
            root.addChild(sun); root.addChild(halo)
            refs["sun"] = sun; refs["sunHalo"] = halo
            let light = PointLight()
            light.light.intensity = 5000
            light.light.color = UIColor(red: 1, green: 0.9, blue: 0.7, alpha: 1)
            light.light.attenuationRadius = 2
            root.addChild(light)
            var i = 0
            for (r, cnt) in Self.ringSizes.enumerated() where i < rankedThinkers.count {
                let ring = Entity()
                let rad = Self.radius(r)
                // 轨道：一整圈细环网格（原来是 72 个小球）
                if let mesh = ringMesh(radius: rad, width: 0.0016) {
                    ring.addChild(ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: champagne3D.withAlphaComponent(0.55))]))
                }
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + cnt)])
                i += cnt
                var souls: [Entity] = []
                for (k, t) in people.enumerated() {
                    let a = Float(k) / Float(people.count) * 2 * .pi
                    let tier = FameTier(fameTotal(t))
                    let soul = model(.generateSphere(radius: tier == .pure ? 0.02 : 0.014), tierMat(t), at: [cos(a) * rad, 0, sin(a) * rad])
                    let label = text3D(shortName(t), size: 0.016)
                    label.position = [0, 0.032, 0]
                    soul.addChild(label)
                    tappable(soul, id: t.id, refs)
                    ring.addChild(soul)
                    souls.append(soul)
                }
                root.addChild(ring)
                refs["ring\(r)"] = ring
                refs.lists["R\(r)"] = souls
            }
        } animate: { refs, t in
            for r in 0..<rings {
                guard let ring = refs["ring\(r)"] else { continue }
                let off = approach(refs, "off\(r)", refs.values["offT\(r)"] ?? 0, 0.2)
                let tilt = simd_quatf(angle: Float(r % 3 - 1) * 0.12, axis: [1, 0, 0])
                ring.orientation = tilt * simd_quatf(angle: Self.baseAngle(r, t) + off, axis: [0, 1, 0])
                if t < 2.6 {
                    let k = ease((t - Double(r) * 0.15) / 0.9)
                    ring.scale = .init(repeating: 0.2 + 0.8 * k)
                    fade(ring, k)
                } else {
                    let op = approach(refs, "op\(r)", refs.group == nil || refs.group == r ? 1 : 0.15)
                    if refs.values["opSet\(r)"] != op { fade(ring, op); refs.values["opSet\(r)"] = op }
                    let sc = approach(refs, "sc\(r)", refs.group == r ? 1.04 : 1)
                    ring.scale = .init(repeating: sc)
                }
            }
            refs["sun"]?.scale = .init(repeating: 1 + 0.06 * sin(Float(refs.now) * 1.3))
            refs["sunHalo"]?.scale = .init(repeating: 1 + 0.15 * sin(Float(refs.now) * 0.9))
        }
    }
}

// MARK: - 罗马神殿 3D：点穹顶切到剖视（穹顶与挡在前面的柱子淡出）；点柱子，镜头降到柱身高度，左右切换相邻的柱子

struct Temple3DView: View {
    private static let motes = 16
    private static let order: [Thinker] = Region.allCases.flatMap { r in rankedThinkers.filter { $0.region == r } }

    var body: some View {
        let n = Self.order.count
        let after = Double(n) * 0.018 + 0.4
        HomeStage3D(title: "罗马神殿", subtitle: "仿万神殿：圆形柱廊按学科分三段，柱高即分数；最高分者立在穹顶圆孔落下的光里",
                    eye: [0, 0.75, 2.7], target: [0, 0.2, 0], entrance: after + 1.6, hint: "点穹顶剖开 · 点柱子走近 · 拖动环绕",
                    hooks: StageHooks(
                        groupHit: { refs, pt, project in
                            // 穹顶：顶部圆孔附近，或穹顶边沿
                            if let q = project([0, 0.58, 0]), hypot(q.x - pt.x, q.y - pt.y) < 70 { return 0 }
                            for j in 0..<16 {
                                let a = Float(j) / 16 * 2 * .pi
                                if let q = project([cos(a) * 0.5, 0.46, sin(a) * 0.5]), hypot(q.x - pt.x, q.y - pt.y) < 28 { return 0 }
                            }
                            return nil
                        },
                        groupCamera: { _, _ in ([0, 0.15, 0], 1.7) },
                        focusPose: { _, _ in (0.06, 0.4) },
                        neighbors: { id in
                            guard let i = Self.order.firstIndex(where: { $0.id == id }) else { return (nil, nil) }
                            return (Self.order[(i - 1 + n) % n].id, Self.order[(i + 1) % n].id)
                        },
                        highlight: { refs in
                            // 专业级柱子平时不显示名字：选中时显示
                            for t in Self.order where FameTier(fameTotal(t)) == .plain {
                                fade(refs["label:\(t.id)"], refs.selected == t.id ? 1 : 0)
                            }
                        },
                        groupHint: { _, _ in "剖视 · 点柱子走近，左右切换相邻的柱子；点空白合上穹顶" }
                    )) { root, refs in
            let stone = mat(ivory, rough: 0.8)
            for s in 0..<3 {
                root.addChild(model(.generateCylinder(height: 0.02, radius: 0.62 - Float(s) * 0.03), stone, at: [0, -0.05 + Float(s) * 0.02, 0]))
            }
            let gap: Float = 0.22
            let span = (2 * Float.pi - gap * 3) / Float(n)
            var a: Float = -.pi / 2 + gap / 2
            let R: Float = 0.5
            var region = Self.order.first?.region
            for (idx, t) in Self.order.enumerated() {
                if t.region != region { a += gap; region = t.region }
                let s = Float(fameTotal(t))
                let tier = FameTier(Int(s))
                let h: Float = 0.12 + max(0, s - 30) * 0.0042
                let base = Entity()
                base.position = [cos(a) * R, -0.01, sin(a) * R]
                let col = model(.generateCylinder(height: h, radius: 0.0085), tierMat(t), at: [0, h / 2, 0])
                col.addChild(model(.generateBox(size: [0.022, 0.006, 0.022], cornerRadius: 0.001), stone, at: [0, h / 2 + 0.003, 0]))
                let label = text3D(shortName(t), size: 0.015)
                label.position = [0, h / 2 + 0.025, 0]
                if tier == .plain { label.components.set(OpacityComponent(opacity: 0)) }
                col.addChild(label)
                refs["label:\(t.id)"] = label
                tappable(col, id: t.id, refs)
                base.addChild(col)
                root.addChild(base)
                refs["col\(idx)"] = base
                refs.values["az\(idx)"] = atan2(base.position.x, base.position.z)
                a += span
            }
            let roof = Entity()
            roof.addChild(model(.generateCylinder(height: 0.006, radius: R + 0.015), mat(ivory, opacity: 0.5, rough: 0.6), at: [0, 0.43, 0]))
            for k in 0..<7 {
                let r = (R + 0.01) * cos(Float(k) / 7 * .pi / 2 * 0.95)
                roof.addChild(model(.generateCylinder(height: 0.012, radius: r), mat(ivory, opacity: 0.16, rough: 0.4), at: [0, 0.44 + Float(k) * 0.03, 0]))
            }
            roof.addChild(model(.generateCylinder(height: 0.014, radius: 0.075), mat(.white, glow: 6), at: [0, 0.655, 0]))
            root.addChild(roof)
            refs["roof"] = roof
            let beam = model(.generateCylinder(height: 0.66, radius: 0.06), mat(UIColor(red: 1, green: 0.96, blue: 0.85, alpha: 1), opacity: 0.16, glow: 2.5),
                             at: [0, 0.32, 0])
            root.addChild(beam)
            refs["beam"] = beam
            for m in 0..<Self.motes {
                let mote = model(.generateSphere(radius: 0.0025), mat(champagne3D, glow: 4))
                root.addChild(mote)
                refs["mote\(m)"] = mote
            }
            if let top = rankedThinkers.first {
                let cube = model(.generateBox(size: .init(repeating: 0.05), cornerRadius: 0.006), tierMat(top))
                let label = text3D(top.name, size: 0.03)
                label.position = [0, 0.07, 0]
                cube.addChild(label)
                let holder = Entity()
                holder.addChild(cube)
                root.addChild(holder)
                refs["idol"] = holder
                // 光里的金块与柱廊里的那根柱子是同一个人：点金块也能选中
                refs.extra.append((cube, top.id))
            }
        } animate: { refs, t in
            if t < after + 0.2 {
                for i in 0..<n {
                    guard let base = refs["col\(i)"] else { continue }
                    let k = ease((t - Double(i) * 0.018) / 0.6)
                    base.scale = [1, max(0.001, k), 1]
                    fade(base, k)
                }
            } else {
                // 剖视：挡在镜头前方的那一段柱子淡出
                let cut = refs.group == 0
                let phiC = atan2(refs.camPos.x, refs.camPos.z)
                for i in 0..<n {
                    let front = cut && abs(wrapAngle((refs.values["az\(i)"] ?? 0) - phiC)) < 0.95
                    let op = approach(refs, "colOp\(i)", front ? 0.1 : 1)
                    if refs.values["colSet\(i)"] != op { fade(refs["col\(i)"], op); refs.values["colSet\(i)"] = op }
                }
            }
            let roofIn = ease((t - after) / 0.8)
            let beamIn = ease((t - after - 0.6) / 0.8)
            if t < after + 1.6 {
                refs["roof"]?.position.y = 0.25 * (1 - roofIn)
                fade(refs["roof"], roofIn)
            } else {
                let op = approach(refs, "roofOp", refs.group == 0 ? 0.05 : 1)
                if refs.values["roofSet"] != op { fade(refs["roof"], op); refs.values["roofSet"] = op }
            }
            fade(refs["beam"], beamIn * (0.8 + 0.2 * sin(Float(refs.now) * 1.1)))
            for m in 0..<Self.motes {
                let fm = Double(m)
                let u = Float((refs.now * 0.08 + fm / Double(Self.motes)).truncatingRemainder(dividingBy: 1))
                let ang = Float(fm * 2.4 + refs.now * 0.3)
                let e = refs["mote\(m)"]
                e?.position = [cos(ang) * 0.035, 0.02 + u * 0.6, sin(ang) * 0.035]
                fade(e, beamIn * sin(u * .pi))
            }
            if let idol = refs["idol"] {
                idol.orientation = simd_quatf(angle: Float(t) * 0.4, axis: [0, 1, 0])
                idol.position.y = 0.008 * sin(Float(t) * 1.4)
                fade(idol, beamIn)
            }
        }
    }
}
