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


// MARK: - 实体登记：建场时记下引用，逐帧动画不再按名字搜索

final class Stage3DRefs {
    /// 人物 id → 可点的实体（模型与名字共用一个碰撞体）
    var people: [String: ModelEntity] = [:]
    var named: [String: Entity] = [:]
    subscript(_ n: String) -> Entity? {
        get { named[n] }
        set { named[n] = newValue }
    }
}

/// 让一个人物可以被点中：碰撞体包住模型和挂在它上面的名字，点名字和点模型选中的是同一个人
private func tappable(_ e: ModelEntity, id: String, _ refs: Stage3DRefs) {
    e.name = "t:" + id
    let b = e.visualBounds(relativeTo: e)
    let size = SIMD3<Float>(max(b.extents.x, 0.04), max(b.extents.y, 0.04), max(b.extents.z, 0.04)) * 1.15
    e.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: size).offsetBy(translation: b.center)]))
    e.components.set(InputTargetComponent())
    refs.people[id] = e
}

private func ease(_ x: Double) -> Float { let c = Float(min(1, max(0, x))); return c * c * (3 - 2 * c) }
private func fade(_ e: Entity?, _ a: Float) { e?.components.set(OpacityComponent(opacity: max(0, min(1, a)))) }

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
    var lastEntityTap = 0.0
}

/// 共用舞台：拖动环绕、双指拉近、点人物聚焦；选中后旋转中心切到这个人，点空白回到选中前的视角，“全景”回到初始构图
struct HomeStage3D: View {
    let title: String
    let subtitle: String
    var eye: SIMD3<Float> = [0, 0.55, 1.5]
    var target: SIMD3<Float> = [0, 0.1, 0]
    /// 入场动画时长：在这之前即使选中了人，动画也照常播完
    var entrance: Double = 4
    /// 信息条里列出影响关系（圆桌）
    var relations = false
    let build: (Entity, Stage3DRefs) -> Void
    var animate: ((Stage3DRefs, Double) -> Void)? = nil
    /// 选中变化时由场景决定怎样高亮（只在变化时调用一次）
    var highlight: ((Stage3DRefs, String?) -> Void)? = nil

    @State private var refs = Stage3DRefs()
    @State private var rt = StageRuntime()
    @State private var goal: CamState?
    @State private var saved: CamState?
    @State private var dragBase: CamState?
    @State private var pinchBase: Float?
    @State private var selected: String?
    @State private var detail: Thinker?

    private var initial: CamState { CamState(eye: eye, target: target) }

