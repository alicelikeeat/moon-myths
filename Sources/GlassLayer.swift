import SwiftUI
import Observation

/// 动画里用原生 Liquid Glass 呈现的元素
struct GlassNode {
    enum Kind { case circle, rect(corner: Double) }
    let kind: Kind
    let x: Double, y: Double      // 中心
    let w: Double, h: Double
    let color: Color
    var alpha: Double = 1     // 颜色里的透明度：原生玻璃据此整体渐隐
}

/// 叠在玻璃之上的文字
struct GlassText {
    let text: String
    let x: Double, y: Double
    let color: Color
    let size: Double
    var serif: Bool = false
}

/// Canvas 绘制时收集玻璃节点与文字；叠加层用原生 glassEffect 渲染（延迟 ≤ 1 帧，肉眼不可见）
struct BeatInfo {
    let durations: [Double]
    let hold: Double
    let cycleStart: Double
    func index(at t: Double) -> Int {
        var u = t - cycleStart
        for (i, d) in durations.enumerated() { if u < d { return i }; u -= d }
        return durations.count - 1
    }
    func start(of i: Int) -> Double { cycleStart + durations.prefix(i).reduce(0, +) }
}

final class GlassBuffer {
    var nodes: [GlassNode] = []
    var texts: [GlassText] = []
    var beat: BeatInfo?
    /// 这批节点对应的时刻；画布按同一时刻绘制线条，保证玻璃与线条对齐
    var time: Double = Date().timeIntervalSinceReferenceDate
    static var current: GlassBuffer?
}

/// 丢弃型缓冲：绘制线条时屏蔽玻璃元素与文字（它们由叠加层负责）
private let discard = GlassBuffer()

/// 共享时钟：播放 / 暂停 / 拖动时间 / 调速
@Observable
final class PlaybackClock {
    static let window = 20.0          // 暂停后可前后拖动的时间范围（秒）
    static let speeds: [Double] = [0.25, 0.5, 1, 1.5, 2]
    var playing = true
    var scrub = 0.0                    // 0…1，对应暂停时刻之后的 window 秒
    private(set) var speed: Double
    /// 当前动画的节拍信息（由画布每帧写入，不触发界面刷新）
    @ObservationIgnored var beat: BeatInfo?
    private var frozen = 0.0
    private var anchorNow: Double
    private var anchorT: Double

    init() {
        let now = Date().timeIntervalSinceReferenceDate
        anchorNow = now
        anchorT = 0          // 每次打开章节都从第一拍开始
        let saved = UserDefaults.standard.double(forKey: "animSpeed")
        speed = saved > 0 ? saved : 1
        // 截图用：`-pausePlayback` 以暂停状态启动
        if ProcessInfo.processInfo.arguments.contains("-pausePlayback") {
            playing = false
            frozen = 0
            scrub = 0.4
        }
    }

    func time(_ now: Double) -> Double {
        playing ? anchorT + (now - anchorNow) * speed : frozen + scrub * Self.window
    }

    func toggle() {
        let now = Date().timeIntervalSinceReferenceDate
        if playing {
            frozen = time(now)
            scrub = 0
            playing = false
        } else {
            anchorT = frozen + scrub * Self.window
            anchorNow = now
            playing = true
        }
    }

    /// 跳到指定时刻（用于“下一拍”）
    func jump(to target: Double) {
        if playing {
            anchorT = target
            anchorNow = Date().timeIntervalSinceReferenceDate
        } else {
            frozen = target
            scrub = 0
        }
    }

    func setSpeed(_ s: Double) {
        let now = Date().timeIntervalSinceReferenceDate
        if playing {
            anchorT = time(now)
            anchorNow = now
        }
        speed = s
        UserDefaults.standard.set(s, forKey: "animSpeed")
    }
}

/// 动画画布：线条、粒子用 Canvas；圆、方框用原生玻璃；文字在最上层。
/// 左上角可切换 2D / 3D；点按画面查看名称，拖动可推开微粒、拖动节点（数据场景），3D 下拖动旋转、双指缩放；左上角复原按钮还原视角。
struct LiveCanvas: View {
    var clock: PlaybackClock? = nil
    var surface: DragSurface? = nil
    var custom3D: (() -> AnyView)? = nil
    let draw: (inout GraphicsContext, CGSize, Double) -> Void
    @State private var buffer = GlassBuffer()
    @State private var cache = InspectCache()
    @AppStorage("anim3D") private var is3D = false
    @State private var cam = Cam3D()
    @State private var camStart: Cam3D?
    @State private var dragging: String?
    @State private var lastTranslation: CGSize = .zero
    @State private var tip: (String, CGPoint)?
    @State private var tipID = 0
    @State private var size: CGSize = .zero

