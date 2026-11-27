import SwiftUI
import RealityKit
import UIKit

// MARK: - 至高级 3D：手工搭建的 RealityKit 真三维场景
//
// 共用一个舞台（Stage3D）：透视相机、主光 + 补光 + 轮廓光、星尘背景、拖动环绕、双指缩放、
// 每一拍一句说明。各场景只负责搭建（build）和每帧驱动（animate）。

func pbr(_ c: UIColor, opacity: Float = 1, rough: Float = 0.12, metal: Float = 0, glow: Float = 0) -> PhysicallyBasedMaterial {
    var m = PhysicallyBasedMaterial()
    m.baseColor = .init(tint: c)
    m.roughness = .init(floatLiteral: rough)
    m.metallic = .init(floatLiteral: metal)
    m.clearcoat = .init(floatLiteral: 1)
    m.clearcoatRoughness = .init(floatLiteral: 0.05)
    if glow > 0 {
        m.emissiveColor = .init(color: c)
        m.emissiveIntensity = glow
    }
    if opacity < 1 { m.blending = .transparent(opacity: .init(floatLiteral: opacity)) }
    return m
}

private let goldUI = UIColor(red: 0.85, green: 0.68, blue: 0.36, alpha: 1)

private func ent(_ mesh: MeshResource, _ m: any RealityKit.Material, _ name: String = "", at p: SIMD3<Float> = .zero) -> ModelEntity {
    let e = ModelEntity(mesh: mesh, materials: [m])
    e.name = name
    e.position = p
    return e
}

/// 立体文字：居中、始终朝向镜头
private func label3D(_ s: String, size: CGFloat, color: UIColor, name: String = "") -> Entity {
    let holder = Entity()
    holder.name = name
    let mesh = MeshResource.generateText(s, extrusionDepth: Float(size) * 0.12,
                                         font: .systemFont(ofSize: size, weight: .semibold),
                                         containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
    let text = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: color)])
    let b = mesh.bounds
    text.position = -b.center
    holder.addChild(text)
    holder.components.set(BillboardComponent())
    return holder
}

private func setOpacity(_ e: Entity?, _ a: Double) {
    e?.components.set(OpacityComponent(opacity: Float(max(0, min(1, a)))))
}

private func lerp3(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ k: Double) -> SIMD3<Float> { a + (b - a) * Float(k) }

/// 共用舞台
struct Stage3D: View {
    let clock: PlaybackClock
    let durations: [Double]
    let captions: [String]
    var eye: SIMD3<Float> = [0, 0.26, 1.15]
    var target: SIMD3<Float> = [0, 0.04, 0]
    let build: (Entity) -> Void
    let animate: (Entity, Double, Int, Double) -> Void

