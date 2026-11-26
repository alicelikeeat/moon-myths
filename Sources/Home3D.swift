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

/// 让一个人物可以被点中
private func tappable(_ e: ModelEntity, id: String) {
    e.name = "t:" + id
    e.generateCollisionShapes(recursive: false)
    e.components.set(InputTargetComponent())
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

/// 共用舞台：相机、三盏柔光、拖动环绕、双指缩放、点选
struct HomeStage3D: View {
    let title: String
    let subtitle: String
    var eye: SIMD3<Float> = [0, 0.55, 1.5]
    var target: SIMD3<Float> = [0, 0.1, 0]
    var startPitch: Float = 0.0
    let build: (Entity) -> Void
    var animate: ((Entity, Double) -> Void)? = nil

    @State private var yaw: Float = 0.25
    @State private var pitch: Float = 0
    @State private var zoom: Float = 1
    @GestureState private var drag: CGSize = .zero
    @GestureState private var pinch: CGFloat = 1
    @State private var detail: Thinker?

    var body: some View {
        TimelineView(.animation(paused: detail != nil)) { tl in
            let now = tl.date.timeIntervalSinceReferenceDate
            RealityView { content in
                let root = Entity()
                root.name = "root"
                build(root)
                content.add(root)
                let cam = PerspectiveCamera()
                cam.camera.fieldOfViewInDegrees = 40
                cam.look(at: target, from: eye, relativeTo: nil)
                content.add(cam)
                for (from, k, tint) in [(SIMD3<Float>(0.8, 1.4, 1.0), Float(3200), UIColor.white),
                                        (SIMD3<Float>(-1.1, 0.5, 0.6), Float(1100), UIColor(red: 0.85, green: 0.9, blue: 1, alpha: 1)),
                                        (SIMD3<Float>(0, 0.8, -1.3), Float(1500), UIColor(red: 1, green: 0.9, blue: 0.72, alpha: 1))] {
                    let l = DirectionalLight()
                    l.light.intensity = k
                    l.light.color = tint
                    l.look(at: .zero, from: from, relativeTo: nil)
                    content.add(l)
                }
            } update: { content in
                guard let root = content.entities.first(where: { $0.name == "root" }) else { return }
                let y = yaw + Float(drag.width) * 0.008 + 0.04 * sin(Float(now * 0.2))
                let x = max(-0.35, min(0.8, startPitch + pitch + Float(drag.height) * 0.005))
                root.orientation = simd_quatf(angle: x, axis: [1, 0, 0]) * simd_quatf(angle: y, axis: [0, 1, 0])
                root.scale = .init(repeating: max(0.6, min(2.6, zoom * Float(pinch))))
                animate?(root, now)
            }
            .gesture(
                DragGesture(minimumDistance: 4)
                    .updating($drag) { v, s, _ in s = v.translation }
                    .onEnded { v in
                        yaw += Float(v.translation.width) * 0.008
                        pitch = max(-0.35 - startPitch, min(0.8 - startPitch, pitch + Float(v.translation.height) * 0.005))
                    }
            )
            .simultaneousGesture(
                MagnifyGesture()
                    .updating($pinch) { v, s, _ in s = v.magnification }
                    .onEnded { v in zoom = max(0.6, min(2.6, zoom * Float(v.magnification))) }
            )
            .simultaneousGesture(
                SpatialTapGesture().targetedToAnyEntity().onEnded { v in
                    var e: Entity? = v.entity
                    while let cur = e, !cur.name.hasPrefix("t:") { e = cur.parent }
                    if let id = e?.name.dropFirst(2), let t = thinkers.first(where: { $0.id == String(id) }) { detail = t }
                }
            )
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTitle(title: title, subtitle: subtitle).padding(.bottom, 8)
        }
        .overlay(alignment: .bottom) {
            Label("拖动环绕 · 双指缩放 · 点人物看评分", systemImage: "hand.draw")
                .font(.caption2).foregroundStyle(Color.primary.opacity(0.55))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
                .padding(.bottom, 16)
        }
        .sheet(item: $detail) { FameSheet(thinker: $0) }
    }
}

// MARK: - 金字塔 3D：素白阶梯，每层边沿站着这一层的人；塔顶金色

private let pyramidRows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 16]

