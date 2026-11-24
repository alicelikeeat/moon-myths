import SwiftUI

// MARK: - 序言：哥白尼式革命
func drawCopernicus(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h / 2
    let (ph, p) = phase(t, period: 12, count: 2)
    let k = ph == 0 ? 1 - smooth(p / 0.25) : smooth(p / 0.25)   // 0 = 旧, 1 = 新
    let r = min(w, h) * 0.34

    let ma = t * 0.7
    let mx = lerp(cx + cos(ma) * r * 0.55, cx, k)
    let my = lerp(cy + sin(ma) * r * 0.55, cy, k)

    for i in 0..<6 {
        let a = Double(i) / 6 * 2 * Double.pi + t * 0.35 * k
        let ox = cx + cos(a) * r, oy = cy + sin(a) * r
        let f = fract(t * 0.6 + Double(i) * 0.17)
        if k < 0.5 {
            line(&ctx, ox, oy, mx, my, Moon.silver.opacity(0.25))
            dot(&ctx, lerp(ox, mx, f), lerp(oy, my, f), 2.5, Moon.silver)
        } else {
            line(&ctx, mx, my, ox, oy, Moon.gold.opacity(0.25))
            dot(&ctx, lerp(mx, ox, f), lerp(my, oy, f), 2.5, Moon.gold)
        }
        dot(&ctx, ox, oy, 8, Moon.silver.opacity(0.9))
    }
    dot(&ctx, mx, my, 22 + 3 * sin(t * 3), Moon.gold.opacity(0.2))
    dot(&ctx, mx, my, 11, Moon.gold)
    label(&ctx, "认识", mx, my + 26, Moon.gold)

    headline(&ctx, k < 0.5 ? "旧：认识符合对象（认识绕着对象转）" : "新：对象符合认识（对象绕着认识转）", size,
             k < 0.5 ? Moon.silver : Moon.gold)
    caption(&ctx, "像哥白尼那样，把视角从对象移到认识主体", size)
}

// MARK: - 导论：先天综合判断
func drawJudgments(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = phase(t, period: 8, count: 2)
    let sx = w * 0.32, sy = h * 0.27, sr = 52.0
    ring(&ctx, sx, sy, sr, Moon.silver)
    label(&ctx, "C(S)", sx, sy - sr - 12, Moon.silver)
    for i in 0..<4 {
        let a = Double(i) * 1.57 + 0.4
        dot(&ctx, sx + cos(a) * 24, sy + sin(a) * 24, 4, Moon.silver.opacity(0.6))
    }
    let k = smooth(p / 0.6)
    let px: Double, py: Double
    if ph == 0 {
        px = lerp(sx + 24 * cos(0.4), w * 0.78, k); py = lerp(sy + 24 * sin(0.4), sy, k)
        headline(&ctx, "分析：P ∈ C(S)，拆开概念就得到", size, Moon.silver)
    } else {
        px = lerp(w * 0.9, sx + sr + 10, k); py = sy
        headline(&ctx, "综合：P ∉ C(S)，需要“第三者”（直观）", size, Moon.gold)
    }
    dot(&ctx, px, py, 8, ph == 0 ? Moon.silver : Moon.gold)
    label(&ctx, "P", px, py - 16, .white)

    // 2×2 矩阵
    let gx = w * 0.2, gy = h * 0.52, cw = w * 0.34, ch = 52.0
    label(&ctx, "分析", gx + cw / 2, gy - 12); label(&ctx, "综合", gx + cw * 1.5, gy - 12)
    label(&ctx, "先天", gx - 22, gy + ch / 2); label(&ctx, "后天", gx - 22, gy + ch * 1.5)
    let cells: [(Int, Int, String)] = [(0, 0, "物体有广延"), (0, 1, "7+5=12 ？"), (1, 0, "✗ 不存在"), (1, 1, "物体是重的")]
    for (r, c, s) in cells {
        let x = gx + Double(c) * cw, y = gy + Double(r) * ch
        let core = (r == 0 && c == 1)
        let glow = core ? 0.15 + 0.15 * sin(t * 3) : 0.03
        box(&ctx, x + 3, y + 3, cw - 6, ch - 6, core ? Moon.gold : Moon.dim, fill: (core ? Moon.gold : Color.white).opacity(glow))
        label(&ctx, s, x + cw / 2, y + ch / 2, core ? Moon.gold : .white.opacity(0.75))
    }
    caption(&ctx, "全书只问一件事：先天综合判断如何可能？", size)
}

