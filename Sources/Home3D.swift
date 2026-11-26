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
    @State private var start = Date.now.timeIntervalSinceReferenceDate

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
                animate?(root, now - start)
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

// MARK: - 动画小工具

private func ease(_ x: Double) -> Float { let c = Float(min(1, max(0, x))); return c * c * (3 - 2 * c) }
private func fade(_ e: Entity?, _ a: Float) { e?.components.set(OpacityComponent(opacity: max(0, min(1, a)))) }

// MARK: - 金字塔 3D：素白阶梯自下而上逐层升起，人物落到各层边沿；塔尖缓缓旋转

private let pyramidRows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 16]

struct Pyramid3DView: View {
    var body: some View {
        HomeStage3D(title: "金字塔", subtitle: "按总分分层：越高越少，塔尖是得分最高者", eye: [0, 1.0, 2.7], target: [0, 0.12, 0]) { root in
            var i = 0
            let H: Float = 0.042
            for (layer, n) in pyramidRows.enumerated() where i < rankedThinkers.count {
                let L = Entity(); L.name = "L\(layer)"
                let side: Float = 0.10 + Float(layer) * 0.068
                let y: Float = 0.42 - Float(layer) * H
                L.addChild(model(.generateBox(size: [side, H, side], cornerRadius: 0.004),
                                 mat(layer == 0 ? champagne3D : ivory, rough: layer == 0 ? 0.3 : 0.75, metal: layer == 0 ? 0.8 : 0), at: [0, y - H / 2, 0]))
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + n)])
                i += n
                let crowd = Entity(); crowd.name = "P\(layer)"
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
                    let block = model(.generateBox(size: .init(repeating: tier == .pure ? 0.03 : 0.022), cornerRadius: 0.004),
                                      tierMat(t), at: [layer == 0 ? 0 : px, y + 0.016, layer == 0 ? 0 : pz], name: layer == 0 ? "apex" : "")
                    tappable(block, id: t.id)
                    let label = text3D(shortName(t), size: tier == .pure ? 0.024 : 0.016)
                    label.position = [0, tier == .pure ? 0.04 : 0.028, 0]
                    block.addChild(label)
                    crowd.addChild(block)
                }
                L.addChild(crowd)
                root.addChild(L)
            }
            root.addChild(model(.generateCylinder(height: 0.004, radius: 1.1), mat(UIColor(red: 0.95, green: 0.92, blue: 0.86, alpha: 1), rough: 0.95),
                                at: [0, 0.42 - Float(pyramidRows.count) * 0.042 - 0.002, 0]))
        } animate: { root, t in
            let n = pyramidRows.count
            for layer in 0..<n {
                // 从底层开始逐层升起，再让这一层的人落下
                let k = ease((t - Double(n - 1 - layer) * 0.09) / 0.7)
                let L = root.findEntity(named: "L\(layer)")
                L?.position.y = -0.35 * (1 - k)
                fade(L, k)
                let pk = ease((t - Double(n - 1 - layer) * 0.09 - 0.45) / 0.5)
                root.findEntity(named: "P\(layer)")?.position.y = 0.06 * (1 - pk)
                fade(root.findEntity(named: "P\(layer)"), pk)
            }
            // 塔尖：缓缓自转、轻轻起伏
            if let apex = root.findEntity(named: "apex") {
                apex.orientation = simd_quatf(angle: Float(t) * 0.5, axis: [0, 1, 0])
                apex.position.y = 0.436 + 0.006 * sin(Float(t) * 1.6)
            }
        }
    }
}

// MARK: - 圆桌 3D：两排交错落座；人物依次入座，影响关系的弧线随后亮起；桌面缓缓转动