    var body: some View {
        TimelineView(.animation(paused: detail != nil)) { tl in
            let now = tl.date.timeIntervalSinceReferenceDate
            RealityView { content in
                let root = Entity()
                root.name = "root"
                build(root, refs)
                // 选中的人身后一圈柔光
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
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { v in
                        if dragBase == nil { dragBase = goal ?? initial }
                        guard var g = dragBase else { return }
                        g.yaw -= Float(v.translation.width) * 0.008
                        g.pitch = max(-0.2, min(1.35, g.pitch + Float(v.translation.height) * 0.005))
                        goal = g
                    }
                    .onEnded { _ in dragBase = nil }
            )
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { v in
                        var g = goal ?? initial
                        if pinchBase == nil { pinchBase = g.dist }
                        // 选中时沿镜头与人物之间的方向拉近，可以贴得更近
                        let lo: Float = selected == nil ? initial.dist * 0.4 : 0.12
                        g.dist = max(lo, min(initial.dist * 1.8, (pinchBase ?? g.dist) / Float(v.magnification)))
                        goal = g
                    }
                    .onEnded { _ in pinchBase = nil }
            )
            .simultaneousGesture(
                SpatialTapGesture().targetedToAnyEntity().onEnded { v in
                    rt.lastEntityTap = Date.now.timeIntervalSinceReferenceDate
                    var e: Entity? = v.entity
                    while let cur = e, !cur.name.hasPrefix("t:") { e = cur.parent }
                    guard let id = e.map({ String($0.name.dropFirst(2)) }) else { return }
                    if id == selected { detail = thinkers.first { $0.id == id } } else { select(id) }
                }
            )
            .simultaneousGesture(
                SpatialTapGesture().onEnded { _ in
                    // 点到空白：退出选中，回到选中前的视角（与点人物的手势区分开）
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        if Date.now.timeIntervalSinceReferenceDate - rt.lastEntityTap > 0.3, selected != nil { deselect() }
                    }
                }
            )
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTitle(title: title, subtitle: subtitle).padding(.bottom, 8)
        }
        .overlay(alignment: .topTrailing) {
            if selected != nil || (goal ?? initial) != initial {
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
                Label("点人物聚焦 · 拖动环绕 · 双指拉近", systemImage: "hand.tap")
                    .font(.caption2).foregroundStyle(Color.primary.opacity(0.55))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .glassEffect(.regular, in: .capsule)
                    .padding(.bottom, 16)
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.2), value: selected)
        .sheet(item: $detail) { FameSheet(thinker: $0) }
    }

    // MARK: 逐帧

    private func step(_ now: Double) {
        let dt = rt.last == 0 ? 0 : min(0.05, now - rt.last)
        rt.last = now
        // 触摸或选中时暂停自转（入场动画照常播完），被看的人不会从镜头里转走
        if (selected == nil && dragBase == nil && pinchBase == nil) || rt.t < entrance { rt.t += dt }
        animate?(refs, rt.t)
        var g = goal ?? initial
        if let id = selected, let e = refs.people[id] { g.target = e.position(relativeTo: nil) }
        var c = rt.cur ?? g
        let k: Float = 0.12
        c.target += (g.target - c.target) * k
        var dy = g.yaw - c.yaw
        while dy > .pi { dy -= 2 * .pi }
        while dy < -.pi { dy += 2 * .pi }
        c.yaw += dy * k
        c.pitch += (g.pitch - c.pitch) * k
        c.dist += (g.dist - c.dist) * k
        rt.cur = c
        refs["cam"]?.look(at: c.target, from: c.position, relativeTo: nil)
        if let halo = refs["halo"] {
            if let id = selected, let e = refs.people[id] {
                halo.position = e.position(relativeTo: nil)
                halo.scale = .init(repeating: 1 + 0.12 * sin(Float(now) * 3))
                fade(halo, 0.9)
            } else { fade(halo, 0) }
        }
    }

    // MARK: 选中

    private func select(_ id: String) {
        if selected == nil { saved = goal ?? initial }
        if let old = selected { refs.people[old]?.scale = .one }
        selected = id
        refs.people[id]?.scale = .init(repeating: 1.3)
        var g = goal ?? initial
        g.dist = min(g.dist, initial.dist * 0.45)
        goal = g
        highlight?(refs, id)
    }

    private func deselect() {
        if let old = selected { refs.people[old]?.scale = .one }
        selected = nil
        goal = saved ?? initial
        saved = nil
        highlight?(refs, nil)
    }

    private func overview() {
        if let old = selected { refs.people[old]?.scale = .one }
        selected = nil
        saved = nil
        goal = initial
        highlight?(refs, nil)
    }

    // MARK: 信息条

    private func infoBar(_ t: Thinker) -> some View {
        let s = fameTotal(t)
        let tier = FameTier(s)
        let from = influences.filter { $0.to == t.id }.compactMap { i in thinkers.first { $0.id == i.from }.map { ($0, i.critical) } }
        let to = influences.filter { $0.from == t.id }.compactMap { i in thinkers.first { $0.id == i.to }.map { ($0, i.critical) } }
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                FameRing(score: s, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text(t.name).font(.system(size: 19, weight: .semibold, design: .serif))
                    Text("\(tier.name) · \(t.region.title) · \(t.approx ? "约" : "")\(yearText(t.born))–\(yearText(t.died))")
                        .font(.caption2).foregroundStyle(tier.deep)
                }
                Spacer(minLength: 4)
                Button("查看详情") { detail = t }.buttonStyle(.glassProminent)
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
                            // 点相连的人：镜头沿桌沿转过去
                            Button { select(p.id) } label: {
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

// MARK: - 金字塔 3D：素白阶梯自下而上逐层升起，人物落到各层边沿；塔尖缓缓自转

private let pyramidRows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 16]

struct Pyramid3DView: View {
    var body: some View {
        let n = pyramidRows.count
        HomeStage3D(title: "金字塔", subtitle: "按总分分层：越高越少，塔尖是得分最高者", eye: [0, 1.0, 2.7], target: [0, 0.12, 0],
                    entrance: Double(n) * 0.09 + 1.2) { root, refs in
            var i = 0
            let H: Float = 0.042
            for (layer, cnt) in pyramidRows.enumerated() where i < rankedThinkers.count {
                let L = Entity()
                let side: Float = 0.10 + Float(layer) * 0.068
                let y: Float = 0.42 - Float(layer) * H
                L.addChild(model(.generateBox(size: [side, H, side], cornerRadius: 0.004),
                                 mat(layer == 0 ? champagne3D : ivory, rough: layer == 0 ? 0.3 : 0.75, metal: layer == 0 ? 0.8 : 0), at: [0, y - H / 2, 0]))
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + cnt)])
                i += cnt
                let crowd = Entity()
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
                    // 父实体负责位置与动画，子实体负责点选（塔尖的自转不会被点选改名打断）
                    let holder = Entity()
                    holder.position = [layer == 0 ? 0 : px, y + 0.016, layer == 0 ? 0 : pz]
                    holder.addChild(block)
                    crowd.addChild(holder)
                    if layer == 0 { refs["apex"] = holder }
                }
                L.addChild(crowd)
                root.addChild(L)
                refs["L\(layer)"] = L
                refs["P\(layer)"] = crowd
            }
            root.addChild(model(.generateCylinder(height: 0.004, radius: 1.1), mat(UIColor(red: 0.95, green: 0.92, blue: 0.86, alpha: 1), rough: 0.95),
                                at: [0, 0.42 - Float(n) * 0.042 - 0.002, 0]))
        } animate: { refs, t in
            if t < Double(n) * 0.09 + 1.2 {
                for layer in 0..<n {
                    let k = ease((t - Double(n - 1 - layer) * 0.09) / 0.7)
                    refs["L\(layer)"]?.position.y = -0.35 * (1 - k)
                    fade(refs["L\(layer)"], k)
                    let pk = ease((t - Double(n - 1 - layer) * 0.09 - 0.45) / 0.5)
                    refs["P\(layer)"]?.position.y = 0.06 * (1 - pk)
                    fade(refs["P\(layer)"], pk)
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
        HomeStage3D(title: "圆桌", subtitle: "按年代围坐，人人平等；点一个人，只看与他相连的关系", eye: [0, 1.75, 2.35], target: [0, 0, 0],
                    entrance: Double(n) * 0.025 + 1.8, relations: true) { root, refs in
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
                let seat = model(.generateSphere(radius: tier == .pure ? 0.019 : 0.013), tierMat(t))
                let label = text3D(shortName(t), size: 0.014)
                label.position = [0, i % 2 == 0 ? 0.034 : 0.05, 0]
                seat.addChild(label)
                tappable(seat, id: t.id, refs)
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
            fade(refs["arcs"], ease((t - Double(n) * 0.025) / 1.2) * (0.8 + 0.2 * sin(Float(t) * 1.2)))
            refs["spin"]?.orientation = simd_quatf(angle: Float(t) * 0.04, axis: [0, 1, 0])
        } highlight: { refs, id in
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
    }
}

// MARK: - 天堂 3D：九重天球由内向外展开，各自以不同速度转动；中心的光呼吸

struct Heaven3DView: View {
    private static let ringSizes = [2, 3, 5, 7, 8, 10, 12, 15, 20]
    var body: some View {
        HomeStage3D(title: "天堂", subtitle: "仿但丁《天堂篇》九重天：分数越高，越靠近中心的光", eye: [0, 1.3, 2.5], target: [0, 0, 0],
                    entrance: 2.6) { root, refs in
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
                let rad: Float = 0.17 + Float(r) * 0.065
                let orbit = mat(champagne3D, opacity: 0.35, rough: 0.3, metal: 0.6)
                for j in 0..<72 {
                    let a = Float(j) / 72 * 2 * .pi
                    ring.addChild(model(.generateSphere(radius: 0.0018), orbit, at: [cos(a) * rad, 0, sin(a) * rad]))
                }
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + cnt)])
                i += cnt
                for (k, t) in people.enumerated() {
                    let a = Float(k) / Float(people.count) * 2 * .pi
                    let tier = FameTier(fameTotal(t))
                    let soul = model(.generateSphere(radius: tier == .pure ? 0.02 : 0.014), tierMat(t), at: [cos(a) * rad, 0, sin(a) * rad])
                    let label = text3D(shortName(t), size: 0.016)
                    label.position = [0, 0.032, 0]
                    soul.addChild(label)
                    tappable(soul, id: t.id, refs)
                    ring.addChild(soul)
                }
                root.addChild(ring)
                refs["ring\(r)"] = ring
            }
        } animate: { refs, t in
            for r in 0..<Self.ringSizes.count {
                guard let ring = refs["ring\(r)"] else { continue }
                let dir: Float = r % 2 == 0 ? 1 : -1
                let tilt = simd_quatf(angle: Float(r % 3 - 1) * 0.12, axis: [1, 0, 0])
                ring.orientation = tilt * simd_quatf(angle: Float(r) * 0.4 + dir * Float(t) * 0.12 / (1 + Float(r) * 0.35), axis: [0, 1, 0])
                if t < 2.6 {
                    let k = ease((t - Double(r) * 0.15) / 0.9)
                    ring.scale = .init(repeating: 0.2 + 0.8 * k)
                    fade(ring, k)
                }
            }
            refs["sun"]?.scale = .init(repeating: 1 + 0.06 * sin(Float(t) * 1.3))
            refs["sunHalo"]?.scale = .init(repeating: 1 + 0.15 * sin(Float(t) * 0.9))
        }
    }
}

