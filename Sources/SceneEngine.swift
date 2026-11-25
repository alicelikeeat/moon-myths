import SwiftUI
import Observation

// MARK: - 段落动画：通用引擎 + JSON 剧本
//
// 剧本放在仓库 anims/<全文 id>.json，和全文一样按需下载，增加动画不需要发新版。
// 一个剧本 = 若干元素 + 若干节拍。元素在第 `at` 拍出现，节拍里可以移动、改色、改字、隐藏。

struct AnimDoc: Codable {
    let id: String
    let scenes: [AnimScene]
    var scores: [Int]? = nil      // 每段的评分（宗教经典没有）
    var style: String? = nil      // 宗教经典：bible / quran / buddhist / vedic
    var basic: Bool? = nil        // 其余段落是否在手机上生成普通动画
}

struct AnimScene: Codable, Identifiable, Hashable {
    var id: String { anchor }
    let anchor: String            // 段落里的一小段原文，用来定位
    let title: String
    let caption: String?
    let elements: [AnimElement]
    let beats: [AnimBeat]
    var tier: String? = nil       // "core" 精讲；"plus" 进阶（按句式自动成图）；"basic" 普通
    var score: Int? = nil         // 段落评分 0–100（书内百分位）

    var isCore: Bool { tier == nil || tier == "core" }
    var isScripture: Bool { tier == "scripture" }
    var isPlus: Bool { tier == "plus" }
    var hasEffects: Bool { tier != "basic" }

    static func == (a: AnimScene, b: AnimScene) -> Bool { a.anchor == b.anchor }
    func hash(into h: inout Hasher) { h.combine(anchor) }
}

struct AnimElement: Codable {
    let id: String
    let kind: String              // node box ring text arrow particles bar
    var x: Double? = nil, y: Double? = nil        // 0…1（相对舞台）
    var r: Double? = nil                          // 点
    var w: Double? = nil, h: Double? = nil        // 0…1（相对舞台）
    var color: String? = nil
    var label: String? = nil
    var size: Double? = nil
    var from: String? = nil, to: String? = nil    // 箭头两端
    var dash: Bool? = nil
    var n: Int? = nil                             // 粒子数
    var at: Int? = nil                            // 第几拍出现（默认 0）
    var flow: Bool? = nil                         // 箭头上流动的光点（精讲默认开启）
    var orbit: String? = nil                      // 绕某个元素旋转
    var or: Double? = nil                         // 环绕半径（点）
    var speed: Double? = nil                      // 环绕角速度
    var font: String? = nil                       // "serif"：经文用衬线字体
}

struct AnimPatch: Codable {
    var x: Double? = nil, y: Double? = nil, r: Double? = nil, w: Double? = nil, h: Double? = nil
    var color: String? = nil
    var label: String? = nil
    var opacity: Double? = nil
}

struct AnimBeat: Codable {
    var dur: Double? = nil
    let headline: String
    var set: [String: AnimPatch]? = nil
    var hide: [String]? = nil
    var pulse: [String]? = nil
}

/// 一个元素在某一拍结束时的状态
private struct ElState {
    var x = 0.5, y = 0.5, r = 14.0, w = 0.3, h = 0.12
    var color = "silver"
    var label = ""
    var opacity = 0.0
}

func animColor(_ name: String) -> Color {
    switch name {
    case "gold": return Moon.gold
    case "violet": return Moon.violet
    case "dim": return Moon.dim
    case "primary": return Color.primary
    case "red": return Color.red.opacity(0.8)
    case "green": return Color.green.opacity(0.8)
    case "blue": return Color.blue.opacity(0.8)
    default: return Moon.silver
    }
}

/// 预先算好每一拍的状态，绘制时只做插值
final class SceneRuntime {
    let scene: AnimScene
    private let order: [String]
    private let kinds: [String: AnimElement]
    private let states: [[String: ElState]]      // states[b] = 第 b 拍结束时
    private let initial: [String: ElState]
    let durations: [Double]

