import SwiftUI

// MARK: - 亚里士多德、阿奎那、莱布尼茨、维特根斯坦

let westernWorkChapters2: [String: [Chapter]] = [
    "nicomachean": [
        Chapter(part: "核心观点", title: "中道",
                thesis: "德性是一种中道：在过度与不及之间，瞄准恰当的中间。",
                formula: "怯懦  <  勇敢  <  鲁莽",
                points: ["勇敢是怯懦（不及）与鲁莽（过度）之间的中道。",
                         "中道不是算术平均，而是“对的时间、对的对象、对的方式”。",
                         "德性是一种习惯，通过反复实践养成。"],
                body: .canvas(drawGoldenMean)),
        Chapter(part: "核心观点", title: "一燕不成春",
                thesis: "人的善是灵魂合乎德性的活动，而且要贯穿完整的一生。",
                formula: "幸福 = 灵魂合乎德性的活动 × 完整一生",
                points: ["每种事物的善在于发挥它特有的功能。",
                         "人的特有功能是理性的活动。",
                         "一只燕子或一个晴天不成春天，一天的善也不使人幸福。"],
                body: .canvas(drawSwallows)),
    ],
    "summa": [
        Chapter(part: "核心观点", title: "五路",
                thesis: "上帝的存在可以用五种方式证明。",
                formula: "运动 · 动力因 · 偶然与必然 · 完满等级 · 目的",
                points: ["五路都从经验中可见的事实出发。",
                         "每一路都推到一个不能再往后追溯的第一者。",
                         "阿奎那认为：这个第一者就是人们所说的上帝。"],
                body: .canvas(drawFiveWays)),
        Chapter(part: "核心观点", title: "第一推动者",
                thesis: "凡运动者都被他物推动；推动的链条不能无限回溯，必有不被推动的第一推动者。",
                formula: "… → 杖 → 手 → 第一推动者（不被推动）",
                points: ["运动是从潜能到现实的转变。",
                         "同一事物不能在同一方面既是潜能又是现实。",
                         "若无第一推动者，就没有后续的推动者。"],
                body: .canvas(drawFirstMover)),
    ],
    "monadologie": [
        Chapter(part: "核心观点", title: "单子没有窗户",
                thesis: "单子是没有部分的单纯实体；它们没有窗户，没有东西能进出。",
                formula: "单子 = 单纯实体 ， 无窗户 ， 各自映照全宇宙",
                points: ["复合物由单纯的单子组成。",
                         "单子之间没有真正的相互作用。",
                         "每个单子从自己的视点映照整个宇宙。"],
                body: .canvas(drawMonads)),
        Chapter(part: "核心观点", title: "最好的可能世界",
                thesis: "神观念中有无数可能的世界，只有一个能存在；神按完满程度选择了最好的那个。",
                formula: "存在的世界 = argmax 完满(可能世界)",
                points: ["选择必须有充足理由。",
                         "理由在于各个世界所含完满程度的差异。",
                         "神的智慧认识它，善意选择它，能力产生它。"],
                body: .canvas(drawBestWorld)),
    ],
    "tractatus": [
        Chapter(part: "核心观点", title: "世界是事实的总和",
                thesis: "世界是一切发生的事情；是事实的总和，而不是物的总和。",
                formula: "世界 = Σ 事实  ≠  Σ 物",
                points: ["物只有在事态之中才出现。",
                         "事实是事态的存在。",
                         "命题是事实的逻辑图像。"],
                body: .canvas(drawFactsWorld)),
        Chapter(part: "核心观点", title: "语言的界限",
                thesis: "我的语言的界限意味着我的世界的界限；对不可说的，必须保持沉默。",
                formula: "可说 ⊂ 语言的界限 ； 不可说 → 沉默",
                points: ["能说的都能说清楚。",
                         "伦理、美学、神秘的东西只能显示，不能说出。",
                         "全书最后一句只有一个命题：7。"],
                body: .canvas(drawLimitsOfLanguage)),
    ],
]

private let ownEN = "本应用英译"

