import SwiftUI

enum SchemaKind {
    case number, degree, permanence, succession, simultaneity, modality
}

struct KCategory: Identifiable, Hashable {
    let name: String
    let group: String
    let schema: String
    let math: String
    let kind: SchemaKind
    var id: String { name }
}

let categoryGroups: [(String, [KCategory])] = [
    ("量", [
        KCategory(name: "单一性", group: "量", schema: "数：逐次加一", math: "1", kind: .number),
        KCategory(name: "复多性", group: "量", schema: "数：逐次加一", math: "n", kind: .number),
        KCategory(name: "全体性", group: "量", schema: "数：逐次加一", math: "Σ", kind: .number),
    ]),
    ("质", [
        KCategory(name: "实在性", group: "质", schema: "度：时间被充实", math: "f(t) > 0", kind: .degree),
        KCategory(name: "否定性", group: "质", schema: "度：时间空无", math: "f(t) = 0", kind: .degree),
        KCategory(name: "限制性", group: "质", schema: "度：有起有止", math: "0 < f ≤ 1", kind: .degree),
    ]),
    ("关系", [
        KCategory(name: "实体", group: "关系", schema: "时间中的持久者", math: "dQ/dt = 0", kind: .permanence),
        KCategory(name: "因果", group: "关系", schema: "按规则的相继", math: "A(t₁) → B(t₂)", kind: .succession),
        KCategory(name: "协同", group: "关系", schema: "同时并存、交互", math: "A(t) ↔ B(t)", kind: .simultaneity),
    ]),
    ("模态", [
        KCategory(name: "可能性", group: "模态", schema: "在某一时间", math: "∃t", kind: .modality),
        KCategory(name: "实存性", group: "模态", schema: "在确定时间", math: "t = t₀", kind: .modality),
        KCategory(name: "必然性", group: "模态", schema: "在一切时间", math: "∀t", kind: .modality),
    ]),
]

struct CategoriesView: View {
    @State private var selected: KCategory = categoryGroups[2].1[1]

