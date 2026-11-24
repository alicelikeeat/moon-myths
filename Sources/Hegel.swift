import SwiftUI

// MARK: - 《精神现象学》

let hegelPhenParts = ["序言", "意识", "自我意识", "绝对知识"]

let hegelPhenChapters: [Chapter] = [
    Chapter(part: "序言", title: "真理是全体",
            thesis: "真理不只是实体，同样是主体；它是自我展开的全过程。",
            formula: "真理 = 全体 = 自我展开的过程",
            points: ["花蕾、花朵、果实彼此排斥，却同样必然。",
                     "单独的结果是僵死的，结果连同它的生成才是真理。",
                     "哲学要把握的是全过程，而不只是终点。"],
            body: .canvas(drawBudFlowerFruit)),
    Chapter(part: "意识", title: "感性确定性",
            thesis: "看似最丰富的知识，其实最贫乏：它只能说出普遍者。",
            formula: "“这时 = 夜晚” → “这时 = 中午” ⟹ “这时” = 普遍者",
            points: ["把“这时是夜晚”写下来，到中午它就不真了。",
                     "保持下来的是“这时”本身：一个普遍者。",
                     "语言比意谓更真实，说出来的总是普遍的东西。"],
            body: .canvas(drawSenseCertainty)),
    Chapter(part: "意识", title: "力与知性",
            thesis: "知性在现象背后设定力与规律，最终发现的是它自己。",
            formula: "力 ⇄ 力的表现 ,  超感官世界 = 现象的规律",
            points: ["知觉把物看作“一”与“许多属性”的矛盾。",
                     "知性把现象理解为力的游戏，在其后设定规律的王国。",
                     "认识对象到头来就是认识自己：意识过渡为自我意识。"],
            body: .canvas(drawForce)),
    Chapter(part: "自我意识", title: "主人与奴隶",
            thesis: "自我意识只有在另一个自我意识的承认中才成为真实的。",
            formula: "承认 : A ⇄ B",
            points: ["双方为争取承认而进行生死斗争。",
                     "怕死的一方成为奴隶，另一方成为主人。",
                     "主人依赖奴隶的劳动；奴隶在恐惧与劳动中获得独立意识。"],
            body: .canvas(drawMasterSlave)),
    Chapter(part: "自我意识", title: "斯多葛、怀疑与苦恼意识",
            thesis: "苦恼意识把本质放在彼岸，自己永远够不着它。",
            formula: "可变的我  |  不变的彼岸",
            points: ["斯多葛主义：退回思想之中的自由。",
                     "怀疑主义：否定一切，却仍依赖被否定的东西。",
                     "苦恼意识：在自身中分裂为此岸与彼岸。"],
            body: .canvas(drawUnhappy)),
    Chapter(part: "绝对知识", title: "绝对知识",
            thesis: "精神回顾自己走过的全部形态，在概念中把握自身。",
            formula: "精神 = 回到自身的圆圈",
            points: ["意识、自我意识、理性、精神、宗教，最后是绝对知识。",
                     "开端在终点被重新理解：一个圆圈的圆圈。",
                     "绝对知识不是新的内容，而是对全过程的概念把握。"],
            body: .canvas(drawSpiralOfSpirit)),
]

// MARK: - 《逻辑学》

let hegelLogicParts = ["存在论", "本质论", "概念论"]

