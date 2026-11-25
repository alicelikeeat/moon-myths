import SwiftUI

struct KAntinomy: Identifiable {
    let id: Int
    let name: String
    let thesis: String
    let antithesis: String
    let mathematical: Bool
}

let antinomies: [KAntinomy] = [
    KAntinomy(id: 0, name: "时空边界", thesis: "世界有开端与边界", antithesis: "世界在时空上无限", mathematical: true),
    KAntinomy(id: 1, name: "可分性", thesis: "存在单纯的部分", antithesis: "一切无限可分", mathematical: true),
    KAntinomy(id: 2, name: "自由", thesis: "存在自由的因果性", antithesis: "一切按自然律发生", mathematical: false),
    KAntinomy(id: 3, name: "必然存在者", thesis: "存在绝对必然者", antithesis: "没有绝对必然者", mathematical: false),
]

struct AntinomyView: View {
    @State private var index = 0

    var body: some View {
        let a = antinomies[index]
        Header(title: "二律背反",
               formula: a.mathematical ? "¬(|W| < ∞) ∧ ¬(|W| = ∞)" : "∀a∈现象: 被决定  ∧  ◇∃a∈本体: 自由",
               subtitle: a.mathematical
                   ? "数学性背反：双方都预设“世界作为全体被给予”。回溯永远在进行，全体从未完成，所以两边都错。"
                   : "力学性背反：正题适用于本体，反题适用于现象，定义域不同，所以两边可以同真。")

        Picker("背反", selection: $index.animation()) {
            ForEach(antinomies) { Text($0.name).tag($0.id) }
        }
        .pickerStyle(.segmented)

        HStack(alignment: .top, spacing: 12) {
            verdictCard("正题", a.thesis, ok: !a.mathematical)
            verdictCard("反题", a.antithesis, ok: !a.mathematical)
        }

        Stage(height: 360) {
            LiveCanvas { ctx, size, t in
                    if a.mathematical {
                        drawRegress(&ctx, size, t, divide: a.id == 1)
                    } else {
                        drawTwoDomains(&ctx, size, t)
            }
            }
        }
    }

    private func verdictCard(_ title: String, _ text: String, ok: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.caption.weight(.bold)).foregroundStyle(Moon.silver)
                Spacer()
                Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(ok ? Color.primary : Color.primary.opacity(0.35))
            }
            Text(text).font(.subheadline).foregroundStyle(Color.primary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

/// 回溯 in indefinitum：不断生成下一圈，但“全体”永远不出现
private func drawRegress(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double, divide: Bool) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h / 2 - 10
    let steps = Int(t * 1.2) % 100000

    if divide {
        // 可分性：线段被一次次二分，永远分不到“单纯部分”
        let depth = 1 + Int(fract(t / 18) * 9)
        let len = w - 60
        for d in 0..<depth {
            let pieces = 1 << d
            let y = 40 + Double(d) * 30
            for k in 0..<pieces {
                let x0 = 30 + Double(k) * len / Double(pieces)
                let x1 = x0 + len / Double(pieces) - 2
                var seg = Path()
                seg.move(to: CGPoint(x: x0, y: y))
                seg.addLine(to: CGPoint(x: max(x0 + 0.5, x1), y: y))
                strokePath(&ctx, seg, Moon.gold.opacity(1 - Double(d) * 0.09), lineWidth: 3)
            }
        }
        label(&ctx, "已二分 \(depth - 1) 次 · 单纯部分从未出现", cx, h - 26, Moon.gold, size: 13)
        return
    }

    // 时空边界：一圈圈向外扩展的世界，边界永远在退后
    for k in 0..<14 {
        let phase = fract(t * 0.18 + Double(k) / 14)
        let r = phase * max(w, h) * 0.75
        strokePath(&ctx, Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)), Moon.violet.opacity((1 - phase) * 0.7), lineWidth: 1.5)
    }
    dot(&ctx, cx, cy, 6, Moon.gold)
    label(&ctx, "此刻", cx, cy + 18, Moon.gold)
    label(&ctx, "已回溯 \(steps) 步", cx, h - 44, Color.primary, size: 14)
    label(&ctx, "|W| = ？ 序列不收敛到任何值", cx, h - 22, Moon.silver, size: 12)
}

/// 现象（因果链）与本体（自由）分属两个定义域
private func drawTwoDomains(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let mid = h * 0.55

    var divider = Path()
    divider.move(to: CGPoint(x: 16, y: mid))
    divider.addLine(to: CGPoint(x: w - 16, y: mid))
    strokePath(&ctx, divider, Color.primary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
    label(&ctx, "现象：一切都被决定（反题 ✓）", w / 2, 20, Moon.silver)
    label(&ctx, "本体：可以设想自由（正题 ✓）", w / 2, mid + 22, Moon.gold)

    // 因果链：一串按规则传递的齿轮点
    let n = 8
    let y = mid * 0.55
    for k in 0..<n {
        let x = 30 + Double(k) * (w - 60) / Double(n - 1)
        let active = Int(t * 1.2) % n == k
        dot(&ctx, x, y, active ? 11 : 7, active ? Moon.silver : Moon.silver.opacity(0.35))
        if k < n - 1 {
            var l = Path()
            l.move(to: CGPoint(x: x + 9, y: y))
            l.addLine(to: CGPoint(x: x + (w - 60) / Double(n - 1) - 9, y: y))
            strokePath(&ctx, l, Moon.silver.opacity(0.4), lineWidth: 1.5)
        }
    }

    // 自由：自发的、不在链条上的光源
    let gy = mid + (h - mid) * 0.58
    for ring in 0..<4 {
        let r = 12 + Double(ring) * 14 + 6 * sin(t * 1 + Double(ring))
        dot(&ctx, w / 2, gy, r, Moon.gold.opacity(0.18 - Double(ring) * 0.035))
    }
    dot(&ctx, w / 2, gy, 8, Moon.gold)
}