    init(clock: PlaybackClock? = nil, surface: DragSurface? = nil, custom3D: (() -> AnyView)? = nil,
         draw: @escaping (inout GraphicsContext, CGSize, Double) -> Void) {
        self.clock = clock
        self.surface = surface
        self.custom3D = custom3D
        self.draw = draw
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if is3D, let custom3D {
                custom3D()
            } else if is3D {
                TimelineView(.animation) { tl in
                    let now = tl.date.timeIntervalSinceReferenceDate
                    let t = clock?.time(now) ?? now
                    // 没在拖动时，镜头缓缓摆动，让人看出纵深
                    let sway = camStart == nil ? Cam3D(yaw: cam.yaw + 0.10 * sin(now * 0.35), pitch: cam.pitch + 0.04 * sin(now * 0.27), zoom: cam.zoom) : cam
                    Canvas { ctx, size in
                        let beat = drawIn3D(draw, &ctx, size, t, cam: sway, cache: cache)
                        clock?.beat = beat
                        drawHighlight(&ctx, cache, now)
                    }
                }
            } else {
                flat
            }
            if let (text, p) = tip {
                Text(text)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .glassEffect(.regular, in: .capsule)
                    .fixedSize()
                    .position(x: min(max(p.x, 70), max(70, size.width - 70)), y: max(30, p.y - 34))
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
            }
            toggle
        }
        .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
        .contentShape(.rect)
        .gesture(dragGesture, including: (is3D && custom3D != nil) ? .subviews : .all)
        .simultaneousGesture(MagnifyGesture().onChanged { v in
            guard is3D, custom3D == nil else { return }
            if camStart == nil { camStart = cam }
            cam.zoom = min(2.2, max(0.6, (camStart?.zoom ?? 1) * v.magnification))
        }.onEnded { _ in camStart = nil })
        .simultaneousGesture(SpatialTapGesture().onEnded { v in inspect(v.location) })
    }

    /// 2D：原来的两遍绘制（线条 + 原生玻璃叠加层）
    private var flat: some View {
        TimelineView(.animation) { tl in
            let now = tl.date.timeIntervalSinceReferenceDate
            let t = clock?.time(now) ?? now
            // 叠加层显示上一批记录；画布按那一批的时刻画线条，二者严格同步
            let shownTime = buffer.time
            let shownNodes = buffer.nodes
            let shownTexts = buffer.texts
            ZStack(alignment: .topLeading) {
                Canvas { ctx, size in
                    // 1. 线条与粒子：按叠加层的时刻绘制
                    GlassBuffer.current = discard
                    draw(&ctx, size, shownTime)
                    discard.nodes.removeAll(keepingCapacity: true)
                    discard.texts.removeAll(keepingCapacity: true)
                    discard.beat = nil
                    // 2. 记录下一帧的玻璃与文字（不可见地跑一遍）
                    var scratch = ctx
                    scratch.opacity = 0
                    buffer.nodes.removeAll(keepingCapacity: true)
                    buffer.texts.removeAll(keepingCapacity: true)
                    buffer.time = t
                    buffer.beat = nil
                    GlassBuffer.current = buffer
                    draw(&scratch, size, t)
                    GlassBuffer.current = nil
                    clock?.beat = buffer.beat
                    cache.labels = buffer.texts.map { ($0.text, CGPoint(x: $0.x, y: $0.y)) }
                    cache.nodes = buffer.nodes.map { CGPoint(x: $0.x, y: $0.y) }
                    drawHighlight(&ctx, cache, now)
                }
                GlassNodesView(nodes: shownNodes)
                GlassTextsView(texts: shownTexts)
            }
        }
    }

    private var toggle: some View {
        HStack(spacing: 6) {
            Button {
                withAnimation(.snappy) { is3D.toggle() }
            } label: {
                Text(is3D ? "3D" : "2D")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .frame(minWidth: 30, minHeight: 28)
            }
            .buttonStyle(.glass)
            .accessibilityIdentifier("anim.3d")
            if cam != Cam3D() || (surface?.hasDrag ?? false) {
                Button { reset() } label: {
                    Image(systemName: "arrow.counterclockwise").font(.system(size: 12, weight: .semibold)).frame(minHeight: 28)
                }
                .buttonStyle(.glass)
                .transition(.opacity)
            }
        }
        .padding(10)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { v in
                if is3D {
                    guard custom3D == nil else { return }
                    if camStart == nil { camStart = cam }
                    let base = camStart ?? cam
                    cam.yaw = min(1.25, max(-1.25, base.yaw + Double(v.translation.width) / 180))
                    cam.pitch = min(1.0, max(-0.6, base.pitch + Double(v.translation.height) / 220))
                    return
                }
                if dragging == nil && lastTranslation == .zero {
                    dragging = surface?.hit(v.startLocation) ?? ""
                }
                if let id = dragging, !id.isEmpty {
                    surface?.drag(id, by: CGSize(width: v.translation.width - lastTranslation.width,
                                                 height: v.translation.height - lastTranslation.height))
                    lastTranslation = v.translation
                } else {
                    TouchField.point = v.location
                    lastTranslation = v.translation
                }
            }
            .onEnded { _ in
                camStart = nil
                dragging = nil
                lastTranslation = .zero
                TouchField.point = nil
            }
    }

    private func reset() {
        withAnimation(.spring(duration: 0.5)) { cam = Cam3D() }
        surface?.resetDrag()
    }

    /// 点按：找最近的文字（或节点附近的文字），在点按处冒出名称
    private func inspect(_ p: CGPoint) {
        cache.highlight = (p, Date().timeIntervalSinceReferenceDate)
        var best: (String, CGPoint, Double)?
        for (s, q) in cache.labels where s.count <= 40 {
            let d = Double(hypot(q.x - p.x, q.y - p.y))
            if d < 70 && d < (best?.2 ?? .infinity) { best = (s, q, d) }
        }
        guard let (s, q, _) = best else { return }
        tipID += 1
        let id = tipID
        withAnimation(.spring(duration: 0.3)) { tip = (s, q) }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.4))
            if id == tipID { withAnimation(.easeOut(duration: 0.3)) { tip = nil } }
        }
    }
}