// MARK: - 空间
func drawSpace(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let step = 28.0
    var x = 0.0
    while x < w { line(&ctx, x, 40, x, h - 40, Moon.silver.opacity(0.12), 1); x += step }
    var y = 40.0
    while y < h - 40 { line(&ctx, 0, y, w, y, Moon.silver.opacity(0.12), 1); y += step }

    let (ph, p) = phase(t, period: 8, count: 2)
    let a = ph == 0 ? smooth(p / 0.2) : 1 - smooth(p / 0.2)
    for i in 0..<6 {
        let s = Double(i)
        let ox = 40 + hash01(s + 2) * (w - 80) + sin(t + s) * 8
        let oy = 60 + hash01(s + 5) * (h - 140)
        dot(&ctx, ox, oy, 10 + hash01(s) * 8, Moon.violet.opacity(0.8 * a))
    }
    let rx = 20 + fract(t * 0.05) * (w - 140)
    box(&ctx, rx, h * 0.55, 100, 70, Moon.gold.opacity(0.8))
    label(&ctx, "区域 = 对唯一空间的限制", rx + 50, h * 0.55 + 84, Moon.gold, size: 11)

    headline(&ctx, ph == 0 ? "物体在空间之中" : "物体可以被抽掉，空间仍在", size, ph == 0 ? .white : Moon.gold)
    caption(&ctx, "空间：外感官的先天形式，不是物的属性", size)
}

// MARK: - 时间
func drawTime(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let ay = h * 0.6, now = w / 2
    line(&ctx, 10, ay, w - 10, ay, Moon.silver.opacity(0.6))
    for k in 0..<24 {
        let x = fract(Double(k) / 24 - t * 0.04) * w
        line(&ctx, x, ay - 4, x, ay + 4, Moon.silver.opacity(0.5), 1)
    }
    line(&ctx, now, ay - 110, now, ay + 20, Moon.gold, 2)
    label(&ctx, "现在", now, ay + 34, Moon.gold)
    let me = (now, h * 0.17)
    dot(&ctx, me.0, me.1, 9, Moon.gold)
    label(&ctx, "我（内感官）", me.0, me.1 - 18, Moon.gold)
    for i in 0..<9 {
        let s = Double(i)
        let x = fract(hash01(s) - t * 0.04) * w
        let ey = ay - 30 - hash01(s + 9) * 50
        let near = abs(x - now) < 50
        line(&ctx, x, ay, x, ey, Moon.violet.opacity(0.4), 1)
        dot(&ctx, x, ey, near ? 8 : 5, near ? Moon.gold : Moon.violet)
        if near { line(&ctx, x, ey, me.0, me.1, Moon.gold.opacity(0.35), 1) }
    }
    headline(&ctx, "表象只能在“先后”与“同时”中被给予", size)
    caption(&ctx, "时间：内感官的形式，因而是一切现象的形式", size)
}

// MARK: - 形而上学演绎
private let judgmentForms = [["全称", "特称", "单称"], ["肯定", "否定", "无限"], ["定言", "假言", "选言"], ["或然", "实然", "必然"]]