let hegelLogicChapters: [Chapter] = [
    Chapter(part: "存在论", title: "有、无、变",
            thesis: "纯有没有任何规定，因而就是无；二者的真理是变。",
            formula: "有 ⇄ 无  ⟹  变",
            points: ["纯有是最空洞的开端。",
                     "有与无各自直接消失于对方之中。",
                     "变的结果是定在：有了规定的有。"],
            body: .canvas(drawBeingNothing)),
    Chapter(part: "存在论", title: "质、量、度",
            thesis: "量的变化越过一定界限，就引起质的飞跃。",
            formula: "量变 → 质变 （度的关节线）",
            points: ["质：与存在直接同一的规定。",
                     "量：与存在无关的规定，可增可减。",
                     "度：在关节线上，量变转为质变，例如水结冰、沸腾。"],
            body: .canvas(drawMeasure)),
    Chapter(part: "本质论", title: "本质与现象",
            thesis: "本质不藏在现象背后，本质必然显现。",
            formula: "本质 ⟶ 反思 ⟶ 现象",
            points: ["本质是存在的真理：回到自身的存在。",
                     "同一、差异、对立、矛盾：反思规定的展开。",
                     "现象就是本质的显现，二者不可分离。"],
            body: .canvas(drawEssence)),
    Chapter(part: "概念论", title: "概念与推理",
            thesis: "概念是普遍、特殊、个别的统一；一切理性的东西都是推理。",
            formula: "U — P — I",
            points: ["概念是自由的，是存在与本质的统一。",
                     "普遍、特殊、个别互相包含、互为中项。",
                     "推理是概念的完成形态。"],
            body: .canvas(drawSyllogism)),
    Chapter(part: "概念论", title: "扬弃与否定之否定",
            thesis: "扬弃同时意味着取消、保存和提高。",
            formula: "扬弃 = 否定 + 保存 + 提升",
            points: ["否定不是简单抹去，而是确定的否定。",
                     "否定之否定回到起点，却处在更高的层次。",
                     "常说的“正—反—合”并不是黑格尔本人的术语。"],
            body: .canvas(drawSublation)),
]

// MARK: - 动画

func drawBudFlowerFruit(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = beats(t, [5, 5, 6])
    let names = ["花蕾", "花朵", "果实"]
    let xs = [w * 0.2, w * 0.5, w * 0.8]
    let y = h * 0.48
    line(&ctx, xs[0], y, xs[2], y, Moon.dim, 1, dash: [4, 4])
    for i in 0..<3 {
        let active = i == ph
        let past = i < ph
        let r = active ? 24 + 10 * smooth(p / 0.4) : (past ? 14 : 10)
        let c: Color = i == 0 ? Moon.silver : (i == 1 ? Moon.violet : Moon.gold)
        dot(&ctx, xs[i], y, r, c.opacity(past ? 0.35 : 1))
        label(&ctx, names[i], xs[i], y + 52, active ? Color.primary : Moon.dim, size: 14)
        if past { label(&ctx, "被扬弃", xs[i], y - 40, Moon.dim, size: 11) }
    }
    headline(&ctx, "后一形态否定前一形态，却保存了它", size)
    caption(&ctx, "每个环节都必然：全体才是真理", size)
}

func drawSenseCertainty(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = beats(t, [6, 7, 7])
    let day = ph == 0 ? 0 : (ph == 1 ? smooth(p / 0.5) : 1)
    let sky = Path(roundedRect: CGRect(x: 20, y: 44, width: w - 40, height: h * 0.4), cornerRadius: 18)
    ctx.fill(sky, with: .linearGradient(
        Gradient(colors: [Color(red: 0.05 + 0.4 * day, green: 0.07 + 0.5 * day, blue: 0.18 + 0.6 * day),
                          Color(red: 0.1 + 0.5 * day, green: 0.1 + 0.45 * day, blue: 0.25 + 0.4 * day)]),
        startPoint: CGPoint(x: 0, y: 44), endPoint: CGPoint(x: 0, y: 44 + h * 0.4)))
    dot(&ctx, w * 0.75, 44 + h * 0.15, day > 0.5 ? 22 : 14, day > 0.5 ? Moon.gold : Moon.silver)
    label(&ctx, day > 0.5 ? "中午" : "夜晚", w * 0.25, 44 + h * 0.2, Color.primary, size: 18)

    let cy = h * 0.68
    box(&ctx, w * 0.12, cy, w * 0.76, 44, Moon.silver)
    label(&ctx, ph == 0 ? "写下：“这时是夜晚”" : (ph == 1 ? "“这时是夜晚”……已经不真了" : "留下来的是“这时”：普遍者"),
          w / 2, cy + 22, ph == 2 ? Moon.gold : Color.primary, size: 14)
    caption(&ctx, "最丰富的确定性，说出来只是最抽象的普遍", size)
}