let westernWorkPassages2: [String: [Passage]] = [
    "nicomachean:0": [Passage(ref: "Ethics, Book II（Chase 英译）",
        original: "Virtue then is in a sense a mean state, since it certainly has an aptitude for aiming at the mean.",
        english: nil,
        chinese: "所以德性在某种意义上是一种中道状态，因为它确实善于瞄准中间。",
        originalLang: "English（Chase 译）")],
    "nicomachean:1": [Passage(ref: "Ethics, Book I（Chase 英译）",
        original: "… then the Good of Man comes to be \"a working of the Soul in the way of Excellence,\" or, if Excellence admits of degrees, in the way of the best and most perfect Excellence. … for as it is not one swallow or one fine day that makes a spring, so it is not one day or a short time that makes a man blessed and happy.",
        english: nil,
        chinese: "……于是人的善就是“灵魂合乎德性的活动”；如果德性有多种，就是合乎最好、最完满的德性。……因为一只燕子或一个晴天不成春天，一天或短暂的时间也不能使人幸福。",
        originalLang: "English（Chase 译）")],
    "summa:0": [Passage(ref: "Summa Theologica, I, q. 2, a. 3",
        original: "The existence of God can be proved in five ways.",
        english: nil,
        chinese: "上帝的存在可以用五种方式来证明。",
        originalLang: "English（多明我会译）")],
    "summa:1": [Passage(ref: "Summa Theologica, I, q. 2, a. 3（第一路）",
        original: "The first and more manifest way is the argument from motion. It is certain, and evident to our senses, that in the world some things are in motion. … Therefore it is necessary to arrive at a first mover, put in motion by no other; and this everyone understands to be God.",
        english: nil,
        chinese: "第一条、也是更明显的路，是从运动出发的论证。世界上有些事物在运动，这是确定的，也是感官明显可见的。……因此必须达到一个不被其他事物推动的第一推动者；所有人都把它理解为上帝。",
        originalLang: "English（多明我会译）")],
    "monadologie:0": [
        Passage(ref: "La Monadologie, §1",
            original: "1. La Monade, dont nous parlerons ici, n'est autre chose, qu'une substance simple, qui entre dans les composés; simple, c'est-à-dire sans parties.",
            english: "1. The Monad of which we shall speak here is nothing but a simple substance which enters into composites; simple, that is to say, without parts.",
            chinese: "一、我们这里要谈的单子，不是别的，只是一种组成复合物的单纯实体；单纯，就是说没有部分。",
            englishSource: ownEN, originalLang: "Français"),
        Passage(ref: "La Monadologie, §7",
            original: "Les Monades n'ont point de fenêtres, par lesquelles quelque chose y puisse entrer ou sortir.",
            english: "Monads have no windows through which anything could come in or go out.",
            chinese: "单子没有可供某物出入的窗户。",
            englishSource: ownEN, originalLang: "Français"),
    ],
    "monadologie:1": [Passage(ref: "La Monadologie, §53, §55",
        original: "53. Or, comme il y a une infinité d'univers possibles dans les Idées de Dieu et qu'il n'en peut exister qu'un seul, il faut qu'il y ait une raison suffisante du choix de Dieu, qui le détermine à l'un plutôt qu'à l'autre. … 55. Et c'est ce qui est la cause de l'existence du Meilleur, que la sagesse fait connaître à Dieu, que sa bonté le fait choisir, et que sa puissance le fait produire.",
        english: "53. Now, as there is an infinity of possible universes in the Ideas of God, and only one of them can exist, there must be a sufficient reason for God's choice, which determines him to one rather than another. … 55. And this is the cause of the existence of the Best, which wisdom makes known to God, which his goodness makes him choose, and which his power makes him produce.",
        chinese: "五十三、神的观念中有无限多可能的宇宙，而只能有一个存在，所以神的选择必须有充足理由，使他决定选这一个而不是另一个。……五十五、这就是最好者之所以存在的原因：智慧使神认识它，善意使神选择它，能力使神产生它。",
        englishSource: ownEN, originalLang: "Français")],
    "tractatus:0": [Passage(ref: "Tractatus 1, 1.1",
        original: "Die Welt ist alles, was der Fall ist. … Die Welt ist die Gesamtheit der Tatsachen, nicht der Dinge.",
        english: "The world is everything that is the case. … The world is the totality of facts, not of things.",
        chinese: "世界是一切发生的事情。……世界是事实的总和，而不是物的总和。",
        englishSource: ownEN, originalLang: "Deutsch")],
    "tractatus:1": [
        Passage(ref: "Tractatus 5.6",
            original: "Die Grenzen meiner Sprache bedeuten die Grenzen meiner Welt.",
            english: "The limits of my language mean the limits of my world.",
            chinese: "我的语言的界限意味着我的世界的界限。",
            englishSource: ownEN, originalLang: "Deutsch"),
        Passage(ref: "Tractatus 7",
            original: "Wovon man nicht sprechen kann, darüber muss man schweigen.",
            english: "Whereof one cannot speak, thereof one must be silent.",
            chinese: "对于不可说的东西，必须保持沉默。",
            englishSource: ownEN, originalLang: "Deutsch"),
    ],
]