struct RoundTable3DView: View {
    var body: some View {
        HomeStage3D(title: "圆桌", subtitle: "按年代围坐，人人平等；金线为继承，红线为批判", eye: [0, 1.75, 2.35], target: [0, 0, 0]) { root in
            let spin = Entity(); spin.name = "spin"
            let order = thinkers.sorted { $0.born < $1.born }
            let R: Float = 0.64
            spin.addChild(model(.generateCylinder(height: 0.02, radius: R - 0.16), mat(.white, opacity: 0.5, rough: 0.05), at: [0, -0.01, 0]))
            spin.addChild(model(.generateCylinder(height: 0.004, radius: R - 0.155), mat(champagne3D, rough: 0.3, metal: 0.8), at: [0, -0.022, 0]))
            var pos: [String: SIMD3<Float>] = [:]
            for (i, t) in order.enumerated() {
                let a = Float(i) / Float(order.count) * 2 * .pi
                // 内外两排交错：相邻两人一前一后，名字一高一低，互不遮挡
                let r = i % 2 == 0 ? R : R - 0.1
                let p = SIMD3<Float>(cos(a) * r, 0.015, sin(a) * r)
                pos[t.id] = p
                let tier = FameTier(fameTotal(t))
                let seat = model(.generateSphere(radius: tier == .pure ? 0.019 : 0.013), tierMat(t), at: p, name: "")
                tappable(seat, id: t.id)
                seat.components.set(OpacityComponent(opacity: 0))
                let label = text3D(shortName(t), size: 0.014)
                label.position = [0, i % 2 == 0 ? 0.034 : 0.05, 0]
                seat.addChild(label)
                let holder = Entity(); holder.name = "seat\(i)"
                holder.addChild(seat)
                spin.addChild(holder)
            }
            let arcs = Entity(); arcs.name = "arcs"
            for inf in influences {
                guard let p = pos[inf.from], let q = pos[inf.to] else { continue }
                let col = inf.critical ? UIColor(red: 0.8, green: 0.32, blue: 0.24, alpha: 1) : pureGold3D
                let m = mat(col, opacity: 0.55, rough: 0.3, metal: 0.6)
                let lift = 0.03 + 0.05 * simd_length(p - q)
                var last = p
                for s in 1...6 {
                    let u = Float(s) / 6
                    var c = p + (q - p) * u
                    c.y += 4 * lift * u * (1 - u)
                    c.x *= 1 - 0.3 * 4 * u * (1 - u)
                    c.z *= 1 - 0.3 * 4 * u * (1 - u)
                    let d = c - last
                    let seg = model(.generateCylinder(height: simd_length(d), radius: 0.0012), m, at: (c + last) / 2)
                    seg.orientation = simd_quatf(from: [0, 1, 0], to: simd_normalize(d))
                    arcs.addChild(seg)
                    last = c
                }
            }
            spin.addChild(arcs)
            root.addChild(spin)
        } animate: { root, t in
            let n = thinkers.count
            for i in 0..<n {
                guard let h = root.findEntity(named: "seat\(i)"), let seat = h.children.first else { continue }
                let k = ease((t - Double(i) * 0.025) / 0.5)
                fade(seat, k)
                h.position.y = 0.08 * (1 - k)
            }
            let arcsIn = ease((t - Double(n) * 0.025) / 1.2)
            fade(root.findEntity(named: "arcs"), arcsIn * (0.75 + 0.25 * sin(Float(t) * 1.2)))
            root.findEntity(named: "spin")?.orientation = simd_quatf(angle: Float(t) * 0.04, axis: [0, 1, 0])
        }
    }
}

// MARK: - 天堂 3D：九重天球由内向外展开，各自以不同速度转动；中心的光呼吸

struct Heaven3DView: View {
    private static let ringSizes = [2, 3, 5, 7, 8, 10, 12, 15, 20]
    var body: some View {
        HomeStage3D(title: "天堂", subtitle: "仿但丁《天堂篇》九重天：分数越高，越靠近中心的光", eye: [0, 1.3, 2.5], target: [0, 0, 0]) { root in
            root.addChild(model(.generateSphere(radius: 0.045), mat(UIColor(red: 1, green: 0.97, blue: 0.88, alpha: 1), glow: 9), name: "sun"))
            root.addChild(model(.generateSphere(radius: 0.075), mat(champagne3D, opacity: 0.15, rough: 0.02, glow: 2), name: "halo"))
            let light = PointLight()
            light.light.intensity = 5000
            light.light.color = UIColor(red: 1, green: 0.9, blue: 0.7, alpha: 1)
            light.light.attenuationRadius = 2
            root.addChild(light)
            var i = 0
            for (r, n) in Self.ringSizes.enumerated() where i < rankedThinkers.count {
                let ring = Entity()
                ring.name = "ring\(r)"
                let rad: Float = 0.17 + Float(r) * 0.065
                let orbit = mat(champagne3D, opacity: 0.35, rough: 0.3, metal: 0.6)
                for j in 0..<72 {
                    let a = Float(j) / 72 * 2 * .pi
                    ring.addChild(model(.generateSphere(radius: 0.0018), orbit, at: [cos(a) * rad, 0, sin(a) * rad]))
                }
                let people = Array(rankedThinkers[i..<min(rankedThinkers.count, i + n)])
                i += n
                for (k, t) in people.enumerated() {
                    let a = Float(k) / Float(people.count) * 2 * .pi
                    let tier = FameTier(fameTotal(t))
                    let soul = model(.generateSphere(radius: tier == .pure ? 0.02 : 0.014), tierMat(t), at: [cos(a) * rad, 0, sin(a) * rad])
                    tappable(soul, id: t.id)
                    let label = text3D(shortName(t), size: 0.016)
                    label.position = [0, 0.032, 0]
                    soul.addChild(label)
                    ring.addChild(soul)
                }
                root.addChild(ring)
            }
        } animate: { root, t in
            for r in 0..<Self.ringSizes.count {
                guard let ring = root.findEntity(named: "ring\(r)") else { continue }
                let dir: Float = r % 2 == 0 ? 1 : -1
                let tilt = simd_quatf(angle: Float(r % 3 - 1) * 0.12, axis: [1, 0, 0])
                ring.orientation = tilt * simd_quatf(angle: Float(r) * 0.4 + dir * Float(t) * 0.12 / (1 + Float(r) * 0.35), axis: [0, 1, 0])
                // 由内向外依次展开
                let k = ease((t - Double(r) * 0.15) / 0.9)
                ring.scale = .init(repeating: 0.2 + 0.8 * k)
                fade(ring, k)
            }
            let b = 1 + 0.06 * sin(Float(t) * 1.3)
            root.findEntity(named: "sun")?.scale = .init(repeating: b)
            root.findEntity(named: "halo")?.scale = .init(repeating: 1 + 0.15 * sin(Float(t) * 0.9))
        }
    }
}