    @State private var yaw: Float = 0.32
    @State private var pitch: Float = 0.08
    @State private var zoom: Float = 1
    @GestureState private var drag: CGSize = .zero
    @GestureState private var pinch: CGFloat = 1

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60)) { tl in
            let now = tl.date.timeIntervalSinceReferenceDate
            let t = clock.time(now)
            let (ph, p) = beats(t, durations)
            ZStack(alignment: .top) {
                RealityView { content in
                    let root = Entity()
                    root.name = "root"
                    build(root)
                    // 星尘：远处一圈缓缓发光的微粒，给出空间感
                    let dust = Entity()
                    dust.name = "dust"
                    for i in 0..<90 {
                        let fi = Float(i)
                        let a = fi * 2.399963
                        let y = 1 - 2 * (fi + 0.5) / 90
                        let r = sqrt(max(0, 1 - y * y))
                        let d: Float = 1.6 + 0.5 * abs(sin(fi * 7.1))
                        let rad: Float = 0.003 + 0.003 * abs(sin(fi * 3.3))
                        let pos = SIMD3<Float>(cos(a) * r * d, y * d * 0.6, sin(a) * r * d)
                        let star = ent(MeshResource.generateSphere(radius: rad), UnlitMaterial(color: UIColor(white: 1, alpha: 0.55)), at: pos)
                        dust.addChild(star)
                    }
                    root.addChild(dust)
                    content.add(root)

                    let camera = PerspectiveCamera()
                    camera.camera.fieldOfViewInDegrees = 42
                    camera.look(at: target, from: eye, relativeTo: nil)
                    content.add(camera)

                    let key = DirectionalLight()
                    key.light.intensity = 3600
                    key.look(at: .zero, from: [0.7, 1.1, 0.9], relativeTo: nil)
                    content.add(key)
                    let fill = DirectionalLight()
                    fill.light.intensity = 900
                    fill.light.color = UIColor(red: 0.7, green: 0.8, blue: 1, alpha: 1)
                    fill.look(at: .zero, from: [-1, 0.3, 0.6], relativeTo: nil)
                    content.add(fill)
                    let rim = DirectionalLight()
                    rim.light.intensity = 1600
                    rim.light.color = UIColor(red: 1, green: 0.88, blue: 0.65, alpha: 1)
                    rim.look(at: .zero, from: [0, 0.6, -1.2], relativeTo: nil)
                    content.add(rim)
                } update: { content in
                    guard let root = content.entities.first(where: { $0.name == "root" }) else { return }
                    let y = yaw + Float(drag.width) * 0.008 + 0.05 * sin(Float(now * 0.25))
                    let x = max(-0.5, min(0.9, pitch + Float(drag.height) * 0.006))
                    root.orientation = simd_quatf(angle: x, axis: [1, 0, 0]) * simd_quatf(angle: y, axis: [0, 1, 0])
                    root.scale = .init(repeating: max(0.6, min(2.2, zoom * Float(pinch))))
                    root.findEntity(named: "dust")?.orientation = simd_quatf(angle: Float(now * 0.02), axis: [0, 1, 0])
                    animate(root, t, ph, p)
                }
                .gesture(
                    DragGesture()
                        .updating($drag) { v, s, _ in s = v.translation }
                        .onEnded { v in
                            yaw += Float(v.translation.width) * 0.008
                            pitch = max(-0.5, min(0.9, pitch + Float(v.translation.height) * 0.006))
                        }
                )
                .simultaneousGesture(
                    MagnifyGesture()
                        .updating($pinch) { v, s, _ in s = v.magnification }
                        .onEnded { v in zoom = max(0.6, min(2.2, zoom * Float(v.magnification))) }
                )

                Text(captions[min(ph, captions.count - 1)])
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .glassEffect(.regular, in: .capsule)
                    .padding(.top, 58)
                    .id(ph)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: ph)
            }
            .overlay(alignment: .bottomLeading) {
                Label("拖动环绕 · 双指缩放", systemImage: "hand.draw")
                    .font(.caption2).foregroundStyle(Color.primary.opacity(0.6))
                    .padding(14)
            }
        }
    }
}

// MARK: - 柏拉图：洞穴之喻

struct Cave3D: View {
    let clock: PlaybackClock
    private static let wallZ: Float = -0.43
    private static let fire: SIMD3<Float> = [0, -0.07, 0.85]
    private static let puppetZ: Float = 0.30