private struct GlassNodesView: View {
    let nodes: [GlassNode]

    var body: some View {
        GlassEffectContainer(spacing: 2) {
            ZStack(alignment: .topLeading) {
                Color.clear
                ForEach(Array(nodes.enumerated()), id: \.offset) { _, n in
                    node(n).opacity(n.alpha).position(x: n.x, y: n.y)
                }
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func node(_ n: GlassNode) -> some View {
        switch n.kind {
        case .circle:
            Circle()
                .fill(n.color.opacity(0.10))
                .frame(width: n.w, height: n.h)
                .glassEffect(Glass.regular.tint(n.color.opacity(0.45)), in: .circle)
        case .rect(let corner):
            RoundedRectangle(cornerRadius: corner)
                .fill(n.color.opacity(0.06))
                .frame(width: n.w, height: n.h)
                .glassEffect(Glass.regular.tint(n.color.opacity(0.3)), in: .rect(cornerRadius: corner))
        }
    }
}

private struct GlassTextsView: View {
    let texts: [GlassText]

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            ForEach(Array(texts.enumerated()), id: \.offset) { _, t in
                Text(t.text)
                    .font(.system(size: t.size, weight: t.serif ? .regular : .medium, design: t.serif ? .serif : .rounded))
                    .foregroundStyle(t.color)
                    .fixedSize()
                    .position(x: t.x, y: t.y)
            }
        }
        .allowsHitTesting(false)
    }
}

/// 节拍进度点：当前拍高亮；点任意一个点跳到该拍，点箭头跳到下一拍
struct BeatDots: View {
    let beat: BeatInfo
    let current: Int
    let go: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<beat.durations.count, id: \.self) { i in
                Capsule()
                    .fill(Color.primary.opacity(i == current ? 0.9 : 0.25))
                    .frame(width: i == current ? 18 : 7, height: 7)
                    .contentShape(.rect)
                    .onTapGesture { go(i) }
            }
            Button {
                go((current + 1) % beat.durations.count)
            } label: {
                Image(systemName: "forward.end.fill").font(.system(size: 11, weight: .semibold))
            }
            .buttonStyle(.plain)
            .padding(.leading, 2)
        }
        .padding(.horizontal, 12).padding(.vertical, 9)
        .glassEffect(.regular, in: .capsule)
        .animation(.spring(duration: 0.3), value: current)
    }
}
