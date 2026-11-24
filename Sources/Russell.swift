import SwiftUI

// MARK: - 《论指称》

let russellDenotingChapters: [Chapter] = [
    Chapter(part: "摹状词理论", title: "当今法国国王是秃子",
            thesis: "限定摹状词不是名字，而是一个量化结构；没有国王时，这句话为假。",
            formula: "∃x( Kx ∧ ∀y(Ky → y = x) ∧ Bx )",
            points: ["句子拆成三部分：有一个法国国王、只有一个、他是秃子。",
                     "第一部分为假，所以整句为假，而不是“无意义”。",
                     "否定句“当今法国国王不是秃子”有两种辖域读法，排中律得以保全。"],
            body: .canvas(drawFrenchKing)),
    Chapter(part: "摹状词理论", title: "司各特与《威弗利》的作者",
            thesis: "“司各特是《威弗利》的作者”有信息量，因为摹状词不是另一个名字。",
            formula: "s = ιx(Wx)   ≠   s = s",
            points: ["乔治四世想知道司各特是否是《威弗利》的作者，",
                     "他并不是想知道司各特是否是司各特。",
                     "把摹状词分析掉之后，替换难题就消失了。"],
            body: .canvas(drawWaverley)),
]

// MARK: - 《数学原理》

let russellPMChapters: [Chapter] = [
    Chapter(part: "悖论与类型", title: "罗素悖论",
            thesis: "“所有不属于自身的集合”构成的集合，既属于又不属于自身。",
            formula: "R = { x | x ∉ x }  ⟹  R ∈ R ⇔ R ∉ R",
            points: ["朴素集合论允许用任意性质定义集合。",
                     "这一条就足以推出矛盾，动摇了弗雷格的体系。",
                     "理发师悖论是它的通俗版本。"],
            body: .canvas(drawRussellParadox)),
    Chapter(part: "悖论与类型", title: "类型论",
            thesis: "对象分层：集合只能包含低一层类型的元素。",
            formula: "x⁰ ∈ y¹ ∈ z² ∈ …   （x ∈ x 不合语法）",
            points: ["个体是第 0 型，个体的集合是第 1 型，依此类推。",
                     "“x ∈ x”根本写不出来，悖论无法表述。",
                     "代价是体系变得繁复，后来需要“可化归公理”。"],
            body: .canvas(drawTypes)),
    Chapter(part: "逻辑主义", title: "1 + 1 = 2",
            thesis: "数学可以从纯逻辑推出：数是类的类。",
            formula: "α ∈ 1 ∧ β ∈ 1 ∧ α ∩ β = ∅  →  α ∪ β ∈ 2   （*54.43）",
            points: ["2 被定义为所有恰好含两个元素的类所组成的类。",
                     "两个不相交的单元类之并，是一个二元类。",
                     "这个结论在第一卷中经过数百页准备才得到证明。"],
            body: .canvas(drawOnePlusOne)),
]

// MARK: - 《哲学问题》

let russellProblemsChapters: [Chapter] = [
    Chapter(part: "现象与实在", title: "桌子",
            thesis: "我们直接知道的是感觉材料，而不是桌子本身。",
            formula: "感觉材料 ≠ 物理对象",
            points: ["换一个角度，桌子的颜色和形状就不同。",
                     "没有哪一个颜色有特权成为“真正的”颜色。",
                     "物理对象是对感觉材料最简单的解释。"],
            body: .canvas(drawTable)),
    Chapter(part: "知识的种类", title: "亲知与描述",
            thesis: "我们能理解的每个命题，都必须完全由亲知的成分组成。",
            formula: "描述的知识  ⟶  还原为亲知",
            points: ["亲知：直接意识到，不经推论，例如感觉材料、记忆、共相。",
                     "描述：通过“某某”来知道对象，例如俾斯麦、他人的心灵。",
                     "专名往往是伪装起来的摹状词。"],
            body: .canvas(drawAcquaintance)),
    Chapter(part: "归纳", title: "归纳问题",
            thesis: "过去一再发生，并不能保证未来也会发生。",
            formula: "过去 n 次如此  ⇏  第 n + 1 次必然如此",
            points: ["每天被喂食的鸡，以为明天也会被喂。",
                     "过去的一致只能让未来的一致更“可能”。",
                     "归纳原则本身既不能由经验证明，也不能被经验否证。"],
            body: .canvas(drawInduction)),
]

// MARK: - 动画