    var body: some View {
        Header(title: "范畴与图型",
               formula: "范畴 = 4 组 × 3 ，第三项 = 前两项的综合",
               subtitle: "点一个范畴，看它在“时间”上如何被实现（图型）。")

        GlassEffectContainer(spacing: 8) {
            VStack(spacing: 8) {
                ForEach(categoryGroups, id: \.0) { group in
                    HStack(spacing: 8) {
                        Text(group.0)
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(width: 38)
                        ForEach(group.1) { c in
                            Button {
                                withAnimation(.spring(duration: 0.45, bounce: 0.25)) { selected = c }
                            } label: {
                                VStack(spacing: 2) {
                                    Text(c.name).font(.subheadline.weight(.semibold))
                                    Text(c.math).font(.caption2.monospaced()).opacity(0.7)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .glassEffect(selected == c
                                             ? Glass.regular.tint(.white.opacity(0.35)).interactive()
                                             : Glass.regular.interactive(),
                                             in: .rect(cornerRadius: 18))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }

        Text("\(selected.name) → \(selected.schema)")
            .font(.title3.weight(.semibold))
            .foregroundStyle(Moon.gold)

        Stage(height: 240) {
            TimelineView(.animation) { tl in
                Canvas { ctx, size in
                    drawSchema(&ctx, size, tl.date.timeIntervalSinceReferenceDate, selected)
                }
            }
        }
    }
}

func drawSchema(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double, _ c: KCategory) {
    let w = Double(size.width), h = Double(size.height)
    let axisY = h * 0.78
    var axis = Path()
    axis.move(to: CGPoint(x: 20, y: axisY))
    axis.addLine(to: CGPoint(x: w - 20, y: axisY))
    ctx.stroke(axis, with: .color(Moon.silver.opacity(0.5)), lineWidth: 1)
    label(&ctx, "时间 t →", w - 50, axisY + 16)
    label(&ctx, c.math, w / 2, 22, Moon.silver, size: 16)

    let span = w - 60
    switch c.kind {
    case .number:
        let count = Int(fract(t * 0.2) * 10) + 1
        for k in 0..<count {
            let x = 30 + Double(k) * span / 10
            dot(&ctx, x, axisY - 30, 9, Moon.gold)
            label(&ctx, "\(k + 1)", x, axisY - 30, .black, size: 10)
        }
        label(&ctx, "n ↦ n + 1", w / 2, h * 0.32, Moon.gold)

    case .degree:
        var p = Path()
        p.move(to: CGPoint(x: 30, y: axisY))
        for i in 0...100 {
            let x = 30 + Double(i) / 100 * span
            var f = 0.5 + 0.5 * sin(Double(i) * 0.12 - t * 2)
            if c.name == "否定性" { f = 0 }
            if c.name == "限制性" && (i < 25 || i > 75) { f = 0 }
            p.addLine(to: CGPoint(x: x, y: axisY - f * h * 0.45))
        }
        p.addLine(to: CGPoint(x: 30 + span, y: axisY))
        p.closeSubpath()
        ctx.fill(p, with: .linearGradient(Gradient(colors: [Moon.gold.opacity(0.7), Moon.violet.opacity(0.1)]),
                                          startPoint: CGPoint(x: 0, y: axisY - h * 0.45),
                                          endPoint: CGPoint(x: 0, y: axisY)))

    case .permanence:
        let y = axisY - 50
        var line = Path()
        line.move(to: CGPoint(x: 30, y: y))
        line.addLine(to: CGPoint(x: 30 + span, y: y))
        ctx.stroke(line, with: .color(Moon.gold), lineWidth: 4)
        label(&ctx, "实体（持久）", 70, y - 18, Moon.gold)
        for k in 0..<6 {
            let x = 30 + fract(Double(k) / 6 + t * 0.08) * span
            let hue = fract(Double(k) * 0.17 + t * 0.1)
            dot(&ctx, x, y, 7, Color(hue: hue, saturation: 0.6, brightness: 1))
        }
        label(&ctx, "偶性在变，实体不变", w / 2, axisY - 95)

    case .succession:
        let phase = fract(t * 0.35)
        let ax = 60.0, bx = w - 80, y = axisY - 50
        dot(&ctx, ax, y, phase < 0.4 ? 14 : 9, Moon.gold.opacity(phase < 0.4 ? 1 : 0.4))
        dot(&ctx, bx, y, phase > 0.6 ? 14 : 9, Moon.violet.opacity(phase > 0.6 ? 1 : 0.4))
        label(&ctx, "A (t₁)", ax, y + 26, Moon.gold)
        label(&ctx, "B (t₂)", bx, y + 26, Moon.violet)
        let head = ax + (bx - ax) * min(1, max(0, (phase - 0.3) / 0.4))
        var arrow = Path()
        arrow.move(to: CGPoint(x: ax + 16, y: y))
        arrow.addLine(to: CGPoint(x: max(ax + 16, head - 14), y: y))
        ctx.stroke(arrow, with: .color(.white.opacity(0.8)), lineWidth: 2)
        label(&ctx, "不可逆：t₁ < t₂", w / 2, h * 0.3)

    case .simultaneity:
        let x = w / 2 + sin(t * 0.8) * span * 0.35
        let y1 = axisY - 110, y2 = axisY - 40
        let r = 10 + 3 * sin(t * 5)
        dot(&ctx, x, y1, r, Moon.gold)
        dot(&ctx, x, y2, r, Moon.violet)
        var link = Path()
        link.move(to: CGPoint(x: x, y: y1 + 12))
        link.addLine(to: CGPoint(x: x, y: y2 - 12))
        ctx.stroke(link, with: .color(.white.opacity(0.7)), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
        var tick = Path()
        tick.move(to: CGPoint(x: x, y: axisY - 6))
        tick.addLine(to: CGPoint(x: x, y: axisY + 6))
        ctx.stroke(tick, with: .color(Moon.silver), lineWidth: 2)
        label(&ctx, "A ↔ B", x + 34, (y1 + y2) / 2, .white)

    case .modality:
        let rows: [(String, Double)] = [("∃t", axisY - 120), ("t = t₀", axisY - 75), ("∀t", axisY - 30)]
        for (name, y) in rows {
            let active = (name == c.math)
            let col = active ? Moon.gold : Moon.dim
            label(&ctx, name, 36, y, col)
            switch name {
            case "∃t":
                let x = 70 + hash01(floor(t * 0.7)) * (span - 50)
                dot(&ctx, x, y, 6, col)
            case "t = t₀":
                dot(&ctx, 70 + (span - 50) * 0.55, y, 6, col)
            default:
                var l = Path()
                l.move(to: CGPoint(x: 70, y: y))
                l.addLine(to: CGPoint(x: 20 + span, y: y))
                ctx.stroke(l, with: .color(col), lineWidth: 3)
            }
        }
    }
}