// MARK: - 动画

func drawGoldenMean(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 6, 8])
    let y = h * 0.5, x0 = 40.0, x1 = w - 40
    line(&ctx, x0, y, x1, y, Color.primary.opacity(0.3), 3)
    label(&ctx, "不及：怯懦", x0 + 40, y + 30, Moon.silver, size: 12)
    label(&ctx, "过度：鲁莽", x1 - 40, y + 30, Moon.violet, size: 12)
    let pos: Double
    switch b {
    case 0: pos = lerp(0.1, 0.9, 0.5 + 0.5 * sin(t * 1.0))
    case 1: pos = lerp(0.12, 0.88, 0.5 + 0.5 * sin(t * 0.7)) * (1 - smooth(p)) + 0.5 * smooth(p)
    default: pos = 0.5 + 0.015 * sin(t * 2)
    }
    let x = lerp(x0, x1, pos)
    let col: Color = abs(pos - 0.5) < 0.08 ? Moon.gold : (pos < 0.5 ? Moon.silver : Moon.violet)
    dot(&ctx, x, y, 16, col)
    if b == 2 {
        line(&ctx, (x0 + x1) / 2, y - 40, (x0 + x1) / 2, y + 12, Moon.gold, 2)
        label(&ctx, "勇敢", (x0 + x1) / 2, y - 56, Moon.gold, size: 15)
    }
    let titles = ["在两个极端之间摇摆", "反复练习，逐渐找到中间", "德性：瞄准中道"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "对的时间、对的对象、对的方式", size)
}

func drawSwallows(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 8, 7])
    func bird(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ s: Double) {
        let f = 6 * sin(t * 4 + x)
        line(&ctx, x - 10 * s, y - f * s * 0.3, x, y, Moon.silver, 2)
        line(&ctx, x, y, x + 10 * s, y - f * s * 0.3, Moon.silver, 2)
    }
    switch b {
    case 0:
        bird(&ctx, w / 2 + sin(t * 0.5) * 60, h * 0.4, 1.4)
        label(&ctx, "一只燕子 ≠ 春天", w / 2, h * 0.7, .primary, size: 14)
        headline(&ctx, "一个晴天、一时的善，都不够", size)
    case 1:
        let n = 1 + Int(smooth(p / 0.8) * 24)
        for i in 0..<n {
            let s = Double(i)
            bird(&ctx, 40 + hash01(s) * (w - 80) + sin(t * 0.4 + s) * 10, 60 + hash01(s + 3) * h * 0.5, 1)
        }
        headline(&ctx, "日复一日合乎德性地活动", size)
    default:
        let k = smooth(p / 0.6)
        line(&ctx, 40, h * 0.6, w - 40, h * 0.6, Color.primary.opacity(0.3), 2)
        line(&ctx, 40, h * 0.6, 40 + (w - 80) * k, h * 0.6, Moon.gold, 4)
        label(&ctx, "生", 40, h * 0.6 + 22, Moon.dim, size: 12)
        label(&ctx, "终", w - 40, h * 0.6 + 22, Moon.dim, size: 12)
        if k > 0.95 { label(&ctx, "幸福（eudaimonia）", w / 2, h * 0.45, Moon.gold, size: 16) }
        headline(&ctx, "贯穿完整的一生", size, Moon.gold)
    }
    caption(&ctx, "人的善：灵魂合乎德性的活动", size)
}