    init(_ scene: AnimScene) {
        self.scene = scene
        order = scene.elements.map(\.id)
        var k: [String: AnimElement] = [:]
        for e in scene.elements { k[e.id] = e }
        kinds = k
        durations = scene.beats.map { min(9, max(5, $0.dur ?? 6.5)) }

        var cur: [String: ElState] = [:]
        for e in scene.elements {
            var s = ElState()
            s.x = e.x ?? 0.5; s.y = e.y ?? 0.5; s.r = e.r ?? 14
            s.w = e.w ?? 0.3; s.h = e.h ?? 0.12
            s.color = e.color ?? "silver"; s.label = e.label ?? ""
            s.opacity = 0
            cur[e.id] = s
        }
        initial = cur
        var all: [[String: ElState]] = []
        for (b, beat) in scene.beats.enumerated() {
            for e in scene.elements where (e.at ?? 0) == b { cur[e.id]?.opacity = 1 }
            for (id, p) in beat.set ?? [:] {
                guard var s = cur[id] else { continue }
                if let v = p.x { s.x = v }
                if let v = p.y { s.y = v }
                if let v = p.r { s.r = v }
                if let v = p.w { s.w = v }
                if let v = p.h { s.h = v }
                if let v = p.color { s.color = v }
                if let v = p.label { s.label = v }
                if let v = p.opacity { s.opacity = v }
                cur[id] = s
            }
            for id in beat.hide ?? [] { cur[id]?.opacity = 0 }
            all.append(cur)
        }
        states = all
    }