func drawForce(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let y = h * 0.4
    let a = w * 0.28, b = w * 0.72
    let k = 0.5 - 0.5 * cos(t * 1.6)
    dot(&ctx, a, y, 22 + 6 * (1 - k), Moon.silver)
    dot(&ctx, b, y, 22 + 6 * k, Moon.violet)
    blob(&ctx, lerp(a, b, k), y - 30 * sin(Double.pi * k), 4, Color.primary)
    label(&ctx, "力", a, y + 44, Moon.silver, size: 14)
    label(&ctx, "力的表现", b, y + 44, Moon.violet, size: 14)
    label(&ctx, "现象：力的游戏", w / 2, 34, Color.primary, size: 14)
    let ly = h * 0.74
    line(&ctx, 30, ly, w - 30, ly, Moon.gold.opacity(0.6), 1, dash: [5, 5])
    label(&ctx, "超感官世界 = 规律的静止王国", w / 2, ly + 20, Moon.gold, size: 13)
    caption(&ctx, "在现象背后，知性找到的是它自己", size)
}

func drawMasterSlave(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (ph, p) = beats(t, [6, 6, 7, 7])
    let k = smooth(p / 0.5)
    var ax = w * 0.3, ay = h * 0.42, bx = w * 0.7, by = h * 0.42
    var bR = 20.0
    var aR = 20.0
    let titles = ["两个自我意识：都要求被承认", "生死斗争：怕死的一方低头", "奴隶劳动：在陶冶事物中认识自己", "颠倒：奴隶获得独立，主人陷入依赖"]
    switch ph {
    case 0:
        ax = lerp(w * 0.2, w * 0.32, k); bx = lerp(w * 0.8, w * 0.68, k)
    case 1:
        ax = w * 0.38 + 3 * sin(t * 6) * (1 - k); bx = w * 0.62
        by = lerp(h * 0.42, h * 0.62, k); bR = lerp(20, 15, k)
    case 2:
        by = h * 0.62; bR = 15
        let side = lerp(30, 60, k)
        let rough = (1 - k) * 12
        box(&ctx, w * 0.62 - side / 2 + rough, h * 0.75 - side / 4, side - rough, side / 2, Moon.gold)
        label(&ctx, "物", w * 0.62, h * 0.75, Color.primary, size: 12)
    default:
        by = lerp(h * 0.62, h * 0.32, k); bR = lerp(15, 24, k)
        ay = lerp(h * 0.42, h * 0.55, k); aR = lerp(20, 13, k)
    }
    dot(&ctx, ax, ay, aR, Moon.violet.opacity(ph == 3 ? 1 - 0.5 * k : 1))
    dot(&ctx, bx, by, bR, Moon.gold)
    label(&ctx, ph == 0 ? "自我意识 A" : "主人", ax, ay + aR + 18, Moon.violet, size: 13)
    label(&ctx, ph == 0 ? "自我意识 B" : "奴隶", bx, by + bR + 18, Moon.gold, size: 13)
    headline(&ctx, titles[ph], size)
    caption(&ctx, "承认的辩证法", size)
}

func drawUnhappy(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let y = h * 0.45
    let far = w * 0.78
    let reach = 0.5 + 0.5 * sin(t * 1.2)
    let x = lerp(w * 0.22, w * 0.5, reach)
    line(&ctx, w * 0.6, 50, w * 0.6, h - 50, Color.primary.opacity(0.25), 1, dash: [4, 6])
    dot(&ctx, far, y, 26, Moon.gold)
    dot(&ctx, x, y, 18, Moon.violet)
    label(&ctx, "可变的我（此岸）", x, y + 42, Moon.violet, size: 13)
    label(&ctx, "不变者（彼岸）", far, y + 48, Moon.gold, size: 13)
    headline(&ctx, "越想抓住彼岸，越感到分裂", size)
    caption(&ctx, "苦恼意识：自身中分裂的意识", size)
}