struct Pyramid3DView: View {
    var body: some View {
        HomeStage3D(title: "金字塔", subtitle: "按总分分层：越高越少，塔尖是得分最高者", eye: [0, 1.0, 2.7], target: [0, 0.12, 0]) { root in
            var i = 0
            let H: Float = 0.042
            for (layer, n) in pyramidRows.enumerated() where i < rankedThinkers.count {
                let side: Float = 0.10 + Float(layer) * 0.068
                let y: Float = 0.42 - Float(layer) * H
                let slab = model(.generateBox(size: [side, H, side], cornerRadius: 0.004),
                                 mat(layer == 0 ? champagne3D : ivory, rough: layer == 0 ? 0.3 : 0.75, metal: layer == 0 ? 0.8 : 0), at: [0, y - H / 2, 0])
                root.addChild(slab)
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + n)])
                i += n
                for (k, t) in people.enumerated() {
                    // 沿正方形边沿均匀排开
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
                    let pos = SIMD3<Float>(layer == 0 ? 0 : px, y + 0.016, layer == 0 ? 0 : pz)
                    let tier = FameTier(fameTotal(t))
                    let block = model(.generateBox(size: .init(repeating: tier == .pure ? 0.03 : 0.022), cornerRadius: 0.004),
                                      tierMat(t), at: pos)
                    tappable(block, id: t.id)
                    let label = text3D(shortName(t), size: tier == .pure ? 0.024 : 0.016)
                    label.position = [0, tier == .pure ? 0.04 : 0.028, 0]
                    block.addChild(label)
                    root.addChild(block)
                }
            }
            // 沙地：一块极淡的大圆盘
            root.addChild(model(.generateCylinder(height: 0.004, radius: 1.1), mat(UIColor(red: 0.95, green: 0.92, blue: 0.86, alpha: 1), rough: 0.95),
                                at: [0, 0.42 - Float(pyramidRows.count) * 0.042 - 0.002, 0]))
        }
    }
}

// MARK: - 圆桌 3D：一张玻璃圆桌，按年代围坐；金线在桌面上方连起影响关系

struct RoundTable3DView: View {
    var body: some View {
        HomeStage3D(title: "圆桌", subtitle: "按年代围坐一圈，人人平等；金线为继承，红线为批判", eye: [0, 1.7, 2.1], target: [0, 0, 0]) { root in
            let order = thinkers.sorted { $0.born < $1.born }
            let R: Float = 0.5
            root.addChild(model(.generateCylinder(height: 0.02, radius: R - 0.06), mat(.white, opacity: 0.55, rough: 0.05), at: [0, -0.01, 0]))
            root.addChild(model(.generateCylinder(height: 0.004, radius: R - 0.055), mat(gold3D, rough: 0.3, metal: 0.8), at: [0, -0.022, 0]))
            var pos: [String: SIMD3<Float>] = [:]
            for (i, t) in order.enumerated() {
                let a = Float(i) / Float(order.count) * 2 * .pi
                let p = SIMD3<Float>(cos(a) * R, 0.02, sin(a) * R)
                pos[t.id] = p
                let tier = FameTier(fameTotal(t))
                let seat = model(.generateSphere(radius: tier == .pure ? 0.022 : 0.016),
                                 tierMat(t), at: p)
                tappable(seat, id: t.id)
                let label = text3D(shortName(t), size: 0.017)
                label.position = [0, 0.04, 0]
                seat.addChild(label)
                root.addChild(seat)
            }
            // 影响关系：桌面上方的弧，由几段细杆连成
            for inf in influences {
                guard let p = pos[inf.from], let q = pos[inf.to] else { continue }
                let col = inf.critical ? UIColor(red: 0.8, green: 0.32, blue: 0.24, alpha: 1) : gold3D
                let m = mat(col, opacity: 0.7, rough: 0.3, metal: 0.5)
                let lift = 0.04 + 0.08 * simd_length(p - q)
                var last = p
                for s in 1...6 {
                    let u = Float(s) / 6
                    var c = p + (q - p) * u
                    c.y += 4 * lift * u * (1 - u)
                    c.x *= 1 - 0.35 * 4 * u * (1 - u)
                    c.z *= 1 - 0.35 * 4 * u * (1 - u)
                    let d = c - last
                    let seg = model(.generateCylinder(height: simd_length(d), radius: 0.0016), m, at: (c + last) / 2)
                    seg.orientation = simd_quatf(from: [0, 1, 0], to: simd_normalize(d))
                    root.addChild(seg)
                    last = c
                }
            }
        }
    }
}

