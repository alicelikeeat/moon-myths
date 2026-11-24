import SwiftUI

// MARK: - 先验幻相：地平线上的月亮
func drawIllusion(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let horizon = h * 0.74
    var hills = Path()
    hills.move(to: CGPoint(x: 0, y: horizon))
    for i in 0...40 {
        let x = Double(i) / 40 * w
        hills.addLine(to: CGPoint(x: x, y: horizon - 10 - 8 * sin(Double(i) * 0.7)))
    }
    hills.addLine(to: CGPoint(x: w, y: h))
    hills.addLine(to: CGPoint(x: 0, y: h))
    hills.closeSubpath()

    let p = smooth(fract(t / 10) * 1.2)
    let my = lerp(horizon - 40, h * 0.2, p)
    let mx = lerp(w * 0.35, w * 0.55, p)
    let seen = lerp(52, 24, p)
    let halo = seen * 2.6
    ctx.fill(Path(ellipseIn: CGRect(x: mx - halo, y: my - halo, width: halo * 2, height: halo * 2)),
             with: .radialGradient(Gradient(colors: [Moon.gold.opacity(0.28), Moon.gold.opacity(0)]),
                                   center: CGPoint(x: mx, y: my), startRadius: seen * 0.9, endRadius: halo))
    ctx.fill(Path(ellipseIn: CGRect(x: mx - seen, y: my - seen, width: seen * 2, height: seen * 2)),
             with: .radialGradient(Gradient(colors: [.white, Moon.gold, Moon.gold.opacity(0.85)]),
                                   center: CGPoint(x: mx - seen * 0.3, y: my - seen * 0.3),
                                   startRadius: 0, endRadius: seen * 1.3))
    ctx.fill(hills, with: .color(Color(red: 0.05, green: 0.05, blue: 0.12)))

    ring(&ctx, w * 0.84, h * 0.3, 24, Moon.silver, 1, dash: [3, 3])
    label(&ctx, "实际视角大小", w * 0.84, h * 0.3 + 36, Moon.silver, size: 11)
    label(&ctx, "（始终不变）", w * 0.84, h * 0.3 + 52, Moon.dim, size: 11)
    headline(&ctx, "明知是错觉，月亮在地平线上依然显得更大", size)
    caption(&ctx, "先验幻相：批判能识破它，却不能消除它", size)
}

// MARK: - 理念：条件的上溯
func drawIdeas(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let n = 1 + Int(fract(t / 9) * 10)
    let stepW = (w - 90) / 10, stepH = 24.0
    for i in 0..<n {
        let x = 30 + Double(i) * stepW, y = h * 0.82 - Double(i) * stepH
        box(&ctx, x, y, stepW - 4, 18, Moon.silver.opacity(0.6), fill: Moon.silver.opacity(0.12))
    }
    label(&ctx, "有条件者", 60, h * 0.82 + 30, Moon.silver, size: 11)
    let lx = 30 + Double(n) * stepW + 20
    let ly = h * 0.82 - Double(n) * stepH - 40
    for i in 0..<4 { dot(&ctx, lx, ly, 10 + Double(i) * 9, Moon.gold.opacity(0.14)) }
    dot(&ctx, lx, ly, 8, Moon.gold)
    label(&ctx, "无条件者", lx - 10, ly - 26, Moon.gold, size: 12)
    headline(&ctx, "灵魂 · 世界 · 上帝", size, Moon.gold)
    caption(&ctx, "每多走一步，无条件者就再退一步", size)
}

// MARK: - 谬误推理
func drawParalogism(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, _) = phase(t, period: 9, count: 3)
    let ys = [h * 0.22, h * 0.42, h * 0.64]
    label(&ctx, "大前提：只能作为【主体】者 = 实体", w / 2, ys[0], .white, size: 14)
    label(&ctx, "小前提：我（思维者）只能作为【主体】", w / 2, ys[1], .white, size: 14)
    label(&ctx, "结论：所以我是实体", w / 2, ys[2], ph == 2 ? Color.red.opacity(0.8) : .white, size: 15)

    let ax = w * 0.62, bx = w * 0.66
    switch ph {
    case 0:
        line(&ctx, ax, ys[0] + 10, bx, ys[1] - 10, Moon.gold, 2)
        label(&ctx, "中项相同？", w * 0.85, (ys[0] + ys[1]) / 2, Moon.gold, size: 12)
    default:
        line(&ctx, ax, ys[0] + 10, ax + 6, (ys[0] + ys[1]) / 2 - 4, Moon.silver, 2)
        line(&ctx, bx - 6, (ys[0] + ys[1]) / 2 + 4, bx, ys[1] - 10, Moon.violet, 2)
        label(&ctx, "实在主体（直观中持久）", w * 0.3, ys[0] + 22, Moon.silver, size: 11)
        label(&ctx, "逻辑主体（我思）", w * 0.3, ys[1] + 22, Moon.violet, size: 11)
    }
    if ph == 2 { line(&ctx, w * 0.25, ys[2], w * 0.75, ys[2], .red, 2) }
    caption(&ctx, ph == 2 ? "四名词错误：结论无效" : "理性心理学的推理", size)
}