// MARK: - 罗马神殿 3D：柱子从台基上依次立起，光柱随后落下，光里有微尘缓缓上升；中央金块慢慢旋转

struct Temple3DView: View {
    private static let motes = 16
    var body: some View {
        let n = thinkers.count
        let after = Double(n) * 0.018 + 0.4
        HomeStage3D(title: "罗马神殿", subtitle: "仿万神殿：圆形柱廊按学科分三段，柱高即分数；最高分者立在穹顶圆孔落下的光里",
                    eye: [0, 0.75, 2.7], target: [0, 0.2, 0], entrance: after + 1.6) { root, refs in
            let stone = mat(ivory, rough: 0.8)
            for s in 0..<3 {
                root.addChild(model(.generateCylinder(height: 0.02, radius: 0.62 - Float(s) * 0.03), stone, at: [0, -0.05 + Float(s) * 0.02, 0]))
            }
            let groups = Region.allCases.map { r in rankedThinkers.filter { $0.region == r } }
            let gap: Float = 0.22
            let span = (2 * Float.pi - gap * 3) / Float(groups.map(\.count).reduce(0, +))
            var a: Float = -.pi / 2 + gap / 2
            let R: Float = 0.5
            var idx = 0
            for people in groups {
                for t in people {
                    let s = Float(fameTotal(t))
                    let tier = FameTier(Int(s))
                    let h: Float = 0.12 + max(0, s - 30) * 0.0042
                    let base = Entity()
                    base.position = [cos(a) * R, -0.01, sin(a) * R]
                    let col = model(.generateCylinder(height: h, radius: 0.0085), tierMat(t), at: [0, h / 2, 0])
                    col.addChild(model(.generateBox(size: [0.022, 0.006, 0.022], cornerRadius: 0.001), stone, at: [0, h / 2 + 0.003, 0]))
                    if tier != .plain {
                        let label = text3D(shortName(t), size: 0.015)
                        label.position = [0, h / 2 + 0.025, 0]
                        col.addChild(label)
                    }
                    tappable(col, id: t.id, refs)
                    base.addChild(col)
                    root.addChild(base)
                    refs["col\(idx)"] = base
                    a += span
                    idx += 1
                }
                a += gap
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
                // 光里的孔子与他柱廊里的那根柱子是同一个人：点光里的金块也能选中
                cube.name = "t:" + top.id
                let b = cube.visualBounds(relativeTo: cube)
                cube.components.set(CollisionComponent(shapes: [ShapeResource.generateBox(size: b.extents * 1.15).offsetBy(translation: b.center)]))
                cube.components.set(InputTargetComponent())
            }
        } animate: { refs, t in
            if t < after + 0.2 {
                for i in 0..<n {
                    guard let base = refs["col\(i)"] else { continue }
                    let k = ease((t - Double(i) * 0.018) / 0.6)
                    base.scale = [1, max(0.001, k), 1]
                    fade(base, k)
                }
            }
            let roofIn = ease((t - after) / 0.8)
            let beamIn = ease((t - after - 0.6) / 0.8)
            if t < after + 1.6 {
                refs["roof"]?.position.y = 0.25 * (1 - roofIn)
                fade(refs["roof"], roofIn)
            }
            fade(refs["beam"], beamIn * (0.8 + 0.2 * sin(Float(t) * 1.1)))
            for m in 0..<Self.motes {
                let fm = Double(m)
                let u = Float((t * 0.08 + fm / Double(Self.motes)).truncatingRemainder(dividingBy: 1))
                let ang = Float(fm * 2.4 + t * 0.3)
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