    func draw(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
        guard !scene.beats.isEmpty else { return }
        let W = Double(size.width), H = Double(size.height)
        let (b, p) = beats(t, durations)
        let k = smooth(min(1, p / 0.45))
        let from = b == 0 ? initial : states[b - 1]
        let to = states[b]
        let pulse = Set(scene.beats[b].pulse ?? [])

        func mix(_ id: String) -> ElState? {
            guard let a = from[id], let c = to[id] else { return nil }
            var s = c
            s.x = lerp(a.x, c.x, k); s.y = lerp(a.y, c.y, k); s.r = lerp(a.r, c.r, k)
            s.w = lerp(a.w, c.w, k); s.h = lerp(a.h, c.h, k)
            s.opacity = lerp(a.opacity, c.opacity, k)
            s.color = k < 0.5 ? a.color : c.color
            s.label = k < 0.5 && a.opacity > 0 ? a.label : c.label
            if pulse.contains(id) { s.r *= 1 + 0.09 * sin(t * 3.2) }
            if let e = kinds[id], let o = e.orbit, let a = from[o], let c = to[o] {
                let cx = lerp(a.x, c.x, k), cy = lerp(a.y, c.y, k)
                let ang = t * (e.speed ?? 0.6) + Double(id.unicodeScalars.reduce(0) { $0 + Int($1.value) } % 7)
                let rad = e.or ?? 60
                s.x = cx + cos(ang) * rad / W
                s.y = cy + sin(ang) * rad * 0.8 / H
            }
            return s
        }

        // 精讲：背景缓慢漂浮的微粒
        if scene.isCore || scene.isScripture {
            for i in 0..<18 {
                let q = Double(i)
                let x = fract(hash01(q) + t * 0.004 * (1 + hash01(q + 5))) * W
                let y = fract(hash01(q + 11) - t * 0.006 * (1 + hash01(q + 2))) * H
                blob(&ctx, x, y, 1.2 + hash01(q + 7) * 1.4, Moon.gold.opacity(0.10 + 0.08 * sin(t + q)))
            }
        }

        // 先画箭头、粒子，再画节点和文字
        for id in order {
            guard let e = kinds[id], let s = mix(id), s.opacity > 0.02 else { continue }
            switch e.kind {
            case "arrow":
                guard let f = e.from, let g = e.to, let a = mix(f), let c = mix(g) else { continue }
                drawArrow(&ctx, a, c, kinds[f]?.kind, kinds[g]?.kind, s, e, W, H, t)
            case "halo":
                drawHalo(&ctx, s.x * W, s.y * H, s.r, animColor(s.color), s.opacity, t)
            case "rays":
                drawRays(&ctx, s.x * W, s.y * H, s.r, e.n ?? 14, animColor(s.color), s.opacity, t)
            case "star":
                drawStarLattice(&ctx, W, H, s.r, animColor(s.color), s.opacity, t)
            case "lotus":
                drawLotus(&ctx, s.x * W, s.y * H, s.r, e.n ?? 8, animColor(s.color), s.opacity, t)
            case "rings":
                drawRings(&ctx, s.x * W, s.y * H, s.r, e.n ?? 4, animColor(s.color), s.opacity, t)
            case "frame":
                drawFrame(&ctx, W, H, animColor(s.color), s.opacity)
            case "particles":
                let n = e.n ?? 30
                for i in 0..<n {
                    let q = Double(i)
                    let ang = q * 2.399 + t * 0.35
                    let rad = s.r * (0.25 + 0.75 * fract(q * 0.618 + t * 0.05))
                    blob(&ctx, s.x * W + cos(ang) * rad, s.y * H + sin(ang) * rad * 0.8, 2.4,
                         animColor(s.color).opacity(0.75 * s.opacity))
                }
                if !s.label.isEmpty { label(&ctx, s.label, s.x * W, s.y * H + s.r + 14, Moon.dim.opacity(s.opacity), size: 11) }
            default: break
            }
        }
        for id in order {
            guard let e = kinds[id], let s = mix(id), s.opacity > 0.02 else { continue }
            let col = animColor(s.color).opacity(s.opacity)
            let x = s.x * W, y = s.y * H
            if scene.hasEffects && pulse.contains(id) && e.kind != "text" && e.kind != "arrow" {
                // 精讲：重点处扩散的光晕
                for j in 0..<2 {
                    let f = fract(t * 0.45 + Double(j) * 0.5)
                    let base = e.kind == "box" ? max(s.w * W, s.h * H) / 2 : s.r
                    ring(&ctx, x, y, base * (1.1 + f * 0.9), animColor(s.color).opacity(0.45 * (1 - f) * s.opacity), 1.5)
                }
            }
            switch e.kind {
            case "node":
                dot(&ctx, x, y, s.r, col)
                if !s.label.isEmpty { label(&ctx, s.label, x, y + s.r + 13, Color.primary.opacity(0.85 * s.opacity), size: e.size ?? 12) }
            case "box":
                let bw = s.w * W, bh = s.h * H
                box(&ctx, x - bw / 2, y - bh / 2, bw, bh, col)
                if !s.label.isEmpty { label(&ctx, s.label, x, y, Color.primary.opacity(s.opacity), size: e.size ?? 13) }
            case "bar":
                let bw = s.w * W, bh = max(1, s.h * H)
                box(&ctx, x - bw / 2, y - bh, bw, bh, col)
                if !s.label.isEmpty { label(&ctx, s.label, x, y + 14, Color.primary.opacity(0.8 * s.opacity), size: e.size ?? 11) }
            case "ring":
                ring(&ctx, x, y, s.r, col, 1.6, dash: (e.dash ?? false) ? [5, 5] : [])
                if !s.label.isEmpty { label(&ctx, s.label, x, y - s.r - 12, col, size: e.size ?? 12) }
            case "text":
                label(&ctx, s.label, x, y, animColor(s.color == "silver" ? "primary" : s.color).opacity(s.opacity), size: e.size ?? 13,
                      serif: e.font == "serif")
            default: break
            }
        }
        headline(&ctx, scene.beats[b].headline, size)
        if let c = scene.caption { caption(&ctx, c, size) }
    }