// MARK: - 纯粹理性的理想
func drawIdeal(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = phase(t, period: 12, count: 2)
    if ph == 0 {
        for (x, title) in [(w * 0.3, "可能的 100 塔勒"), (w * 0.7, "现实的 100 塔勒")] {
            for i in 0..<10 {
                let y = h * 0.7 - Double(i) * 10
                let rect = CGRect(x: x - 34, y: y - 6, width: 68, height: 14)
                ctx.fill(Path(ellipseIn: rect), with: .color(Moon.gold.opacity(0.85)))
                ctx.stroke(Path(ellipseIn: rect), with: .color(Color.black.opacity(0.3)), lineWidth: 1)
            }
            label(&ctx, title, x, h * 0.7 + 28, .white, size: 12)
        }
        let ty = lerp(50, h * 0.7 - 120, smooth(p / 0.5))
        box(&ctx, w * 0.7 - 34, ty, 68, 24, Moon.violet, fill: Moon.violet.opacity(0.3))
        label(&ctx, "+ 存在", w * 0.7, ty + 12, .white, size: 12)
        if p > 0.55 { label(&ctx, "概念内容：完全相同", w / 2, h * 0.3, Moon.gold, size: 14) }
        caption(&ctx, "“存在”不是实在谓词：不给概念增加任何东西", size)
    } else {
        let names = ["自然神学证明", "宇宙论证明", "本体论证明"]
        let crack = p > 0.3
        let fall = max(0, p - 0.5) * 2
        for i in 0..<3 {
            let y = h * 0.18 + Double(i) * 76 + fall * fall * Double(3 - i) * 60
            let isRoot = i == 2
            let col: Color = isRoot && crack ? .red : Moon.silver
            box(&ctx, w / 2 - 80, y, 160, 40, col.opacity(1 - fall * 0.7), fill: col.opacity(0.12))
            label(&ctx, names[i], w / 2, y + 20, .white.opacity(1 - fall * 0.7), size: 13)
            if i < 2 { line(&ctx, w / 2, y + 42, w / 2, y + 74, Moon.dim, 1, dash: [3, 3]) }
        }
        if crack { label(&ctx, "✗", w / 2 + 96, h * 0.18 + 172, .red, size: 20) }
        caption(&ctx, "前两种证明都暗中依赖本体论证明", size)
    }
}

// MARK: - 方法论：训练
func drawDiscipline(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let p = fract(t / 7)
    let k = smooth(p / 0.6)
    line(&ctx, w / 2, 50, w / 2, h - 50, Moon.dim, 1, dash: [4, 4])

    var tri = Path()
    tri.move(to: CGPoint(x: w * 0.25, y: h * 0.25))
    tri.addLine(to: CGPoint(x: w * 0.42, y: h * 0.65))
    tri.addLine(to: CGPoint(x: w * 0.08, y: h * 0.65))
    tri.closeSubpath()
    ctx.stroke(tri.trimmedPath(from: 0, to: k), with: .color(Moon.gold), lineWidth: 2.5)
    if p > 0.65 { label(&ctx, "内角和 = 180°", w * 0.25, h * 0.73, Moon.gold, size: 12) }
    label(&ctx, "数学：在直观中构造", w * 0.25, 46, Moon.gold, size: 13)

    let cx = w * 0.75, cy = h * 0.45
    ring(&ctx, cx, cy, 34 * (1 - k * 0.5), Moon.violet.opacity(1 - k * 0.6))
    for i in 0..<4 {
        let a = Double(i) * Double.pi / 2 + 0.6
        dot(&ctx, cx + cos(a) * (12 + 50 * k), cy + sin(a) * (12 + 50 * k), 5, Moon.violet)
    }
    label(&ctx, "哲学：只能分析概念", w * 0.75, 46, Moon.violet, size: 13)
    caption(&ctx, "哲学不要模仿数学的定义、公理与证明", size)
}