func drawFiveWays(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let ways = [("运动", "第一推动者"), ("动力因", "第一因"), ("偶然", "必然存在者"), ("完满等级", "最完满者"), ("目的", "智慧的安排者")]
    let (b, p) = beats(t, [4, 4, 4, 4, 4, 6])
    let rowH = (h - 110) / 5
    for (i, wv) in ways.enumerated() {
        let y = 60 + Double(i) * rowH + rowH / 2
        let on = b == 5 || i == b
        let k = i == b ? smooth(p / 0.6) : (i < b || b == 5 ? 1 : 0)
        box(&ctx, 24, y - 16, w * 0.32, 32, on ? Moon.silver : Moon.silver.opacity(0.4))
        label(&ctx, wv.0, 24 + w * 0.16, y, on ? .primary : Moon.dim, size: 13)
        line(&ctx, 30 + w * 0.32, y, 30 + w * 0.32 + (w * 0.22) * k, y, Moon.gold.opacity(0.7), 2)
        if k > 0.95 { label(&ctx, wv.1, w * 0.8, y, on ? Moon.gold : Moon.dim, size: 13) }
    }
    if b == 5 {
        dot(&ctx, w * 0.8, h - 40, 14 + 4 * sin(t * 1.5), Moon.gold)
        label(&ctx, "上帝", w * 0.8 - 40, h - 40, Moon.gold, size: 13)
    }
    headline(&ctx, b < 5 ? "第\(["一", "二", "三", "四", "五"][b])路：从\(ways[b].0)出发" : "五路都推到同一个第一者", size)
    caption(&ctx, "从可见的经验，上溯到第一原因", size)
}

func drawFirstMover(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 7])
    let y = h * 0.5
    let names = ["石头", "杖", "手", "……"]
    let n = b == 0 ? 3 : 4
    for i in 0..<n {
        let x = w * 0.85 - Double(i) * w * 0.2
        let push = 6 * sin(t * 2 - Double(i))
        dot(&ctx, x + push, y, 16, i == 3 ? Moon.violet : Moon.silver)
        label(&ctx, names[i], x, y + 30, Moon.dim, size: 12)
        if i > 0 { line(&ctx, x + 18, y, x + w * 0.2 - 18, y, Color.primary.opacity(0.4), 1.5) }
    }
    if b == 1 {
        for i in 0..<5 { blob(&ctx, w * 0.2 - Double(i) * 14 - fract(t * 0.5) * 14, y, 2.5, Moon.dim) }
        label(&ctx, "无限回溯？", w * 0.15, y - 40, .red.opacity(0.7), size: 13)
    }
    if b == 2 {
        let k = smooth(p / 0.5)
        dot(&ctx, w * 0.12, y, 22 * k + 4, Moon.gold)
        label(&ctx, "第一推动者", w * 0.12, y - 40, Moon.gold, size: 13)
        label(&ctx, "（不被推动）", w * 0.12, y + 36, Moon.gold, size: 11)
    }
    let titles = ["凡运动者，都被他物推动", "推动的链条不能无限回溯", "必须有一个不被推动的第一推动者"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "运动：从潜能到现实", size)
}

func drawMonads(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 8])
    let centers: [(Double, Double)] = [(0.25, 0.35), (0.72, 0.3), (0.5, 0.68), (0.2, 0.75), (0.82, 0.72)]
    for (i, c) in centers.enumerated() {
        let x = w * c.0, y = h * c.1
        dot(&ctx, x, y, 30, i == 2 ? Moon.gold : Moon.silver)
        if b == 2 {
            // 每个单子内部映照整个宇宙（缩小的五个点）
            for (j, d) in centers.enumerated() {
                blob(&ctx, x + (d.0 - 0.5) * 36, y + (d.1 - 0.5) * 36, 2, (j == i ? Moon.gold : Color.primary).opacity(0.7))
            }
        }
    }
    if b == 1 {
        let k = fract(p * 2)
        let sx = lerp(w * 0.5, w * 0.5, k), sy = lerp(h * 0.95, h * 0.68 + 34, min(1, k * 1.6))
        let bounce = k > 0.62 ? (k - 0.62) * 80 : 0
        dot(&ctx, sx, sy + bounce, 6, .red.opacity(0.8))
        label(&ctx, "进不去", w * 0.5 + 50, h * 0.88, .red.opacity(0.7), size: 12)
    }
    let titles = ["单纯实体：没有部分", "没有窗户：任何东西都进不去", "每个单子从自己的视点映照整个宇宙"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "Les Monades n'ont point de fenêtres", size)
}