    private func extent(_ s: ElState, _ kind: String?, _ W: Double, _ H: Double, _ dx: Double, _ dy: Double) -> Double {
        switch kind {
        case "box":
            // 从中心沿方向到矩形边缘的距离
            let hw = s.w * W / 2, hh = s.h * H / 2
            let len = max(0.001, hypot(dx, dy))
            let tx = abs(dx) > 0.001 ? hw / abs(dx / len) : .infinity
            let ty = abs(dy) > 0.001 ? hh / abs(dy / len) : .infinity
            return min(tx, ty) + 4
        case "ring": return s.r + 4
        case "text": return 16
        default: return s.r + 5
        }
    }

    private func drawArrow(_ ctx: inout GraphicsContext, _ a: ElState, _ c: ElState, _ ka: String?, _ kc: String?,
                           _ s: ElState, _ e: AnimElement, _ W: Double, _ H: Double, _ t: Double) {
        let ax = a.x * W, ay = a.y * H, cx = c.x * W, cy = c.y * H
        let dx = cx - ax, dy = cy - ay
        let len = hypot(dx, dy)
        guard len > 1 else { return }
        let ux = dx / len, uy = dy / len
        let s0 = extent(a, ka, W, H, dx, dy), s1 = extent(c, kc, W, H, -dx, -dy)
        let x0 = ax + ux * s0, y0 = ay + uy * s0
        let full = max(0, len - s0 - s1)
        let grow = s.opacity                    // 出现时从头长出来
        let x1 = x0 + ux * full * grow, y1 = y0 + uy * full * grow
        let col = animColor(s.color).opacity(0.85 * min(1, a.opacity, c.opacity))
        line(&ctx, x0, y0, x1, y1, col, 2, dash: (e.dash ?? false) ? [5, 4] : [])
        if grow > 0.9 && (e.flow ?? scene.hasEffects) && full > 30 {
            // 精讲：沿箭头流动的光点
            for j in 0..<3 {
                let f = fract(t * 0.35 + Double(j) / 3)
                blob(&ctx, x0 + ux * full * f, y0 + uy * full * f, 2.6, col.opacity(sin(f * .pi)))
            }
        }
        if grow > 0.9 {
            let hx = -ux * 9, hy = -uy * 9
            line(&ctx, x1, y1, x1 + hx * 0.87 - hy * 0.5, y1 + hy * 0.87 + hx * 0.5, col, 2)
            line(&ctx, x1, y1, x1 + hx * 0.87 + hy * 0.5, y1 + hy * 0.87 - hx * 0.5, col, 2)
        }
        if !s.label.isEmpty && grow > 0.6 {
            label(&ctx, s.label, (x0 + x1) / 2 - uy * 14, (y0 + y1) / 2 + ux * 14, col, size: e.size ?? 11)
        }
    }
}

// MARK: - 经文的装饰（只用几何与光，不描绘任何神圣人物）

private func drawHalo(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ c: Color, _ o: Double, _ t: Double) {
    let breathe = 1 + 0.04 * sin(t * 0.8)
    let rr = r * breathe
    ctx.fill(Path(ellipseIn: CGRect(x: x - rr, y: y - rr, width: rr * 2, height: rr * 2)),
             with: .radialGradient(Gradient(colors: [c.opacity(0.28 * o), c.opacity(0.10 * o), c.opacity(0)]),
                                   center: CGPoint(x: x, y: y), startRadius: 0, endRadius: rr))
}

private func drawRays(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ n: Int, _ c: Color, _ o: Double, _ t: Double) {
    for i in 0..<n {
        let a = .pi * (0.08 + 0.84 * Double(i) / Double(max(1, n - 1))) + 0.02 * sin(t * 0.3 + Double(i))
        let len = r * (0.75 + 0.25 * sin(t * 0.5 + Double(i) * 1.7))
        var p = Path()
        p.move(to: CGPoint(x: x, y: y))
        p.addLine(to: CGPoint(x: x + cos(a) * len, y: y + sin(a) * len))
        ctx.stroke(p, with: .linearGradient(Gradient(colors: [c.opacity(0.35 * o), c.opacity(0)]),
                                            startPoint: CGPoint(x: x, y: y), endPoint: CGPoint(x: x + cos(a) * len, y: y + sin(a) * len)),
                   lineWidth: 1.2)
    }
}