func drawMetaphysicalDeduction(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let k = smooth(0.5 + 0.7 * sin(t * 0.6))
    let gx = 56.0, gy = 54.0, cw = (w - gx - 12) / 3, ch = (h - 110) / 4
    for g in 0..<4 {
        label(&ctx, categoryGroups[g].0, 26, gy + Double(g) * ch + ch / 2, Moon.silver, size: 13)
        for j in 0..<3 {
            let x = gx + Double(j) * cw, y = gy + Double(g) * ch
            box(&ctx, x + 3, y + 3, cw - 6, ch - 6, Color.white.opacity(0.15), fill: Moon.gold.opacity(0.08 * k))
            label(&ctx, judgmentForms[g][j], x + cw / 2, y + ch / 2, Moon.silver.opacity(1 - k), size: 14)
            label(&ctx, categoryGroups[g].1[j].name, x + cw / 2, y + ch / 2, Moon.gold.opacity(k), size: 14)
        }
    }
    headline(&ctx, k < 0.5 ? "判断的 12 种逻辑功能" : "12 个纯粹知性概念（范畴）", size, k < 0.5 ? Moon.silver : Moon.gold)
    caption(&ctx, "同一功能：用于判断 = 逻辑形式，用于直观 = 范畴", size)
}

// MARK: - 先验演绎
func drawDeduction(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h / 2 - 6, r = min(w, h) * 0.42
    let n = 28
    let conn = min(n, Int(fract(t / 11) * Double(n + 8)))
    for i in 0..<n {
        let s = Double(i)
        let a = hash01(s) * 2 * Double.pi
        if i < conn {
            let aa = a + t * 0.25
            let x = cx + cos(aa) * r * 0.62, y = cy + sin(aa) * r * 0.62
            line(&ctx, cx, cy, x, y, Moon.gold.opacity(0.22), 1)
            dot(&ctx, x, y, 4, Moon.gold)
        } else {
            let rr = r * (0.82 + 0.12 * sin(t + s))
            let x = cx + cos(a + sin(t * 0.3 + s) * 0.3) * rr, y = cy + sin(a) * rr
            dot(&ctx, x, y, 3, .gray.opacity(0.6))
        }
    }
    dot(&ctx, cx, cy, 26 + 4 * sin(t * 2), Moon.gold.opacity(0.18))
    dot(&ctx, cx, cy, 14, Moon.gold)
    label(&ctx, "我思", cx, cy + 28, Moon.gold, size: 13)
    headline(&ctx, "已被统觉统一的表象 \(conn) / \(n)", size)
    caption(&ctx, "“我思”必须能伴随一切表象 → 范畴对经验对象有效", size)
}

// MARK: - 直观的公理
func drawAxioms(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let p = fract(t / 7)
    let segs = Int(p * 14)
    let unit = (w - 60) / 12
    for i in 0..<min(segs, 12) {
        let x = 30 + Double(i) * unit
        line(&ctx, x + 2, 80, x + unit - 2, 80, Moon.gold, 5)
        label(&ctx, "\(i + 1)", x + unit / 2, 98, Moon.dim, size: 10)
    }
    label(&ctx, "线段：一段一段相加", w / 2, 56, Moon.silver)

    let cells = Int(p * 42)
    let side = 26.0, ox = w / 2 - side * 3, oy = h * 0.42
    for i in 0..<36 {
        let x = ox + Double(i % 6) * side, y = oy + Double(i / 6) * side
        box(&ctx, x + 1, y + 1, side - 2, side - 2, Color.white.opacity(0.12),
            fill: i < cells ? Moon.gold.opacity(0.55) : nil)
    }
    headline(&ctx, "广延量：部分的表象先于整体", size)
    caption(&ctx, "一切直观都是广延量 → 几何学可应用于经验", size)
}

