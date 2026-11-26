import SwiftUI
import RealityKit
import UIKit

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
                        highlight: { refs in
                            // 展开的那一层：显示这一层所有人的名字
                            refs.reveal = []
                            if let l = refs.group {
                                var i = 0
                                for (k, n) in pyramidRows.enumerated() {
                                    if k == l { refs.reveal = Set(rankedThinkers[i..<min(rankedThinkers.count, i + n)].map(\.id)) }
                                    i += n
                                }
                            }
                        },
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
                    // 卡通小人（或考据雕像）站在一块等级色小底座上
                    let block = model(.generateBox(size: [0.024, 0.006, 0.024], cornerRadius: 0.002), tierMat(t))
                    let fs: Float = tier == .pure ? 1.25 : 0.95
                    let fig = figureSlot(for: t, scale: fs)
                    fig.position = [0, 0.003, 0]
                    fig.components.set(BillboardComponent())
                    block.addChild(fig)
                    let label = text3D(shortName(t), size: tier == .pure ? 0.024 : 0.016)
                    refs.labels[t.id] = label
                    label.position = [0, 0.05 * fs + 0.01, 0]
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
                    let k = ease3((t - Double(n - 1 - layer) * 0.09) / 0.7)
                    refs["L\(layer)"]?.position.y = -0.35 * (1 - k)
                    fade3(refs["L\(layer)"], k)
                    let pk = ease3((t - Double(n - 1 - layer) * 0.09 - 0.45) / 0.5)
                    refs["P\(layer)"]?.position.y = 0.06 * (1 - pk)
                    fade3(refs["P\(layer)"], pk)
                }
            } else {
                // 展开：选中的一层沿外沿排成一圈；它上面的层淡化
                for layer in 0..<n {
                    let e = approach(refs, "exp\(layer)", refs.group == layer ? 1 : 0)
                    let op = approach(refs, "op\(layer)", (refs.group.map { layer < $0 } ?? false) ? 0.12 : 1)
                    if refs.values["opSet\(layer)"] != op { fade3(refs["L\(layer)"], op); refs.values["opSet\(layer)"] = op }
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
                                fade3(refs["arc\(k)"], on ? 1 : 0.04)
                            }
                            for (i, t) in Self.order.enumerated() {
                                guard let seat = refs["seat\(i)"]?.children.first else { continue }
                                fade3(seat, id == nil || linked.contains(t.id) || t.id == id ? 1 : 0.22)
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
                // 没有合格雕像时先放卡通示意小人；雕像“可展示”后自动替换
                let slot = figureSlot(for: t)
                slot.position = [0, h / 2 + 0.0015, 0]
                slot.components.set(BillboardComponent())
                seat.addChild(slot)
                let label = text3D(shortName(t), size: 0.014)
                refs.labels[t.id] = label
                label.position = [0, h / 2 + (i % 2 == 0 ? 0.062 : 0.078), 0]
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
                let lift = 0.03 + 0.05 * simd_length(p - q)
                var pts: [SIMD3<Float>] = []
                for s in 0...14 {
                    let u = Float(s) / 14
                    var c = p + (q - p) * u
                    c.y += 4 * lift * u * (1 - u)
                    c.x *= 1 - 0.3 * 4 * u * (1 - u)
                    c.z *= 1 - 0.3 * 4 * u * (1 - u)
                    pts.append(c)
                }
                // 一条弧一个网格（原来是 6 段小圆柱）；越接近被影响者一端越粗，看得出方向
                let arc = Entity()
                if let mesh = tubesMesh([pts], radius: [(0.0008, 0.0019)], sides: 6) {
                    arc.addChild(ModelEntity(mesh: mesh, materials: [tubeMat(col, opacity: 0.55, rough: 0.3, metal: 0.6)]))
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
                    let k = ease3((t - Double(i) * 0.025) / 0.5)
                    fade3(seat, k)
                    h.position.y = 0.015 + 0.08 * (1 - k)
                }
            }
            fade3(refs["arcs"], ease3((t - Double(n) * 0.025) / 1.2) * (0.8 + 0.2 * sin(Float(refs.now) * 1.2)))
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
                        highlight: { refs in
                            refs.reveal = []
                            if let r = refs.group {
                                let start = Self.ringSizes.prefix(r).reduce(0, +)
                                refs.reveal = Set(rankedThinkers[start..<min(rankedThinkers.count, start + Self.ringSizes[r])].map(\.id))
                            }
                        },
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
                    // 卡通小人站在一枚等级色的浮空小盘上
                    let soul = model(.generateCylinder(height: 0.003, radius: tier == .pure ? 0.017 : 0.013), tierMat(t), at: [cos(a) * rad, 0, sin(a) * rad])
                    let fs: Float = tier == .pure ? 1.05 : 0.8
                    let fig = figureSlot(for: t, scale: fs)
                    fig.position = [0, 0.0015, 0]
                    fig.components.set(BillboardComponent())
                    soul.addChild(fig)
                    let label = text3D(shortName(t), size: 0.016)
                    refs.labels[t.id] = label
                    label.position = [0, 0.05 * fs + 0.01, 0]
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
                    let k = ease3((t - Double(r) * 0.15) / 0.9)
                    ring.scale = .init(repeating: 0.2 + 0.8 * k)
                    fade3(ring, k)
                } else {
                    let op = approach(refs, "op\(r)", refs.group == nil || refs.group == r ? 1 : 0.15)
                    if refs.values["opSet\(r)"] != op { fade3(ring, op); refs.values["opSet\(r)"] = op }
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
    private static var order: [Thinker] { Region.allCases.flatMap { r in rankedThinkers.filter { $0.region == r } } }

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
                // 柱头上站着这位人物的卡通小人（或考据雕像）
                let fig = figureSlot(for: t, scale: 0.7)
                fig.position = [0, h / 2 + 0.006, 0]
                fig.components.set(BillboardComponent())
                col.addChild(fig)
                let label = text3D(shortName(t), size: 0.015)
                refs.labels[t.id] = label
                label.position = [0, h / 2 + 0.05, 0]
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
                let cube = model(.generateBox(size: [0.05, 0.02, 0.05], cornerRadius: 0.004), tierMat(top))
                let fig = figureSlot(for: top, scale: 1.8)
                fig.position = [0, 0.01, 0]
                fig.components.set(BillboardComponent())
                cube.addChild(fig)
                let label = text3D(shortName(top), size: 0.03)
                label.position = [0, 0.11, 0]
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
                    let k = ease3((t - Double(i) * 0.018) / 0.6)
                    base.scale = [1, max(0.001, k), 1]
                    fade3(base, k)
                }
            } else {
                // 剖视：挡在镜头前方的那一段柱子淡出
                let cut = refs.group == 0
                let phiC = atan2(refs.camPos.x, refs.camPos.z)
                for i in 0..<n {
                    let front = cut && abs(wrapAngle((refs.values["az\(i)"] ?? 0) - phiC)) < 0.95
                    let op = approach(refs, "colOp\(i)", front ? 0.1 : 1)
                    if refs.values["colSet\(i)"] != op { fade3(refs["col\(i)"], op); refs.values["colSet\(i)"] = op }
                }
            }
            let roofIn = ease3((t - after) / 0.8)
            let beamIn = ease3((t - after - 0.6) / 0.8)
            if t < after + 1.6 {
                refs["roof"]?.position.y = 0.25 * (1 - roofIn)
                fade3(refs["roof"], roofIn)
            } else {
                let op = approach(refs, "roofOp", refs.group == 0 ? 0.05 : 1)
                if refs.values["roofSet"] != op { fade3(refs["roof"], op); refs.values["roofSet"] = op }
            }
            fade3(refs["beam"], beamIn * (0.8 + 0.2 * sin(Float(refs.now) * 1.1)))
            for m in 0..<Self.motes {
                let fm = Double(m)
                let u = Float((refs.now * 0.08 + fm / Double(Self.motes)).truncatingRemainder(dividingBy: 1))
                let ang = Float(fm * 2.4 + refs.now * 0.3)
                let e = refs["mote\(m)"]
                e?.position = [cos(ang) * 0.035, 0.02 + u * 0.6, sin(ang) * 0.035]
                fade3(e, beamIn * sin(u * .pi))
            }
            if let idol = refs["idol"] {
                idol.orientation = simd_quatf(angle: Float(t) * 0.4, axis: [0, 1, 0])
                idol.position.y = 0.008 * sin(Float(t) * 1.4)
                fade3(idol, beamIn)
            }
        }
    }
}