// MARK: - 天堂 3D：九重天球，中心是光；分数越高越靠近中心，各重天缓缓转动

struct Heaven3DView: View {
    private static let ringSizes = [2, 3, 5, 7, 8, 10, 12, 15, 20]
    var body: some View {
        HomeStage3D(title: "天堂", subtitle: "仿但丁《天堂篇》九重天：分数越高，越靠近中心的光", eye: [0, 1.3, 2.5], target: [0, 0, 0]) { root in
            root.addChild(model(.generateSphere(radius: 0.045), mat(UIColor(red: 1, green: 0.97, blue: 0.88, alpha: 1), glow: 9), name: "sun"))
            root.addChild(model(.generateSphere(radius: 0.075), mat(gold3D, opacity: 0.15, rough: 0.02, glow: 2)))
            let light = PointLight()
            light.light.intensity = 5000
            light.light.color = UIColor(red: 1, green: 0.9, blue: 0.7, alpha: 1)
            light.light.attenuationRadius = 2
            root.addChild(light)
            var i = 0
            for (r, n) in Self.ringSizes.enumerated() where i < rankedThinkers.count {
                let ring = Entity()
                ring.name = "ring\(r)"
                // 每一重天略微倾斜，像套在一起的天球
                ring.orientation = simd_quatf(angle: Float(r % 3 - 1) * 0.12, axis: [1, 0, 0]) * simd_quatf(angle: Float(r) * 0.4, axis: [0, 1, 0])
                let rad: Float = 0.17 + Float(r) * 0.065
                let orbit = mat(gold3D, opacity: 0.35, rough: 0.3, metal: 0.6)
                for j in 0..<72 {
                    let a = Float(j) / 72 * 2 * .pi
                    ring.addChild(model(.generateSphere(radius: 0.0018), orbit, at: [cos(a) * rad, 0, sin(a) * rad]))
                }
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + n)])
                i += n
                for (k, t) in people.enumerated() {
                    let a = Float(k) / Float(people.count) * 2 * .pi
                    let tier = FameTier(fameTotal(t))
                    let soul = model(.generateSphere(radius: tier == .pure ? 0.02 : 0.014),
                                     tierMat(t), at: [cos(a) * rad, 0, sin(a) * rad])
                    tappable(soul, id: t.id)
                    let label = text3D(shortName(t), size: 0.016)
                    label.position = [0, 0.032, 0]
                    soul.addChild(label)
                    ring.addChild(soul)
                }
                root.addChild(ring)
            }
        } animate: { root, now in
            for r in 0..<Self.ringSizes.count {
                guard let ring = root.findEntity(named: "ring\(r)") else { continue }
                let dir: Float = r % 2 == 0 ? 1 : -1
                let tilt = simd_quatf(angle: Float(r % 3 - 1) * 0.12, axis: [1, 0, 0])
                ring.orientation = tilt * simd_quatf(angle: Float(r) * 0.4 + dir * Float(now) * 0.12 / (1 + Float(r) * 0.35), axis: [0, 1, 0])
            }
            root.findEntity(named: "sun")?.scale = .init(repeating: 1 + 0.04 * sin(Float(now) * 1.3))
        }
    }
}