func drawBestWorld(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 7])
    let n = 6
    let perf: [Double] = [0.45, 0.7, 0.3, 1.0, 0.55, 0.62]
    let best = 3
    for i in 0..<n {
        let x = 40 + Double(i) * (w - 80) / Double(n - 1)
        let y = h * 0.42
        let chosen = b == 2 && i == best
        let faded = b == 2 && i != best
        let r = chosen ? 26 + 8 * smooth(p / 0.5) : 18
        dot(&ctx, x, y, r, (chosen ? Moon.gold : Moon.silver).opacity(faded ? 0.25 : 1))
        if b >= 1 {
            let bh = 90 * perf[i] * (b == 1 ? smooth(p / 0.7) : 1)
            box(&ctx, x - 8, h * 0.82 - bh, 16, max(1, bh), (i == best ? Moon.gold : Moon.silver).opacity(faded ? 0.3 : 1))
        }
    }
    if b >= 1 { label(&ctx, "完满程度", w / 2, h * 0.88, Moon.dim, size: 11) }
    let titles = ["神的观念中有无数可能的世界", "比较它们所含的完满程度", "智慧认识它，善意选择它，能力产生它"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "充足理由：存在的是最好的可能世界", size)
}

func drawFactsWorld(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 7])
    let pts: [(Double, Double)] = [(0.2, 0.35), (0.35, 0.6), (0.5, 0.3), (0.65, 0.55), (0.8, 0.35), (0.3, 0.8), (0.7, 0.8)]
    let links: [(Int, Int)] = [(0, 1), (1, 3), (2, 4), (3, 6), (5, 1)]
    for (i, q) in pts.enumerated() {
        dot(&ctx, w * q.0, h * q.1, 12, b == 0 ? Moon.silver : Moon.silver.opacity(0.7))
        if b == 0 { label(&ctx, "物", w * q.0, h * q.1 + 22, Moon.dim, size: 10) }
        _ = i
    }
    if b >= 1 {
        let k = b == 1 ? smooth(p / 0.7) : 1
        for (a, c) in links.prefix(Int(ceil(k * Double(links.count)))) {
            line(&ctx, w * pts[a].0, h * pts[a].1, w * pts[c].0, h * pts[c].1, Moon.gold.opacity(0.8), 2.5)
        }
    }
    if b == 2 {
        ring(&ctx, w / 2, h * 0.55, min(w, h) * 0.42, Moon.gold.opacity(0.6), 1.5, dash: [5, 5])
        label(&ctx, "世界", w / 2, h * 0.55 - min(w, h) * 0.42 - 12, Moon.gold, size: 13)
    }
    let titles = ["孤立的物还不构成世界", "物在事态中联结：事实", "世界 = 事实的总和"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "Die Welt ist alles, was der Fall ist.", size)
}

func drawLimitsOfLanguage(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 7, 8])
    let cx = w / 2, cy = h * 0.52, R = min(w, h) * 0.32
    let fade = b == 2 ? 1 - smooth(p / 0.7) : 1
    ring(&ctx, cx, cy, R, Moon.gold.opacity(0.8 * fade), 2)
    label(&ctx, "语言的界限", cx, cy - R - 14, Moon.gold.opacity(fade), size: 12)
    let sayable = ["事实", "科学命题", "日常描述"]
    for (i, s) in sayable.enumerated() {
        let a = Double(i) / 3 * 2 * Double.pi + t * 0.1
        dot(&ctx, cx + cos(a) * R * 0.5, cy + sin(a) * R * 0.5, 12, Moon.silver.opacity(fade))
        label(&ctx, s, cx + cos(a) * R * 0.5, cy + sin(a) * R * 0.5 + 22, Color.primary.opacity(0.7 * fade), size: 11)
    }
    if b >= 1 {
        let outside = ["伦理", "美", "神秘"]
        for (i, s) in outside.enumerated() {
            let a = Double(i) / 3 * 2 * Double.pi + 0.5 - t * 0.05
            let x = cx + cos(a) * (R + 50), y = cy + sin(a) * (R + 40)
            label(&ctx, s, x, y, Moon.violet.opacity(0.35 * fade + 0.1), size: 13)
        }
    }
    if b == 2 && p > 0.7 { label(&ctx, "7", cx, cy, Color.primary.opacity(smooth((p - 0.7) / 0.3)), size: 30) }
    let titles = ["能说的，都能说清楚", "界限之外：只能显示，不能说出", "对不可说的，必须保持沉默"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "Die Grenzen meiner Sprache bedeuten die Grenzen meiner Welt.", size)
}