func drawFrenchKing(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = beats(t, [6, 9])
    let clauses = ["∃x Kx", "唯一", "Bx 秃"]
    let bw = (w - 60) / 3
    for (i, c) in clauses.enumerated() {
        let x = 20 + Double(i) * (bw + 10)
        let failed = ph == 1 && i == 0 && p > 0.75
        box(&ctx, x, 50, bw, 44, failed ? .red : Moon.silver, fill: failed ? Color.red.opacity(0.25) : nil)
        label(&ctx, c, x + bw / 2, 72, failed ? .red : Color.primary, size: 14)
    }
    label(&ctx, "存在 ∧ 唯一 ∧ 秃", w / 2, 116, Moon.dim, size: 12)
    let people = ["总统", "教师", "画家", "厨师", "学生", "诗人"]
    for (i, name) in people.enumerated() {
        let x = 40 + Double(i % 3) * (w - 80) / 2
        let y = h * 0.48 + Double(i / 3) * 80
        dot(&ctx, x, y, 16, Moon.violet)
        label(&ctx, name, x, y + 30, Moon.dim, size: 11)
    }
    if ph == 1 {
        let scan = min(1, p / 0.7) * 6
        let i = min(5, Int(scan))
        let x = 40 + Double(i % 3) * (w - 80) / 2
        let y = h * 0.48 + Double(i / 3) * 80
        ring(&ctx, x, y, 24, Moon.gold, 2)
        label(&ctx, "是法国国王？否", x, y - 30, Moon.gold, size: 11)
    }
    caption(&ctx, ph == 0 ? "把句子改写为量化式" : (p > 0.75 ? "找不到满足 K 的 x：整句为假" : "在论域里逐一寻找……"), size)
}

func drawWaverley(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let k = smooth(0.5 + 0.6 * sin(t * 0.6))
    let cx = w / 2, cy = h * 0.5
    dot(&ctx, cx, cy, 26, Moon.gold)
    label(&ctx, "同一个人", cx, cy + 46, Moon.gold, size: 12)
    let lx = lerp(w * 0.18, cx - 60, k), rx = lerp(w * 0.82, cx + 60, k)
    label(&ctx, "司各特", lx, cy - 60, Color.primary, size: 15)
    label(&ctx, "《威弗利》的作者", rx, cy - 90, Moon.silver, size: 15)
    line(&ctx, lx, cy - 48, cx, cy - 28, Color.primary.opacity(0.4), 1)
    line(&ctx, rx, cy - 78, cx, cy - 28, Moon.silver.opacity(0.4), 1, dash: [4, 4])
    label(&ctx, "名字：直接指称", w * 0.25, h * 0.8, Color.primary.opacity(0.7), size: 12)
    label(&ctx, "摹状词：∃x(Wx ∧ 唯一 …)", w * 0.68, h * 0.8, Moon.silver, size: 12)
    caption(&ctx, "所以这句话告诉了我们新东西", size)
}

func drawRussellParadox(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h * 0.48
    let speed = 0.4
    let inside = sin(t * speed * 2) > 0
    let k = 0.5 + 0.5 * sin(t * speed * 2)
    dot(&ctx, cx, cy, 70, Moon.violet)
    label(&ctx, "R", cx - 50, cy - 50, Color.primary, size: 18)
    let tx = lerp(cx + 120, cx, k)
    dot(&ctx, min(tx, w - 30), cy, 14, Moon.gold)
    label(&ctx, "R 自己", min(tx, w - 30), cy + 30, Moon.gold, size: 12)
    headline(&ctx, inside ? "R ∈ R ？那它就属于自身，不该在里面" : "R ∉ R ？那它不属于自身，就该在里面", size,
             inside ? Moon.violet : Moon.gold)
    caption(&ctx, "来回翻转，永远停不下来", size)
}

func drawTypes(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let names = ["类型 0：个体", "类型 1：个体的集合", "类型 2：集合的集合", "类型 3 …"]
    let lh = (h - 90) / 4
    for i in 0..<4 {
        let y = h - 50 - Double(i + 1) * lh
        box(&ctx, 20, y + 6, w - 40, lh - 12, Moon.silver)
        label(&ctx, names[i], 90, y + 20, Color.primary.opacity(0.8), size: 11)
        for j in 0..<3 {
            let x = w * 0.45 + Double(j) * 50
            blob(&ctx, x, y + lh / 2 + 6, 5, i == 0 ? Moon.silver : Moon.gold)
        }
    }
    let f = fract(t / 6) * 3
    let lvl = Int(f)
    let k = f - Double(lvl)
    let y0 = h - 50 - Double(lvl + 1) * lh + lh / 2 + 6
    let y1 = y0 - lh
    blob(&ctx, w * 0.45 + 50, lerp(y0, y1, k), 4, Color.primary)
    line(&ctx, w * 0.45 + 50, y0, w * 0.45 + 50, y1, Color.primary.opacity(0.4), 1)
    label(&ctx, "∈ 只能向上一层", w * 0.82, y0 - lh / 2, Moon.gold, size: 11)
    label(&ctx, "x ∈ x  ✗", w * 0.82, h - 50 - lh / 2 + 6, .red.opacity(0.8), size: 12)
    caption(&ctx, "同层之间无法谈论“属于”", size)
}