func drawSpiralOfSpirit(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h / 2
    let names = ["意识", "自我意识", "理性", "精神", "宗教", "绝对知识"]
    var path = Path()
    for i in 0...240 {
        let u = Double(i) / 240
        let a = u * 2 * Double.pi * 1.0 - Double.pi / 2
        let r = 40 + u * min(w, h) * 0.32
        let pt = CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r)
        if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
    }
    ctx.stroke(path, with: .color(Color.primary.opacity(0.25)), lineWidth: 1.5)
    let p = fract(t / 12)
    for (i, n) in names.enumerated() {
        let u = Double(i) / Double(names.count - 1)
        let a = u * 2 * Double.pi - Double.pi / 2
        let r = 40 + u * min(w, h) * 0.32
        let x = cx + cos(a) * r, y = cy + sin(a) * r
        let reached = p >= u
        dot(&ctx, x, y, reached ? 12 : 7, i == names.count - 1 ? Moon.gold : Moon.silver)
        label(&ctx, n, x, y + 22, reached ? Color.primary : Moon.dim, size: 12)
    }
    let a = p * 2 * Double.pi - Double.pi / 2
    let r = 40 + p * min(w, h) * 0.32
    blob(&ctx, cx + cos(a) * r, cy + sin(a) * r, 4, Color.primary)
    caption(&ctx, "终点回到起点，却已是自觉的全体", size)
}

func drawBeingNothing(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h * 0.45
    let d = abs(cos(t * 0.7)) * w * 0.28
    let spin = t * 1.2
    let ax = cx - d * cos(spin * 0.2), bx = cx + d * cos(spin * 0.2)
    dot(&ctx, ax, cy, 24, Moon.gold)
    dot(&ctx, bx, cy, 24, Moon.violet)
    if d > 40 {
        label(&ctx, "有", ax, cy + 44, Moon.gold, size: 16)
        label(&ctx, "无", bx, cy + 44, Moon.violet, size: 16)
    } else {
        label(&ctx, "变", cx, cy + 50, Color.primary, size: 18)
    }
    headline(&ctx, "有消失于无，无消失于有", size)
    caption(&ctx, "这种消失本身就是“变”", size)
}

func drawMeasure(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let temp = measureTemp(t)
    let bx = 40.0, bw = w - 80, by = h * 0.78
    box(&ctx, bx, by, bw, 12, Moon.dim)
    let fill = (temp + 20) / 140
    ctx.fill(Path(roundedRect: CGRect(x: bx, y: by, width: bw * fill, height: 12), cornerRadius: 6),
             with: .linearGradient(Gradient(colors: [Moon.silver, Moon.gold]),
                                   startPoint: CGPoint(x: bx, y: 0), endPoint: CGPoint(x: bx + bw, y: 0)))
    for (v, name) in [(0.0, "0 °C"), (100.0, "100 °C")] {
        let x = bx + bw * (v + 20) / 140
        line(&ctx, x, by - 8, x, by + 20, Moon.gold, 2)
        label(&ctx, name, x, by + 32, Moon.gold, size: 11)
    }
    label(&ctx, String(format: "%.0f °C", temp), w / 2, by - 22, Color.primary, size: 14)
    let cx = w / 2, cy = h * 0.4
    if temp < 0 {
        box(&ctx, cx - 40, cy - 40, 80, 80, Moon.silver)
        label(&ctx, "冰", cx, cy, Color.primary, size: 20)
    } else if temp < 100 {
        dot(&ctx, cx, cy, 42, Moon.silver)
        label(&ctx, "水", cx, cy, Color.primary, size: 20)
    } else {
        for i in 0..<7 {
            let s = Double(i)
            dot(&ctx, cx + sin(s * 2.1) * 50, cy + 30 - fract(t * 0.4 + s * 0.14) * 110, 8, Moon.silver)
        }
        label(&ctx, "汽", cx, cy + 60, Color.primary, size: 20)
    }
    headline(&ctx, "温度一点点升高，状态却突然改变", size)
    caption(&ctx, "度：量与质的统一", size)
}