// MARK: - 知觉的预测
func drawAnticipations(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let v = 0.5 - 0.5 * cos(t * 0.8)
    let cx = w / 2, cy = h * 0.33
    for i in 0..<5 { dot(&ctx, cx, cy, 20 + Double(i) * 12, Moon.gold.opacity(v * 0.12)) }
    dot(&ctx, cx, cy, 20, Moon.gold.opacity(0.15 + 0.85 * v))
    label(&ctx, String(format: "度 = %.3f", v), cx, cy + 80, .white, size: 14)

    let by = h * 0.68, bx = 30.0, bw = w - 60
    box(&ctx, bx, by, bw, 14, Moon.dim)
    ctx.fill(Path(roundedRect: CGRect(x: bx, y: by, width: bw * v, height: 14), cornerRadius: 7), with: .color(Moon.gold))
    let depth = 1 + Int(fract(t / 9) * 7)
    let parts = 1 << depth
    for k in 0...parts {
        let x = bx + bw * Double(k) / Double(parts)
        line(&ctx, x, by + 18, x, by + 26, Moon.silver.opacity(0.6), 1)
    }
    label(&ctx, "任意两度之间总有中间度（细分 \(parts) 份）", w / 2, by + 42, Moon.silver, size: 11)
    headline(&ctx, "强度量：感觉没有广延，却有程度", size)
    caption(&ctx, "一切实在都有度，可从 0 连续增长", size)
}

// MARK: - 经验的类比
func drawAnalogies(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let (ph, _) = phase(t, period: 15, count: 3)
    drawSchema(&ctx, size, t, categoryGroups[2].1[ph])
    let names = ["第一类比：实体持存", "第二类比：因果相继", "第三类比：交互协同"]
    label(&ctx, names[ph], Double(size.width) / 2, 46, Moon.gold, size: 14)
}

// MARK: - 公设与驳斥唯心论
func drawRefutation(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = phase(t, period: 10, count: 2)
    let sx = w * 0.82, sy = h * 0.26
    let starA = ph == 0 ? 1.0 : 1 - smooth(p / 0.2)
    dot(&ctx, sx, sy, 20, Moon.silver.opacity(0.2 * starA))
    dot(&ctx, sx, sy, 9, Moon.silver.opacity(starA))
    label(&ctx, "外部持久之物", sx, sy - 22, Moon.silver.opacity(starA))
    let ay = h * 0.68
    line(&ctx, 20, ay, w - 20, ay, Moon.dim)
    let count = min(7, Int(p * 9))
    for i in 0..<count {
        let s = Double(i)
        var x = 40 + s * (w - 100) / 6
        var y = ay - 20
        if ph == 1 {
            x = 40 + hash01(s + floor(t * 2)) * (w - 80)
            y = ay - 20 - hash01(s + 3 + floor(t * 2)) * 80
        } else {
            line(&ctx, x, y, sx, sy, Moon.silver.opacity(0.18), 1)
        }
        dot(&ctx, x, y, 6, Moon.gold)
        label(&ctx, "t\(i + 1)", x, y + 16, Moon.dim, size: 10)
    }
    headline(&ctx, ph == 0 ? "以外物为参照，内在时间序列才可规定" : "去掉外物：内在表象无从排序", size,
             ph == 0 ? Moon.gold : Moon.violet)
    caption(&ctx, "外物的存在与“我”的此在同样确定", size)
}

// MARK: - 反思概念的歧义
func drawAmphiboly(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = phase(t, period: 8, count: 2)
    let k = ph == 0 ? smooth(p / 0.3) : 1 - smooth(p / 0.3)   // 1 = 合一
    let y = h * 0.45
    for x in [lerp(w * 0.28, w / 2, k), lerp(w * 0.72, w / 2, k)] {
        dot(&ctx, x, y, 30, Moon.violet.opacity(0.45))
        dot(&ctx, x - 9, y - 9, 7, .white.opacity(0.6))
    }
    if ph == 1 {
        line(&ctx, w * 0.28, y + 50, w * 0.72, y + 50, Moon.silver.opacity(0.6), 1, dash: [4, 4])
        label(&ctx, "位置 x₁ ≠ x₂", w / 2, y + 66, Moon.silver)
    }
    headline(&ctx, ph == 0 ? "只按概念比较（莱布尼茨）：完全相同 → 同一个" : "按直观（康德）：位置不同 → 两滴水", size,
             ph == 0 ? Moon.violet : Moon.gold)
    caption(&ctx, "歧义：把现象当作纯粹知性的对象来比较", size)
}