func drawOnePlusOne(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = beats(t, [6, 5])
    let k = ph == 0 ? smooth(p / 0.7) : 1 - smooth(p / 0.3)
    let cy = h * 0.45
    let ax = lerp(w * 0.25, w / 2 - 20, k), bx = lerp(w * 0.75, w / 2 + 20, k)
    dot(&ctx, ax, cy, 36, Moon.silver)
    dot(&ctx, bx, cy, 36, Moon.violet)
    blob(&ctx, ax, cy, 5, Color.primary)
    blob(&ctx, bx, cy, 5, Color.primary)
    if k < 0.6 {
        label(&ctx, "α ∈ 1", ax, cy + 56, Moon.silver, size: 13)
        label(&ctx, "β ∈ 1", bx, cy + 56, Moon.violet, size: 13)
        label(&ctx, "α ∩ β = ∅", w / 2, cy - 70, Color.primary.opacity(0.8), size: 13)
    } else {
        label(&ctx, "α ∪ β ∈ 2", w / 2, cy + 62, Moon.gold, size: 15)
    }
    caption(&ctx, "数是类的类", size)
}

func drawTable(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let a = t * 0.5
    let ex = w / 2 + cos(a) * w * 0.38, ey = h * 0.5 + sin(a) * h * 0.32
    let light = 0.5 + 0.5 * cos(a - 0.8)
    let tw = w * 0.36, th = h * 0.2
    let rect = Path(roundedRect: CGRect(x: w / 2 - tw / 2, y: h * 0.5 - th / 2, width: tw, height: th), cornerRadius: 10)
    ctx.fill(rect, with: .color(Color(red: 0.35 + 0.45 * light, green: 0.22 + 0.3 * light, blue: 0.12 + 0.2 * light)))
    line(&ctx, ex, ey, w / 2, h * 0.5, Color.primary.opacity(0.3), 1, dash: [4, 4])
    dot(&ctx, ex, ey, 14, Moon.silver)
    label(&ctx, "眼睛", ex, ey + 26, Moon.silver, size: 11)
    label(&ctx, light > 0.66 ? "看起来：发亮" : (light > 0.33 ? "看起来：棕色" : "看起来：暗"), w / 2, h * 0.5 + th / 2 + 22, Color.primary, size: 13)
    headline(&ctx, "同一张桌子，每个角度颜色都不同", size)
    caption(&ctx, "哪一个才是“真正的”颜色？", size)
}

func drawAcquaintance(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h / 2
    let R = min(w, h) * 0.4, r = R * 0.42
    ring(&ctx, cx, cy, R, Moon.violet.opacity(0.5), 1, dash: [5, 5])
    let inner = ["感觉材料", "记忆", "共相"]
    let outer = ["俾斯麦", "他人心灵", "物质"]
    for (i, n) in outer.enumerated() {
        let a = Double(i) / 3 * 2 * Double.pi + t * 0.1
        let x = cx + cos(a) * R * 0.8, y = cy + sin(a) * R * 0.8
        let ia = a + 0.3
        let ix = cx + cos(ia) * r * 0.55, iy = cy + sin(ia) * r * 0.55
        line(&ctx, x, y, ix, iy, Moon.violet.opacity(0.35), 1, dash: [3, 4])
        dot(&ctx, x, y, 10, Moon.violet)
        label(&ctx, n, x, y + 22, Moon.violet, size: 11)
    }
    dot(&ctx, cx, cy, r, Moon.gold)
    for (i, n) in inner.enumerated() {
        label(&ctx, n, cx, cy - 18 + Double(i) * 18, Color.primary, size: 11)
    }
    label(&ctx, "亲知", cx, cy - r - 14, Moon.gold, size: 13)
    label(&ctx, "描述", cx, cy - R - 12, Moon.violet, size: 13)
    caption(&ctx, "外圈的知识都要通过内圈来理解", size)
}

func drawInduction(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let total = 20
    let n = min(total, Int(fract(t / 28) * Double(total + 6)))
    let cols = 5
    let cw = (w - 60) / Double(cols)
    for i in 0..<min(n, total - 1) {
        let x = 30 + cw * (Double(i % cols) + 0.5)
        let y = 70 + Double(i / cols) * 52
        dot(&ctx, x, y, 14, Moon.silver)
        label(&ctx, "✓", x, y, Color.primary, size: 12)
    }
    if n >= total {
        let i = total - 1
        let x = 30 + cw * (Double(i % cols) + 0.5)
        let y = 70 + Double(i / cols) * 52
        dot(&ctx, x, y, 14, Moon.gold)
        label(&ctx, "?", x, y, Color.primary, size: 14)
    }
    headline(&ctx, "第 \(min(n, total)) 天：今天也被喂食了", size)
    caption(&ctx, "养鸡人每天都来……直到有一天不是来喂食的", size)
}
