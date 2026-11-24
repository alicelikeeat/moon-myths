import SwiftUI
import Observation

/// 动画里用原生 Liquid Glass 呈现的元素
struct GlassNode {
    enum Kind { case circle, rect(corner: Double) }
    let kind: Kind
    let x: Double, y: Double      // 中心
    let w: Double, h: Double
    let color: Color
}

/// 叠在玻璃之上的文字
struct GlassText {
    let text: String
    let x: Double, y: Double
    let color: Color
    let size: Double
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

/// 动画画布：线条、粒子用 Canvas；圆、方框用原生玻璃；文字在最上层
struct LiveCanvas: View {
    var clock: PlaybackClock? = nil
    let draw: (inout GraphicsContext, CGSize, Double) -> Void
    @State private var buffer = GlassBuffer()

    init(clock: PlaybackClock? = nil, draw: @escaping (inout GraphicsContext, CGSize, Double) -> Void) {
        self.clock = clock
        self.draw = draw
    }

    var body: some View {
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
                }
                GlassNodesView(nodes: shownNodes)
                GlassTextsView(texts: shownTexts)
            }
            .overlay(alignment: .topLeading) {
                if let clock, let beat = buffer.beat, beat.durations.count > 1 {
                    BeatDots(beat: beat, current: beat.index(at: t)) { i in
                        clock.jump(to: beat.start(of: i))
                    }
                    .padding(12)
                }
            }
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
                    node(n).position(x: n.x, y: n.y)
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
                    .font(.system(size: t.size, weight: .medium, design: .rounded))
                    .foregroundStyle(t.color)
                    .fixedSize()
                    .position(x: t.x, y: t.y)
            }
        }
        .allowsHitTesting(false)
    }
}

/// 节拍进度点：当前拍高亮；点任意一个点跳到该拍，点箭头跳到下一拍
private struct BeatDots: View {
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
        .glassEffect(Glass.regular.interactive(), in: .capsule)
        .animation(.spring(duration: 0.3), value: current)
    }
}