    var body: some View {
        Stage3D(clock: clock, durations: [7, 7, 7],
                captions: ["囚徒只看得见墙上的影子", "转过身：火光与被搬运的器物", "走出洞穴：看见太阳"],
                eye: [0, 0.5, 1.85], target: [0, 0.02, 0.15]) { root in
            let stone = pbr(UIColor(red: 0.42, green: 0.38, blue: 0.34, alpha: 1), rough: 0.95)
            root.addChild(ent(.generateBox(size: [1.7, 0.012, 1.6]), stone, at: [0, -0.15, 0.25]))
            root.addChild(ent(.generateBox(size: [1.7, 0.62, 0.03], cornerRadius: 0.01),
                              pbr(UIColor(red: 0.62, green: 0.56, blue: 0.48, alpha: 1), rough: 0.9), at: [0, 0.16, Self.wallZ - 0.016]))
            // 囚徒：一排，被锁链连在一起，面朝墙
            let body = pbr(UIColor(red: 0.55, green: 0.6, blue: 0.72, alpha: 1), rough: 0.5)
            for i in 0..<5 {
                let x = Float(i - 2) * 0.12
                let p = Entity(); p.name = "pri\(i)"; p.position = [x, -0.15, 0.02]
                p.addChild(ent(.generateBox(size: [0.05, 0.075, 0.045], cornerRadius: 0.02), body, at: [0, 0.04, 0]))
                p.addChild(ent(.generateSphere(radius: 0.022), body, at: [0, 0.1, 0]))
                root.addChild(p)
            }
            let chain = ent(.generateCylinder(height: 0.5, radius: 0.0025), pbr(.gray, rough: 0.3, metal: 1), at: [0, -0.12, 0.02])
            chain.orientation = simd_quatf(angle: .pi / 2, axis: [0, 0, 1])
            root.addChild(chain)
            // 矮墙
            root.addChild(ent(.generateBox(size: [1.3, 0.07, 0.025], cornerRadius: 0.005), stone, at: [0, -0.115, 0.24]))
            // 被举着走过的器物，以及它们在墙上的影子
            let shapes: [MeshResource] = [.generateBox(size: [0.05, 0.05, 0.02], cornerRadius: 0.006),
                                          .generateCone(height: 0.07, radius: 0.028),
                                          .generateSphere(radius: 0.026)]
            let cols: [UIColor] = [UIColor(red: 0.85, green: 0.7, blue: 0.45, alpha: 1), UIColor(red: 0.7, green: 0.5, blue: 0.4, alpha: 1),
                                   UIColor(red: 0.8, green: 0.8, blue: 0.6, alpha: 1)]
            for i in 0..<3 {
                let pup = ent(shapes[i], pbr(cols[i], rough: 0.35), "pup\(i)")
                pup.addChild(ent(.generateCylinder(height: 0.09, radius: 0.003), pbr(.brown, rough: 0.8), at: [0, -0.06, 0]))
                root.addChild(pup)
                let sh = ent(shapes[i], UnlitMaterial(color: UIColor(white: 0.05, alpha: 0.75)), "sh\(i)")
                root.addChild(sh)
            }
            // 火：两层发光球 + 点光源
            root.addChild(ent(.generateSphere(radius: 0.045), pbr(.orange, opacity: 0.85, glow: 4), "fire", at: Self.fire))
            root.addChild(ent(.generateSphere(radius: 0.025), pbr(.yellow, glow: 6), "fire2", at: Self.fire))
            let pl = PointLight()
            pl.name = "firelight"
            pl.light.color = UIColor(red: 1, green: 0.6, blue: 0.3, alpha: 1)
            pl.light.intensity = 6000
            pl.light.attenuationRadius = 2.2
            pl.position = Self.fire
            root.addChild(pl)
            // 洞口外的太阳与上升的小路
            root.addChild(ent(.generateSphere(radius: 0.09), pbr(UIColor(red: 1, green: 0.92, blue: 0.7, alpha: 1), opacity: 0.95, glow: 8), "sun", at: [0.62, 0.42, 1.0]))
            for j in 0..<14 {
                let k = Double(j) / 13
                let p = lerp3([0, -0.13, 0.05], [0.58, 0.36, 0.98], k)
                root.addChild(ent(.generateSphere(radius: 0.006), pbr(goldUI, glow: 3), "path\(j)", at: p))
            }
        } animate: { root, t, ph, p in
            let lit = ph == 0 ? 0.18 : 1.0
            // 火焰跳动
            let f1: Double = 0.12 * sin(t * 13), f2: Double = 0.06 * sin(t * 29)
            let flick: Double = 1 + f1 + f2
            root.findEntity(named: "fire")?.scale = .init(repeating: Float(flick))
            root.findEntity(named: "fire2")?.scale = .init(repeating: Float(2 - flick))
            setOpacity(root.findEntity(named: "fire"), ph == 0 ? 0.25 : 1)
            if let pl = root.findEntity(named: "firelight") as? PointLight { pl.light.intensity = Float(5200 * flick) }
            let F = Self.fire
            let s = (Self.wallZ - F.z) / (Self.puppetZ - F.z)
            for i in 0..<3 {
                let u = fract(t * 0.07 + Double(i) * 0.33)
                let px: Double = -0.5 + u, py: Double = -0.005 + 0.008 * sin(t * 3 + Double(i))
                let pos = SIMD3<Float>(Float(px), Float(py), Self.puppetZ)
                let pup = root.findEntity(named: "pup\(i)")
                pup?.position = pos
                setOpacity(pup, lit)
                let sx: Float = F.x + (pos.x - F.x) * s
                let sy: Float = F.y + (pos.y - F.y) * s
                let sh = root.findEntity(named: "sh\(i)")
                sh?.position = [sx, sy, Self.wallZ + 0.002]
                sh?.scale = [s, s, 0.04]
                let edge: Float = abs(sx)
                let fade: Double = edge < 0.8 ? 0.85 * (1 - Double(edge) / 0.8 * 0.3) : 0
                setOpacity(sh, fade)
            }
            // 第二拍：中间那位转身；第三拍：沿小路走向太阳
            let turn = ph == 0 ? 0 : (ph == 1 ? smooth(p / 0.4) : 1)
            let walk = ph == 2 ? smooth(p / 0.8) : 0
            if let pri = root.findEntity(named: "pri2") {
                pri.orientation = simd_quatf(angle: Float(turn) * .pi, axis: [0, 1, 0])
                pri.position = lerp3([0, -0.15, 0.02], [0.56, 0.24, 0.94], walk)
            }
            let sun = root.findEntity(named: "sun")
            setOpacity(sun, ph == 2 ? smooth(p / 0.3) : 0)
            let sunS: Double = 0.6 + 0.4 * (ph == 2 ? smooth(p) : 0)
            sun?.scale = SIMD3<Float>(repeating: Float(sunS))
            for j in 0..<14 {
                let pj: Double = ph == 2 ? smooth(p * 3 - Double(j) / 14 * 1.5) : 0
                setOpacity(root.findEntity(named: "path\(j)"), pj)
            }
        }
    }
}

