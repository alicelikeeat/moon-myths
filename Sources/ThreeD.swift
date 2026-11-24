import SwiftUI
import RealityKit
import UIKit

/// 有 3D 版本的章节（键：书籍 id + ":" + 章节序号）
let threeDScenes: [String: (PlaybackClock) -> AnyView] = [
    "kant-cpr:0": { clock in AnyView(Copernicus3D(clock: clock)) },
]

private func glass(_ color: UIColor, alpha: CGFloat) -> SimpleMaterial {
    SimpleMaterial(color: color.withAlphaComponent(alpha), roughness: 0.08, isMetallic: false)
}

/// 哥白尼式革命：旧模式“认识绕着对象转”，新模式“对象绕着认识转”。拖动可旋转视角。
struct Copernicus3D: View {
    let clock: PlaybackClock
    @State private var yaw: Float = 0.5
    @State private var pitch: Float = 0.35
    @GestureState private var drag: CGSize = .zero

    private let count = 6

    var body: some View {
        TimelineView(.animation) { tl in
            let t = clock.time(tl.date.timeIntervalSinceReferenceDate)
            let (ph, p) = beats(t, [7, 7])
            let k = ph == 0 ? 1 - smooth(p / 0.25) : smooth(p / 0.25)   // 0 = 旧, 1 = 新
            ZStack(alignment: .top) {
                RealityView { content in
                    let root = Entity()
                    root.name = "root"
                    let mind = ModelEntity(mesh: .generateSphere(radius: 0.07),
                                           materials: [glass(UIColor(red: 1, green: 0.85, blue: 0.5, alpha: 1), alpha: 0.85)])
                    mind.name = "mind"
                    root.addChild(mind)
                    for i in 0..<count {
                        let o = ModelEntity(mesh: .generateSphere(radius: 0.035),
                                            materials: [glass(UIColor(red: 0.75, green: 0.85, blue: 1, alpha: 1), alpha: 0.75)])
                        o.name = "obj\(i)"
                        root.addChild(o)
                        let ray = ModelEntity(mesh: .generateCylinder(height: 1, radius: 0.002),
                                              materials: [UnlitMaterial(color: UIColor.white.withAlphaComponent(0.45))])
                        ray.name = "ray\(i)"
                        root.addChild(ray)
                    }
                    // 轨道环：一圈小点
                    for j in 0..<48 {
                        let a = Float(j) / 48 * 2 * .pi
                        let d = ModelEntity(mesh: .generateSphere(radius: 0.004),
                                            materials: [UnlitMaterial(color: UIColor.white.withAlphaComponent(0.35))])
                        d.position = [cos(a) * 0.32, 0, sin(a) * 0.32]
                        root.addChild(d)
                    }
                    content.add(root)

                    let camera = PerspectiveCamera()
                    camera.camera.fieldOfViewInDegrees = 45
                    camera.look(at: .zero, from: [0, 0.25, 1.0], relativeTo: nil)
                    content.add(camera)

                    let light = DirectionalLight()
                    light.light.intensity = 4000
                    light.look(at: .zero, from: [0.6, 1, 0.8], relativeTo: nil)
                    content.add(light)
                } update: { content in
                    guard let root = content.entities.first(where: { $0.name == "root" }) else { return }
                    let y = yaw + Float(drag.width) * 0.01
                    let x = max(-1.2, min(1.2, pitch + Float(drag.height) * 0.01))
                    root.orientation = simd_quatf(angle: x, axis: [1, 0, 0]) * simd_quatf(angle: y, axis: [0, 1, 0])

                    let r: Float = 0.32
                    let ma = Float(t * 0.7)
                    let oldMind = SIMD3<Float>(cos(ma) * r * 0.55, 0.05 * sin(ma * 2), sin(ma) * r * 0.55)
                    let mindPos = oldMind * Float(1 - k)
                    root.findEntity(named: "mind")?.position = mindPos
                    for i in 0..<count {
                        let a = Float(i) / Float(count) * 2 * .pi + Float(t * 0.35 * k)
                        let tilt = Float(0.08) * sin(a * 2)
                        let pos = SIMD3<Float>(cos(a) * r, tilt, sin(a) * r)
                        root.findEntity(named: "obj\(i)")?.position = pos
                        if let ray = root.findEntity(named: "ray\(i)") {
                            let d = pos - mindPos
                            let len = simd_length(d)
                            ray.position = (pos + mindPos) / 2
                            ray.scale = [1, max(0.001, len), 1]
                            if len > 0.0001 {
                                ray.orientation = simd_quatf(from: [0, 1, 0], to: simd_normalize(d))
                            }
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .updating($drag) { v, s, _ in s = v.translation }
                        .onEnded { v in
                            yaw += Float(v.translation.width) * 0.01
                            pitch = max(-1.2, min(1.2, pitch + Float(v.translation.height) * 0.01))
                        }
                )

                Text(k < 0.5 ? "旧：认识绕着对象转" : "新：对象绕着认识转")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 14).padding(.vertical, 7)
                    .glassEffect(.regular, in: .capsule)
                    .padding(.top, 14)
            }
            .overlay(alignment: .bottomLeading) {
                Label("拖动旋转", systemImage: "hand.draw")
                    .font(.caption2).foregroundStyle(Color.primary.opacity(0.6))
                    .padding(14)
            }
        }
    }
}
