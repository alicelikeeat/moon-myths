import SwiftUI

struct RegulativeView: View {
    @State private var subjective = true
    @State private var objective = false

    var body: some View {
        Header(title: "调节性理念",
               formula: "max Unity(T),  sup = 理念 ∉ 经验",
               subtitle: "理念不给对象，只给方向：知识沿“系统统一性”的梯度不断上升，却永远到不了那条虚线。")

        Stage(height: 300) {
            LiveCanvas { ctx, size, t in
                    drawAscent(&ctx, size, t)
            }
        }

        Text("意见 · 信念 · 知识")
            .font(.title3.weight(.bold))
            .foregroundStyle(Moon.gold)
        Toggle("主观上充分（我确信）", isOn: $subjective.animation())
        Toggle("客观上充分（有对象可证）", isOn: $objective.animation())

        HStack {
            Text(assent).font(.system(size: 34, weight: .bold, design: .serif))
            Spacer()
            Text(example).font(.footnote).foregroundStyle(Color.primary.opacity(0.7))
                .multilineTextAlignment(.trailing)
        }
        .padding(18)
        .foregroundStyle(Color.primary)
        .glassEffect(Glass.regular.tint(Color.primary.opacity(0.18)), in: .rect(cornerRadius: 24))
    }

    private var assent: String {
        switch (subjective, objective) {
        case (true, true): return "知识"
        case (true, false): return "信念"
        case (false, true): return "知识？"
        case (false, false): return "意见"
        }
    }

    private var example: String {
        switch (subjective, objective) {
        case (true, true): return "例：物体有广延，\n凡事皆有因"
        case (true, false): return "例：上帝、灵魂不朽\n（实践上的预设）"
        case (false, true): return "有证据却不确信：\n康德不单列此类"
        case (false, false): return "例：随口的猜测"
        }
    }
}

private func drawAscent(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let left = 30.0, right = w - 20, top = 50.0, bottom = h - 34
    let maxX = 6.0
    func px(_ x: Double) -> Double { left + x / maxX * (right - left) }
    func py(_ u: Double) -> Double { bottom - u * (bottom - top) }
    func unity(_ x: Double) -> Double { 1 - exp(-x) }

    // 渐近线 = 理念
    var asym = Path()
    asym.move(to: CGPoint(x: left, y: py(1)))
    asym.addLine(to: CGPoint(x: right, y: py(1)))
    ctx.stroke(asym, with: .color(Moon.gold.opacity(0.8)), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
    label(&ctx, "理念（虚焦点 focus imaginarius）", w / 2, py(1) - 16, Moon.gold)

    // 曲线
    var curve = Path()
    for i in 0...120 {
        let x = Double(i) / 120 * maxX
        let p = CGPoint(x: px(x), y: py(unity(x)))
        if i == 0 { curve.move(to: p) } else { curve.addLine(to: p) }
    }
    ctx.stroke(curve, with: .color(Moon.silver), lineWidth: 2)

    // 沿梯度上升的知识点
    let x = fract(t * 0.07) * maxX
    let u = unity(x)
    let grad = exp(-x)
    dot(&ctx, px(x), py(u), 14, Moon.violet.opacity(0.25))
    dot(&ctx, px(x), py(u), 6, Color.primary)
    var arrow = Path()
    arrow.move(to: CGPoint(x: px(x), y: py(u)))
    arrow.addLine(to: CGPoint(x: px(x) + 40, y: py(u) - 40 * grad * (bottom - top) / (right - left) * maxX))
    ctx.stroke(arrow, with: .color(Moon.violet), lineWidth: 2)

    label(&ctx, String(format: "统一度 %.4f  ·  距理念 %.4f", u, 1 - u), w / 2, bottom + 18, Color.primary)
    label(&ctx, "经验知识 →", left + 40, bottom - 10)
}