func drawEssence(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h / 2
    let R = min(w, h) * 0.36
    ring(&ctx, cx, cy, R, Color.primary.opacity(0.3), 1, dash: [4, 5])
    for i in 0..<8 {
        let a = Double(i) / 8 * 2 * Double.pi + t * 0.15
        let f = fract(t * 0.5 + Double(i) * 0.125)
        line(&ctx, cx, cy, cx + cos(a) * R, cy + sin(a) * R, Moon.gold.opacity(0.18), 1)
        blob(&ctx, cx + cos(a) * R * f, cy + sin(a) * R * f, 3, Moon.gold)
        dot(&ctx, cx + cos(a) * R, cy + sin(a) * R, 9, Moon.silver)
    }
    dot(&ctx, cx, cy, 26, Moon.gold)
    label(&ctx, "本质", cx, cy, Color.primary, size: 14)
    label(&ctx, "现象", cx, cy - R - 22, Moon.silver, size: 13)
    caption(&ctx, "本质在显现中才是本质", size)
}

func drawSyllogism(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let pts: [(Double, Double, String, Color)] = [
        (w / 2, h * 0.2, "普遍 U", Moon.gold), (w * 0.2, h * 0.72, "特殊 P", Moon.silver), (w * 0.8, h * 0.72, "个别 I", Moon.violet),
    ]
    for i in 0..<3 {
        let a = pts[i], b = pts[(i + 1) % 3]
        line(&ctx, a.0, a.1, b.0, b.1, Color.primary.opacity(0.3), 1.5)
    }
    let f = fract(t / 6) * 3
    let i = Int(f), k = f - Double(i)
    let a = pts[i % 3], b = pts[(i + 1) % 3]
    blob(&ctx, lerp(a.0, b.0, k), lerp(a.1, b.1, k), 5, Color.primary)
    for p in pts {
        dot(&ctx, p.0, p.1, 22, p.3)
        label(&ctx, p.2, p.0, p.1 + 40, p.3, size: 13)
    }
    caption(&ctx, "三者轮流充当中项：推理的循环", size)
}

func drawSublation(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let names = ["肯定", "否定", "否定之否定"]
    var path = Path()
    for i in 0...200 {
        let u = Double(i) / 200
        let x = w / 2 + sin(u * 2 * Double.pi * 1.5) * w * 0.3
        let y = h * 0.85 - u * h * 0.68
        if i == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
    }
    ctx.stroke(path, with: .color(Color.primary.opacity(0.25)), lineWidth: 1.5)
    let p = fract(t / 9)
    for (i, n) in names.enumerated() {
        let u = Double(i) / 2
        let x = w / 2 + sin(u * 2 * Double.pi * 1.5) * w * 0.3
        let y = h * 0.85 - u * h * 0.68
        dot(&ctx, x, y, p >= u ? 16 : 9, i == 2 ? Moon.gold : Moon.silver)
        label(&ctx, n, x, y + 30, p >= u ? Color.primary : Moon.dim, size: 13)
    }
    let x = w / 2 + sin(p * 2 * Double.pi * 1.5) * w * 0.3
    blob(&ctx, x, h * 0.85 - p * h * 0.68, 4, Color.primary)
    headline(&ctx, "回到起点，却在更高处", size)
    caption(&ctx, "取消 · 保存 · 提升", size)
}

/// 度：温度随时间变化，在 0 °C 和 100 °C 两个关节点各停留 2.5 秒
func measureTemp(_ t: Double) -> Double {
    // (起点, 终点, 时长)
    let segs: [(Double, Double, Double)] = [(-20, 0, 4), (0, 0, 2.5), (0, 100, 9), (100, 100, 2.5), (100, 120, 3), (120, 120, 2)]
    var u = fract(t / segs.reduce(0) { $0 + $1.2 }) * segs.reduce(0) { $0 + $1.2 }
    for s in segs {
        if u < s.2 { return lerp(s.0, s.1, u / s.2) }
        u -= s.2
    }
    return 120
}
