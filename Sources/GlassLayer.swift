import SwiftUI

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
final class GlassBuffer {
    var nodes: [GlassNode] = []
    var texts: [GlassText] = []
    /// 这批节点对应的时刻；画布按同一时刻绘制线条，保证玻璃与线条对齐
    var time: Double = Date().timeIntervalSinceReferenceDate
    static var current: GlassBuffer?
}

/// 丢弃型缓冲：绘制线条时屏蔽玻璃元素与文字（它们由叠加层负责）
private let discard = GlassBuffer()

/// 动画画布：线条、粒子用 Canvas；圆、方框用原生玻璃；文字在最上层
struct LiveCanvas: View {
    let draw: (inout GraphicsContext, CGSize, Double) -> Void
    @State private var buffer = GlassBuffer()

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
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
                    // 2. 记录下一帧的玻璃与文字（不可见地跑一遍）
                    var scratch = ctx
                    scratch.opacity = 0
                    buffer.nodes.removeAll(keepingCapacity: true)
                    buffer.texts.removeAll(keepingCapacity: true)
                    buffer.time = t
                    GlassBuffer.current = buffer
                    draw(&scratch, size, t)
                    GlassBuffer.current = nil
                }
                GlassNodesView(nodes: shownNodes)
                GlassTextsView(texts: shownTexts)
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