// MARK: - 世界树 3D：渐细的树干与根，三条枝在空间里分开生长；每位人物是站在等级底座上的卡通小人，周围有萤火

struct WorldTree3DView: View {
    private static let W = 390.0
    private static let layout = treeLayout(width: W)
    private static let fireflies = 24

    /// 2D 布局 → 3D 位置：高度来自年代，左右来自枝的位置；三条枝在纵深上错开
    private static func place(_ n: TreeNode) -> SIMD3<Float> {
        let x = Float((n.x / W - 0.5) * 1.3)
        let y = Float((1 - n.y / layout.height) * 1.7 - 0.15)
        let wob = Float(sin(Double(n.order) * 1.7)) * 0.06
        let z: Float
        switch n.thinker.region {
        case .china: z = 0.16 + wob
        case .west: z = -0.16 + wob
        case .math: z = 0.32 + wob
        }
        return [x, y, z]
    }

    /// 主枝的中线：从树干（x = 0）出发，约 0.3 的高度内平缓弯到这一枝的位置
    private static func spine(_ r: Region, _ y: Float, _ y0: Float) -> SIMD3<Float> {
        let (bx, bz): (Float, Float) = r == .china ? (-0.34, 0.1) : (r == .west ? (0.34, -0.1) : (0.0, 0.26))
        let u = min(1, max(0, (y - y0) / 0.3))
        let k = u * u * (3 - 2 * u)
        return [bx * k, y, bz * k]
    }