// MARK: - 罗马神殿 3D：柱子从台基上依次立起，光柱随后落下，光里有微尘缓缓上升；中央金块慢慢旋转

struct Temple3DView: View {
    private static let motes = 16
    var body: some View {
        HomeStage3D(title: "罗马神殿", subtitle: "仿万神殿：圆形柱廊按学科分三段，柱高即分数；最高分者立在穹顶圆孔落下的光里",
                    eye: [0, 0.75, 2.7], target: [0, 0.2, 0]) { root in
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
                    // 柱子挂在一个位于地面的支点上：缩放支点的高度，柱子就从地面“长”起来
                    let base = Entity(); base.name = "col\(idx)"
                    base.position = [cos(a) * R, -0.01, sin(a) * R]
                    let col = model(.generateCylinder(height: h, radius: 0.0085), tierMat(t), at: [0, h / 2, 0])
                    tappable(col, id: t.id)
                    col.addChild(model(.generateBox(size: [0.022, 0.006, 0.022], cornerRadius: 0.001), stone, at: [0, h / 2 + 0.003, 0]))
                    if tier != .plain {
                        let label = text3D(shortName(t), size: 0.015)
                        label.position = [0, h / 2 + 0.025, 0]
                        col.addChild(label)
                    }
                    base.addChild(col)
                    root.addChild(base)
                    a += span
                    idx += 1
                }
                a += gap
            }
            let roof = Entity(); roof.name = "roof"
            roof.addChild(model(.generateCylinder(height: 0.006, radius: R + 0.015), mat(ivory, opacity: 0.5, rough: 0.6), at: [0, 0.43, 0]))
            for k in 0..<7 {
                let r = (R + 0.01) * cos(Float(k) / 7 * .pi / 2 * 0.95)
                roof.addChild(model(.generateCylinder(height: 0.012, radius: r), mat(ivory, opacity: 0.16, rough: 0.4), at: [0, 0.44 + Float(k) * 0.03, 0]))
            }
            roof.addChild(model(.generateCylinder(height: 0.014, radius: 0.075), mat(.white, glow: 6), at: [0, 0.655, 0]))
            root.addChild(roof)
            root.addChild(model(.generateCylinder(height: 0.66, radius: 0.06), mat(UIColor(red: 1, green: 0.96, blue: 0.85, alpha: 1), opacity: 0.16, glow: 2.5),
                                at: [0, 0.32, 0], name: "beam"))
            for m in 0..<Self.motes {
                root.addChild(model(.generateSphere(radius: 0.0025), mat(champagne3D, glow: 4), name: "mote\(m)"))
            }
            if let top = rankedThinkers.first {
                let cube = model(.generateBox(size: .init(repeating: 0.05), cornerRadius: 0.006), tierMat(top), at: [0, 0.0, 0], name: "")
                tappable(cube, id: top.id)
                let label = text3D(top.name, size: 0.03)
                label.position = [0, 0.07, 0]
                cube.addChild(label)
                let holder = Entity(); holder.name = "idol"
                holder.addChild(cube)
                root.addChild(holder)
            }
        } animate: { root, t in
            let n = thinkers.count
            for i in 0..<n {
                guard let base = root.findEntity(named: "col\(i)") else { continue }
                let k = ease((t - Double(i) * 0.018) / 0.6)
                base.scale = [1, max(0.001, k), 1]
                fade(base, k)
            }
            let after = Double(n) * 0.018 + 0.4
            let roofIn = ease((t - after) / 0.8)
            root.findEntity(named: "roof")?.position.y = 0.25 * (1 - roofIn)
            fade(root.findEntity(named: "roof"), roofIn)
            let beamIn = ease((t - after - 0.6) / 0.8)
            fade(root.findEntity(named: "beam"), beamIn * (0.8 + 0.2 * sin(Float(t) * 1.1)))
            for m in 0..<Self.motes {
                let fm = Double(m)
                let u = Float((t * 0.08 + fm / Double(Self.motes)).truncatingRemainder(dividingBy: 1))
                let ang = Float(fm * 2.4 + t * 0.3)
                let e = root.findEntity(named: "mote\(m)")
                e?.position = [cos(ang) * 0.035, 0.02 + u * 0.6, sin(ang) * 0.035]
                fade(e, beamIn * sin(u * .pi))
            }
            if let idol = root.findEntity(named: "idol") {
                idol.orientation = simd_quatf(angle: Float(t) * 0.4, axis: [0, 1, 0])
                idol.position.y = 0.008 * sin(Float(t) * 1.4)
                fade(idol, beamIn)
            }
        }
    }
}