/// 八角星几何纹样（伊斯兰装饰传统中常见的抽象图案）
private func drawStarLattice(_ ctx: inout GraphicsContext, _ W: Double, _ H: Double, _ cell: Double, _ c: Color, _ o: Double, _ t: Double) {
    let step = max(40, cell)
    let rot = t * 0.015
    var y = -step / 2
    var row = 0
    while y < H + step {
        var x = (row % 2 == 0 ? 0 : step / 2) - step / 2
        while x < W + step {
            var p = Path()
            for k in 0..<2 {
                let base = rot + Double(k) * .pi / 4
                for j in 0..<4 {
                    let a0 = base + Double(j) * .pi / 2, a1 = base + Double(j + 1) * .pi / 2
                    let rr = step * 0.32
                    if j == 0 { p.move(to: CGPoint(x: x + cos(a0) * rr, y: y + sin(a0) * rr)) }
                    p.addLine(to: CGPoint(x: x + cos(a1) * rr, y: y + sin(a1) * rr))
                }
                p.closeSubpath()
            }
            ctx.stroke(p, with: .color(c.opacity(0.16 * o)), lineWidth: 0.8)
            x += step
        }
        y += step * 0.87
        row += 1
    }
}

private func drawLotus(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ n: Int, _ c: Color, _ o: Double, _ t: Double) {
    let open = 0.85 + 0.15 * sin(t * 0.4)
    for layer in 0..<2 {
        let lr = r * (layer == 0 ? 1 : 0.62) * open
        let count = layer == 0 ? n : max(4, n - 2)
        for i in 0..<count {
            let a = Double(i) / Double(count) * 2 * .pi + Double(layer) * .pi / Double(count) + t * 0.01
            var petal = Path()
            petal.addEllipse(in: CGRect(x: -lr * 0.16, y: -lr * 0.5, width: lr * 0.32, height: lr))
            let tr = CGAffineTransform(translationX: x + cos(a) * lr * 0.5, y: y + sin(a) * lr * 0.5).rotated(by: a + .pi / 2)
            ctx.stroke(petal.applying(tr), with: .color(c.opacity((layer == 0 ? 0.22 : 0.32) * o)), lineWidth: 1)
        }
    }
}

private func drawRings(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ n: Int, _ c: Color, _ o: Double, _ t: Double) {
    for i in 0..<n {
        let f = fract(Double(i) / Double(n) + t * 0.03)
        let rr = r * (0.2 + 0.8 * f)
        ctx.stroke(Path(ellipseIn: CGRect(x: x - rr, y: y - rr, width: rr * 2, height: rr * 2)),
                   with: .color(c.opacity(0.3 * o * (1 - f))), lineWidth: 1)
    }
}

private func drawFrame(_ ctx: inout GraphicsContext, _ W: Double, _ H: Double, _ c: Color, _ o: Double) {
    for (inset, a) in [(14.0, 0.35), (19.0, 0.18)] {
        ctx.stroke(Path(roundedRect: CGRect(x: inset, y: inset + 22, width: W - inset * 2, height: H - inset * 2 - 40), cornerRadius: 10),
                   with: .color(c.opacity(a * o)), lineWidth: 0.8)
    }
    for (cx, cy) in [(14.0, 36.0), (W - 14, 36.0), (14.0, H - 18), (W - 14, H - 18)] {
        var d = Path()
        d.move(to: CGPoint(x: cx, y: cy - 5)); d.addLine(to: CGPoint(x: cx + 5, y: cy))
        d.addLine(to: CGPoint(x: cx, y: cy + 5)); d.addLine(to: CGPoint(x: cx - 5, y: cy)); d.closeSubpath()
        ctx.fill(d, with: .color(c.opacity(0.4 * o)))
    }
}