// MARK: - 黑格尔：真理是全体（精神沿螺旋上升）

struct Spiral3D: View {
    let clock: PlaybackClock
    private static let n = 140
    private static let stages = ["感性确定性", "知觉与知性", "自我意识", "理性与精神", "绝对知识"]

    private static func point(_ u: Double) -> SIMD3<Float> {
        let a = u * 4.5 * 2 * Double.pi
        let r = 0.34 * (1 - u * 0.6)
        let x: Double = cos(a) * r, y: Double = -0.22 + u * 0.5, z: Double = sin(a) * r
        return SIMD3<Float>(Float(x), Float(y), Float(z))
    }

    var body: some View {
        Stage3D(clock: clock, durations: [6, 6, 6],
                captions: ["精神沿着自身的环节上升", "每一环节被扬弃，也被保存", "真理是全体"],
                eye: [0, 0.3, 1.2], target: [0, 0.03, 0]) { root in
            let gold = pbr(goldUI, rough: 0.2, metal: 0.6, glow: 1.5)
            for i in 0..<Self.n {
                root.addChild(ent(.generateSphere(radius: 0.006), gold, "h\(i)", at: Self.point(Double(i) / Double(Self.n - 1))))
            }
            for (k, s) in Self.stages.enumerated() {
                let u = (Double(k) + 0.5) / Double(Self.stages.count)
                let p = Self.point(u)
                root.addChild(ent(.generateSphere(radius: 0.022), pbr(UIColor(red: 0.75, green: 0.82, blue: 1, alpha: 1), opacity: 0.8), "node\(k)", at: p))
                let l = label3D(s, size: 0.028, color: UIColor.label.withAlphaComponent(0.85), name: "lab\(k)")
                l.position = p + [0, 0.045, 0]
                root.addChild(l)
            }
            root.addChild(ent(.generateSphere(radius: 0.03), pbr(UIColor(red: 1, green: 0.86, blue: 0.55, alpha: 1), opacity: 0.95, glow: 5), "spirit"))
            root.addChild(ent(.generateSphere(radius: 0.46), pbr(UIColor(red: 0.8, green: 0.88, blue: 1, alpha: 1), opacity: 0.12, rough: 0.02), "whole", at: [0, 0.02, 0]))
            root.addChild(ent(.generateCylinder(height: 0.55, radius: 0.004), pbr(.white, opacity: 0.35), "axis", at: [0, 0.03, 0]))
        } animate: { root, t, ph, p in
            let total = (Double(ph) + p) / 3
            let u = min(1, total * 1.05)
            root.findEntity(named: "spirit")?.position = Self.point(u)
            for i in 0..<Self.n {
                let ui = Double(i) / Double(Self.n - 1)
                let e = root.findEntity(named: "h\(i)")
                setOpacity(e, ui <= u ? 1 : 0.15)
                e?.scale = .init(repeating: ui <= u ? 1.2 : 0.8)
            }
            for k in 0..<Self.stages.count {
                let uk = (Double(k) + 0.5) / Double(Self.stages.count)
                let reached = smooth((u - uk) / 0.05 + 1)
                setOpacity(root.findEntity(named: "lab\(k)"), 0.25 + 0.75 * reached)
                // 被扬弃的环节：缩小、变透明，却仍留在原处
                let past = ph >= 1 ? smooth((u - uk) / 0.15) : 0
                let ns: Double = 1 + 0.4 * reached - 0.45 * past
                root.findEntity(named: "node\(k)")?.scale = SIMD3<Float>(repeating: Float(ns))
            }
            let whole = root.findEntity(named: "whole")
            setOpacity(whole, ph == 2 ? 0.9 * smooth(p / 0.6) : 0)
            let wS: Double = ph == 2 ? 0.7 + 0.3 * smooth(p / 0.6) : 0.7
            whole?.scale = SIMD3<Float>(repeating: Float(wS))
            root.findEntity(named: "spirit")?.scale = .init(repeating: Float(1 + 0.15 * sin(t * 4)))
        }
    }
}