// MARK: - 法规
func drawCanon(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let qs: [(String, Color)] = [("我能知道什么？", Moon.silver), ("我应当做什么？", Moon.gold), ("我可以希望什么？", Moon.violet)]
    let shown = Int(fract(t / 9) * 4.5)
    for (i, q) in qs.enumerated() where i < shown {
        label(&ctx, q.0, w / 2, 56 + Double(i) * 40, q.1, size: 17)
    }
    let states: [(String, Double, Double)] = [("意见", 0.2, 0.1), ("信念", 1, 0.15), ("知识", 1, 1)]
    let s = states[Int(t / 3) % 3]
    let by = h * 0.6
    for (j, name) in ["主观充分", "客观充分"].enumerated() {
        let y = by + Double(j) * 30
        label(&ctx, name, 50, y + 6, Moon.dim, size: 11)
        box(&ctx, 90, y, w - 200, 12, Moon.dim)
        let v = j == 0 ? s.1 : s.2
        ctx.fill(Path(roundedRect: CGRect(x: 90, y: y, width: (w - 200) * v, height: 12), cornerRadius: 6),
                 with: .color(Moon.gold))
    }
    label(&ctx, s.0, w - 55, by + 20, Moon.gold, size: 22)
    caption(&ctx, "扬弃知识，为信仰留出位置", size)
}

// MARK: - 建筑术
func drawArchitectonic(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = phase(t, period: 9, count: 2)
    let k = ph == 0 ? smooth(p / 0.4) : 1 - smooth(p / 0.4)
    var tree: [(Double, Double)] = [(w / 2, 60)]
    for i in 0..<3 { tree.append((w * (0.2 + 0.3 * Double(i)), h * 0.4)) }
    for i in 0..<9 { tree.append((w * (0.08 + 0.105 * Double(i)), h * 0.7)) }
    var pos: [(Double, Double)] = []
    for i in 0..<tree.count {
        let s = Double(i)
        let hx = 30 + hash01(s + 1) * (w - 60), hy = 60 + hash01(s + 7) * (h - 140)
        pos.append((lerp(hx, tree[i].0, k), lerp(hy, tree[i].1, k)))
    }
    for i in 1..<tree.count {
        let parent = i <= 3 ? 0 : 1 + (i - 4) / 3
        line(&ctx, pos[parent].0, pos[parent].1, pos[i].0, pos[i].1, Moon.gold.opacity(0.5 * k))
    }
    for (i, q) in pos.enumerated() { dot(&ctx, q.0, q.1, i == 0 ? 10 : 6, i == 0 ? Moon.gold : Moon.silver) }
    headline(&ctx, k < 0.5 ? "堆积：知识的拼凑" : "系统：按一个理念有机生长", size, k < 0.5 ? Moon.dim : Moon.gold)
    caption(&ctx, "建筑术：知识应是有机整体，而非杂凑", size)
}

// MARK: - 历史
func drawHistory(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let p = fract(t / 10)
    let angle = 0.9 * exp(-3 * p) * cos(2 * Double.pi * 3 * p)
    let px = w / 2, py = 40.0, len = h * 0.6
    let bx = px + sin(angle) * len, by = py + cos(angle) * len
    line(&ctx, px, py, bx, by, Moon.silver, 2)
    dot(&ctx, px, py, 4, Moon.silver)
    dot(&ctx, bx, by, 16, Moon.gold)
    let left = px + sin(-0.9) * len, right = px + sin(0.9) * len, base = py + cos(0.9) * len + 34
    label(&ctx, "独断论", left, base, angle < -0.4 ? Moon.gold : Moon.dim, size: 14)
    label(&ctx, "怀疑论", right, base, angle > 0.4 ? Moon.gold : Moon.dim, size: 14)
    label(&ctx, "批判", px, py + len + 36, abs(angle) < 0.12 && p > 0.5 ? Moon.gold : Moon.dim, size: 16)
    caption(&ctx, "理性在两极间摆动，最终停在批判", size)
}