// MARK: - 下载与缓存

@Observable
@MainActor
final class AnimStore {
    static let shared = AnimStore()
    private(set) var docs: [String: AnimDoc] = [:]
    private var fetched: Set<String> = []

    private let dir: URL = {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("anims", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }()

    private func file(_ id: String) -> URL { dir.appendingPathComponent("\(id).json") }

    /// 先读缓存，再联网更新（每次启动每本书最多联网一次）
    func load(_ id: String) async -> AnimDoc? {
        if docs[id] == nil,
           let src = FileManager.default.fileExists(atPath: file(id).path) ? file(id) : TextStore.bundled("anims", id),
           let data = try? Data(contentsOf: src),
           let doc = try? JSONDecoder().decode(AnimDoc.self, from: data) {
            docs[id] = doc
        }
        if !fetched.contains(id) {
            let url = URL(string: "https://raw.githubusercontent.com/alicelikeeat/moon-myths/main/anims/\(id).json")!
            // 用独立任务下载：阅读页刷新导致的任务取消不会让这次下载失败
            let result = await Task.detached { try? await URLSession.shared.data(from: url) }.value
            if let res = result, (res.1 as? HTTPURLResponse)?.statusCode == 200,
               let doc = try? JSONDecoder().decode(AnimDoc.self, from: res.0) {
                try? res.0.write(to: file(id), options: .atomic)
                docs[id] = doc
                fetched.insert(id)          // 只有成功才记下，失败了下次打开还会再试
            }
        }
        return docs[id]
    }
}

// MARK: - 播放界面

struct ParagraphAnimSheet: View {
    let scene: AnimScene
    let text: String
    @State private var clock = PlaybackClock()
    @State private var runtime: SceneRuntime
    @Environment(\.dismiss) private var dismiss

    init(scene: AnimScene, text: String) {
        self.scene = scene
        self.text = text
        _runtime = State(initialValue: SceneRuntime(scene))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(scene.title)
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        Stage(height: 380) {
                            LiveCanvas(clock: clock) { ctx, size, t in
                                runtime.draw(&ctx, size, t)
                            }
                        }
                        .playbackControls(clock)
                        Text(text)
                            .font(.system(size: 15, design: .serif))
                            .foregroundStyle(Color.primary.opacity(0.75))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.regular, in: .rect(cornerRadius: 18))
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }
}

// MARK: - 截图用：九宫格预览（`-animGrid <全文 id> -animPage k -animBeat b`）

struct AnimGridView: View {
    let textId: String
    let page: Int
    let beat: Int
    @State private var scenes: [AnimScene] = []

    var body: some View {
        let cols = Array(repeating: GridItem(.fixed(126), spacing: 4), count: 3)
        LazyVGrid(columns: cols, spacing: 6) {
            ForEach(Array(scenes.enumerated()), id: \.offset) { i, s in
                let rt = SceneRuntime(s)
                let b = min(beat, rt.durations.count - 1)
                let t = rt.durations.prefix(b).reduce(0, +) + rt.durations[b] * 0.85
                VStack(spacing: 2) {
                    Canvas { ctx, size in rt.draw(&ctx, size, t) }
                        .frame(width: 350, height: 380)
                        .background(Color.primary.opacity(0.04))
                        .scaleEffect(0.36)
                        .frame(width: 126, height: 137)
                    Text("\(page * 9 + i + 1). \(s.title)").font(.system(size: 8)).lineLimit(1)
                }
            }
        }
        .padding(.top, 50)
        .task {
            if let d = await AnimStore.shared.load(textId) {
                scenes = Array(d.scenes.dropFirst(page * 9).prefix(9))
            }
        }
    }
}