// MARK: - 老子：道生一，一生二，二生三，三生万物

struct Dao3D: View {
    let clock: PlaybackClock
    private static let many = 150

    var body: some View {
        Stage3D(clock: clock, durations: [5, 5, 5, 7],
                captions: ["道生一", "一生二", "二生三", "三生万物"],
                eye: [0, 0.18, 1.1], target: [0, 0, 0]) { root in
            root.addChild(ent(.generateSphere(radius: 0.06), pbr(UIColor(white: 0.97, alpha: 1), opacity: 0.85, rough: 0.03, glow: 0.6), "one"))
            root.addChild(ent(.generateSphere(radius: 0.045), pbr(UIColor(white: 0.12, alpha: 1), rough: 0.08), "yin"))
            root.addChild(ent(.generateSphere(radius: 0.045), pbr(UIColor(red: 1, green: 0.96, blue: 0.86, alpha: 1), rough: 0.05, glow: 1.2), "yang"))
            root.addChild(ent(.generateSphere(radius: 0.035), pbr(UIColor(red: 0.55, green: 0.75, blue: 1, alpha: 1), opacity: 0.6, rough: 0.02, glow: 1), "chong"))
            for j in 0..<60 {
                let a = Float(j) / 60 * 2 * .pi
                root.addChild(ent(.generateSphere(radius: 0.0035), UnlitMaterial(color: UIColor(white: 1, alpha: 0.6)), "ring\(j)",
                                  at: [cos(a) * 0.13, 0, sin(a) * 0.13]))
            }
            for i in 0..<Self.many {
                let h = Double(i) / Double(Self.many)
                let c = UIColor(hue: CGFloat(fract(0.08 + h * 0.6)), saturation: 0.45, brightness: 0.95, alpha: 1)
                root.addChild(ent(.generateSphere(radius: 0.006 + 0.006 * Float(fract(h * 7.3))), pbr(c, rough: 0.2, glow: 0.8), "w\(i)"))
            }
        } animate: { root, t, ph, p in
            let one = root.findEntity(named: "one")
            let born = ph == 0 ? smooth(p / 0.7) : 1
            let oneS: Double = (0.05 + 0.95 * born) * (1 + 0.04 * sin(t * 2))
            one?.scale = SIMD3<Float>(repeating: Float(oneS))
            setOpacity(one, ph == 0 ? born : (ph == 1 ? 1 - smooth(p / 0.4) : 0))
            // 二：一分为阴阳，彼此环绕
            let split = ph == 0 ? 0 : (ph == 1 ? smooth(p / 0.6) : 1)
            let a = t * 0.9
            let r = 0.13 * split
            let cx: Double = cos(a) * r, cz: Double = sin(a) * r, cyy: Double = 0.02 * sin(a * 2)
            let yinP = SIMD3<Float>(Float(cx), Float(cyy), Float(cz))
            root.findEntity(named: "yin")?.position = yinP
            root.findEntity(named: "yang")?.position = -yinP
            setOpacity(root.findEntity(named: "yin"), split)
            setOpacity(root.findEntity(named: "yang"), split)
            // 三：冲气居中，连成一环
            let three = ph < 2 ? 0 : (ph == 2 ? smooth(p / 0.6) : 1)
            let chS: Double = (0.1 + 0.9 * three) * (1 + 0.08 * sin(t * 3))
            root.findEntity(named: "chong")?.scale = SIMD3<Float>(repeating: Float(chS))
            setOpacity(root.findEntity(named: "chong"), three)
            for j in 0..<60 { setOpacity(root.findEntity(named: "ring\(j)"), three * 0.8) }
            // 万物：从中心沿各个方向生出，缓缓旋转
            let grow = ph == 3 ? smooth(p / 0.8) : 0
            for i in 0..<Self.many {
                let fi = Double(i)
                let y = 1 - 2 * (fi + 0.5) / Double(Self.many)
                let rr: Double = sqrt(max(0, 1 - y * y))
                let ang: Double = fi * 2.399963 + t * 0.15
                let d: Double = (0.16 + 0.22 * fract(fi * 0.618)) * grow
                let e = root.findEntity(named: "w\(i)")
                let px: Double = cos(ang) * rr * d, py: Double = y * d * 0.8, pz: Double = sin(ang) * rr * d
                e?.position = SIMD3<Float>(Float(px), Float(py), Float(pz))
                setOpacity(e, smooth(grow * 2 - fi / Double(Self.many)))
            }
        }
    }
}