// MARK: - 罗马神殿 3D：圆形柱廊、阶梯状穹顶、圆孔落下的光柱，最高分者立在光里

struct Temple3DView: View {
    var body: some View {
        HomeStage3D(title: "罗马神殿", subtitle: "仿万神殿：圆形柱廊按学科分三段，柱高即分数；最高分者立在穹顶圆孔落下的光里",
                    eye: [0, 0.75, 2.7], target: [0, 0.2, 0]) { root in
            let stone = mat(ivory, rough: 0.8)
            // 台基：三级圆台
            for s in 0..<3 {
                root.addChild(model(.generateCylinder(height: 0.02, radius: 0.62 - Float(s) * 0.03), stone, at: [0, -0.05 + Float(s) * 0.02, 0]))
            }
            // 柱廊：中国、西方、数学各占一段弧，中间留门
            let groups = Region.allCases.map { r in rankedThinkers.filter { $0.region == r } }
            let gap: Float = 0.22
            let span = (2 * Float.pi - gap * 3) / Float(groups.map(\.count).reduce(0, +))
            var a: Float = -.pi / 2 + gap / 2
            let R: Float = 0.5
            for (g, people) in groups.enumerated() {
                let tint: UIColor = [UIColor(red: 0.9, green: 0.88, blue: 0.97, alpha: 1), ivory, UIColor(red: 0.86, green: 0.95, blue: 0.92, alpha: 1)][g]
                for t in people {
                    let s = Float(fameTotal(t))
                    let tier = FameTier(Int(s))
                    let h: Float = 0.12 + max(0, s - 30) * 0.0042
                    let p = SIMD3<Float>(cos(a) * R, -0.01 + h / 2, sin(a) * R)
                    let col = model(.generateCylinder(height: h, radius: 0.0085),
                                    tierMat(t), at: p)
                    tappable(col, id: t.id)
                    // 柱头
                    col.addChild(model(.generateBox(size: [0.022, 0.006, 0.022], cornerRadius: 0.001), stone, at: [0, h / 2 + 0.003, 0]))
                    if tier != .plain {
                        let label = text3D(shortName(t), size: 0.015)
                        label.position = [0, h / 2 + 0.025, 0]
                        col.addChild(label)
                    }
                    root.addChild(col)
                    a += span
                }
                a += gap
            }
            // 额枋：一圈细环
            root.addChild(model(.generateCylinder(height: 0.006, radius: R + 0.015), mat(ivory, opacity: 0.5, rough: 0.6), at: [0, 0.43, 0]))
            // 阶梯状穹顶（像万神殿外部的阶环），顶上留圆孔
            for k in 0..<7 {
                let r = (R + 0.01) * cos(Float(k) / 7 * .pi / 2 * 0.95)
                let ring = model(.generateCylinder(height: 0.012, radius: r), mat(ivory, opacity: 0.16, rough: 0.4), at: [0, 0.44 + Float(k) * 0.03, 0])
                root.addChild(ring)
            }
            root.addChild(model(.generateCylinder(height: 0.014, radius: 0.075), mat(.white, glow: 6), at: [0, 0.655, 0]))
            // 光柱与光里的人
            root.addChild(model(.generateCylinder(height: 0.66, radius: 0.06), mat(UIColor(red: 1, green: 0.96, blue: 0.85, alpha: 1), opacity: 0.16, glow: 2.5), at: [0, 0.32, 0]))
            if let top = rankedThinkers.first {
                let cube = model(.generateBox(size: .init(repeating: 0.05), cornerRadius: 0.006), tierMat(top), at: [0, 0.0, 0])
                tappable(cube, id: top.id)
                let label = text3D(top.name, size: 0.03)
                label.position = [0, 0.07, 0]
                cube.addChild(label)
                root.addChild(cube)
            }
        }
    }
}