    private static func segment(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ r: Float, _ m: any RealityKit.Material) -> ModelEntity {
        let d = b - a
        let e = model(.generateCylinder(height: max(0.001, simd_length(d)), radius: r), m, at: (a + b) / 2)
        e.orientation = simd_quatf(from: [0, 1, 0], to: simd_normalize(d))
        return e
    }

    var body: some View {
        let nodes = Self.layout.nodes
        let byOrder = nodes.sorted { $0.order < $1.order }
        HomeStage3D(title: "哲学之树", subtitle: "根在下、冠在上：中国一枝、西方一枝、数学一根藤，沿年代向上生长", eye: [0, 0.9, 2.7], target: [0, 0.62, 0],
                    entrance: Double(nodes.count) * 0.03 + 2.2, relations: true, hint: "点人物聚焦 · 拖动环绕 · 双指拉近",
                    hooks: StageHooks(
                        neighbors: { id in
                            guard let i = byOrder.firstIndex(where: { $0.id == id }) else { return (nil, nil) }
                            return (i > 0 ? byOrder[i - 1].id : nil, i + 1 < byOrder.count ? byOrder[i + 1].id : nil)
                        }
                    )) { root, refs in
            let bark = mat(UIColor(red: 0.86, green: 0.82, blue: 0.76, alpha: 1), rough: 0.85)
            let tree = Entity()
            // 树干与根：合成一个管状网格。树干自下而上变细，根向四周伸开
            let top: Float = 1.5, bottom: Float = -0.15
            var woodPaths: [[SIMD3<Float>]] = [(0...12).map { k in SIMD3<Float>(0, bottom + (top - bottom) * Float(k) / 12, 0) }]
            var woodR: [(Float, Float)] = [(0.045, 0.013)]
            for k in 0..<7 {
                let a = Float(k) / 7 * 2 * .pi + 0.3
                woodPaths.append((0...6).map { s in
                    let u = Float(s) / 6
                    return SIMD3<Float>(cos(a) * 0.32 * u, bottom + 0.02 - 0.04 * u - 0.05 * u * u, sin(a) * 0.32 * u)
                })
                woodR.append((0.016, 0.004))
            }
            if let mesh = tubesMesh(woodPaths, radius: woodR, sides: 10) {
                tree.addChild(ModelEntity(mesh: mesh, materials: [tubeMat(UIColor(red: 0.86, green: 0.82, blue: 0.76, alpha: 1), rough: 0.85)]))
            }
            _ = bark
            // 三条枝：从树干上分出，平缓地弯向各自的一侧向上生长；每片叶子用一根短枝接到主枝上
            for region in Region.allCases {
                let ns = nodes.filter { $0.thinker.region == region }.sorted { $0.y > $1.y }
                guard let first = ns.first, let last = ns.last else { continue }
                let y0 = Self.place(first).y - 0.12, y1 = Self.place(last).y + 0.02
                // 主枝与所有短枝合成一个网格
                var spinePts: [SIMD3<Float>] = []
                var y = y0
                while y < y1 { spinePts.append(Self.spine(region, y, y0)); y += 0.03 }
                spinePts.append(Self.spine(region, y1, y0))
                var paths = [spinePts], radii: [(Float, Float)] = [(0.0075, 0.0045)]
                for n in ns {
                    let leaf = Self.place(n)
                    paths.append([Self.spine(region, leaf.y - 0.03, y0), leaf])
                    radii.append((0.003, 0.0022))
                }
                if let mesh = tubesMesh(paths, radius: radii) {
                    tree.addChild(ModelEntity(mesh: mesh, materials: [tubeMat(UIColor(fameRegionTint(region)).withAlphaComponent(1), rough: 0.55)]))
                }
            }
            root.addChild(tree)
            refs["tree"] = tree
            // 人物：等级底座 + 卡通小人（或考据雕像）
            for n in byOrder {
                let t = n.thinker
                let tier = FameTier(fameTotal(t))
                let leaf = model(.generateCylinder(height: 0.004, radius: tier == .pure ? 0.019 : 0.014), tierMat(t), at: Self.place(n))
                let fs: Float = tier == .pure ? 1.15 : 0.85
                let fig = figureSlot(for: t, scale: fs)
                fig.position = [0, 0.002, 0]
                fig.components.set(BillboardComponent())
                leaf.addChild(fig)
                let label = text3D(shortName(t), size: 0.015)
                refs.labels[t.id] = label
                label.position = [0, 0.05 * fs + 0.012, 0]
                leaf.addChild(label)
                tappable(leaf, id: t.id, refs)
                leaf.components.set(OpacityComponent(opacity: 0))
                root.addChild(leaf)
                refs["leaf\(n.order)"] = leaf
            }
            // 萤火
            for f in 0..<Self.fireflies {
                let e = model(.generateSphere(radius: 0.004), mat(UIColor(red: 1, green: 0.88, blue: 0.55, alpha: 1), glow: 6))
                root.addChild(e)
                refs["fly\(f)"] = e
            }
        } animate: { refs, t in
            // 入场：树干从下往上长出，人物按年代依次出现
            let grow = ease3(t / 1.6)
            if t < 2 {
                refs["tree"]?.scale = [1, max(0.01, grow), 1]
                refs["tree"]?.position.y = -0.15 * (1 - grow)
            }
            if t < Double(byOrder.count) * 0.03 + 2.2 {
                for n in byOrder {
                    let k = ease3((t - 1.0 - Double(n.order) * 0.03) / 0.5)
                    fade3(refs["leaf\(n.order)"], k)
                }
            }
            for f in 0..<Self.fireflies {
                let ff: Double = Double(f)
                let speed: Double = 0.15 + 0.05 * sin(ff)
                let aD: Double = ff * 2.4 + refs.now * speed
                let rD: Double = 0.35 + 0.3 * abs(sin(ff * 1.3))
                let yD: Double = 0.1 + fract(ff * 0.37 + refs.now * 0.02) * 1.4
                let a = Float(aD), r = Float(rD), y = Float(yD)
                let e = refs["fly\(f)"]
                e?.position = SIMD3<Float>(cos(a) * r, y, sin(a) * r)
                let tw: Double = 0.4 + 0.6 * abs(sin(refs.now * 1.5 + ff))
                fade3(e, ease3(t - 1.5) * Float(tw))
            }
        }
    }
}
