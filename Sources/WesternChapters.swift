import SwiftUI

let workChapters: [String: [Chapter]] = chineseWorkChapters
    .merging(westernWorkChapters) { a, _ in a }
    .merging(westernWorkChapters2) { a, _ in a }
let workPassages: [String: [Passage]] = chineseWorkPassages
    .merging(westernWorkPassages) { a, _ in a }
    .merging(westernWorkPassages2) { a, _ in a }

// MARK: - 章节

let westernWorkChapters: [String: [Chapter]] = [
    "apology": [
        Chapter(part: "核心观点", title: "未经审视的生活",
                thesis: "未经审视的生活不值得过；每天讨论德性、审视自己和他人，是人最大的善。",
                formula: "主张 → 诘问 → 审视",
                points: ["苏格拉底通过不断提问，检验人们自以为知道的东西。",
                         "大多数定义经不起追问。",
                         "哲学首先是一种生活方式：持续地自我审视。"],
                body: .canvas(drawExamined)),
        Chapter(part: "核心观点", title: "自知无知",
                thesis: "他不知道却以为知道；我不知道，也不以为知道。",
                formula: "知道自己无知  ＞  自以为知",
                points: ["神谕说苏格拉底是最有智慧的人。",
                         "他走访自称智者的人，发现他们并不真懂。",
                         "苏格拉底的智慧在于承认自己的无知。"],
                body: .canvas(drawIgnorance)),
    ],
    "republic": [
        Chapter(part: "核心观点", title: "洞穴之喻",
                thesis: "囚徒把墙上的影子当作真实；走出洞穴的人才看见太阳下的事物本身。",
                formula: "影子 → 火光 → 实物 → 太阳（善的理念）",
                points: ["囚徒从小被锁住，只能看到墙上的影子。",
                         "被解放的人先被火光刺眼，再走出洞穴。",
                         "太阳象征善的理念，是一切可知事物的源泉。"],
                body: .canvas(drawCave)),
        Chapter(part: "核心观点", title: "线段之喻",
                thesis: "把一条线分成不等的两段，再各自按同样比例分开：对应认识的四个层次。",
                formula: "想象 < 信念 < 理智 < 理性",
                points: ["下段是可见世界：影像与实物。",
                         "上段是可知世界：数学对象与理念。",
                         "越往上越清晰、越真实。"],
                body: .canvas(drawDividedLine)),
    ],
    "confessions": [
        Chapter(part: "核心观点", title: "时间是什么",
                thesis: "没人问我，我倒清楚；要我解释，我便茫然。时间是心灵的延展。",
                formula: "过去 = 记忆 ，现在 = 注意 ，将来 = 期待",
                points: ["过去已不在，将来尚未来，现在转瞬即逝。",
                         "那么时间在哪里？在心灵之中。",
                         "奥古斯丁把时间理解为心灵的延展。"],
                body: .canvas(drawAugustineTime)),
    ],
    "discourse": [
        Chapter(part: "核心观点", title: "我思故我在",
                thesis: "怀疑一切之后，唯有“正在怀疑的我”无法被怀疑。",
                formula: "怀疑 ⟹ 我思 ⟹ 我在",
                points: ["感官会骗人，梦境与清醒难以区分。",
                         "就算一切都是假的，正在思考的我必然存在。",
                         "这成为笛卡尔重建知识的第一原理。"],
                body: .canvas(drawCogito)),
    ],
    "meditationes": [
        Chapter(part: "核心观点", title: "蜡块",
                thesis: "蜡块融化后，颜色、形状、气味全变了，我们仍知道它是同一块蜡。",
                formula: "感官性质改变 ， 蜡仍是蜡 ⟹ 靠心灵认识",
                points: ["刚取出的蜡有颜色、形状、气味，是硬的、冷的。",
                         "靠近火后，这些性质全都改变。",
                         "认识蜡的不是感官或想象，而是心灵的洞察。"],
                body: .canvas(drawWax)),
    ],
    "ethics": [
        Chapter(part: "核心观点", title: "神即自然",
                thesis: "只有一个实体：神，或者说自然；万物都是它的样式。",
                formula: "实体 = 神 = 自然 ， 万物 = 样式",
                points: ["神或自然出于自身本性的必然而存在与行动。",
                         "自然并没有预设的目的。",
                         "个别事物都是唯一实体的变化样式。"],
                body: .canvas(drawOneSubstance)),
        Chapter(part: "核心观点", title: "观念与事物的平行",
                thesis: "观念的次序和联系，与事物的次序和联系是同一的。",
                formula: "order(观念) ≡ order(事物)",
                points: ["思想与广延是同一实体的两种属性。",
                         "心灵与身体不是两个相互作用的东西，而是同一事物的两种表达。"],
                body: .canvas(drawParallelism)),
    ],
    "enquiry": [
        Chapter(part: "核心观点", title: "习惯是人生的向导",
                thesis: "我们从未看到因果之间的必然联系，只看到恒常的相伴，期待来自习惯。",
                formula: "A 后 B（n 次） ⟹ 期待 B ， 但 ⇏ 必然",
                points: ["一个台球撞另一个，我们只看到先后发生。",
                         "重复多次后，心灵形成习惯，产生期待。",
                         "习惯，而非理性，是人生的伟大向导。"],
                body: .canvas(drawCustom)),
        Chapter(part: "核心观点", title: "付之一炬",
                thesis: "一本书若既无关数量的抽象推理，又无关事实的经验推理，就付之一炬。",
                formula: "观念的关系 ∨ 实际的事情 ， 否则 → 🔥",
                points: ["有意义的知识只有两类：数学式推理与经验推理。",
                         "这就是后人所说的“休谟之叉”。",
                         "它被逻辑实证主义继承，用来批判形而上学。"],
                body: .canvas(drawHumesFork)),
    ],
    "zarathustra": [
        Chapter(part: "核心观点", title: "人是一根绳索",
                thesis: "人是系在动物与超人之间的一根绳索，一根悬在深渊上的绳索。",
                formula: "动物 —— 人 —— 超人",
                points: ["人是应当被超越的东西。",
                         "人之伟大在于他是桥梁，而不是目的。",
                         "走钢丝的人象征在危险中前行的人类。"],
                body: .canvas(drawRope)),
        Chapter(part: "核心观点", title: "精神三变",
                thesis: "精神变为骆驼，骆驼变为狮子，狮子最后变为孩子。",
                formula: "骆驼（你应） → 狮子（我要） → 孩子（神圣的肯定）",
                points: ["骆驼：承担一切重负。",
                         "狮子：对“你应”说“不”，为自己争得自由。",
                         "孩子：天真与遗忘，一个新的开始。"],
                body: .canvas(drawThreeMetamorphoses)),
    ],
]

// MARK: - 原文（逐字核对自公有领域文本）

private let jowett = "English（Jowett 译）"
private let ownEN = "本应用英译"

let westernWorkPassages: [String: [Passage]] = [
    "apology:0": [Passage(ref: "Apology（Jowett 英译）",
        original: "… daily to discourse about virtue, and of those other things about which you hear me examining myself and others, is the greatest good of man, and that the unexamined life is not worth living …",
        english: nil,
        chinese: "……每天讨论德性，以及你们听我审视自己和他人时谈到的那些事，是人最大的善；未经审视的生活不值得过……",
        originalLang: jowett)],
    "apology:1": [Passage(ref: "Apology（Jowett 英译）",
        original: "Well, although I do not suppose that either of us knows anything really beautiful and good, I am better off than he is,--for he knows nothing, and thinks that he knows; I neither know nor think that I know.",
        english: nil,
        chinese: "虽然我认为我们俩都不真正懂得什么美与善，但我比他强一些——他什么都不知道，却以为自己知道；我既不知道，也不以为自己知道。",
        originalLang: jowett)],
    "republic:0": [Passage(ref: "The Republic, Book VII（Jowett 英译）",
        original: "Behold! human beings living in a underground den, which has a mouth open towards the light and reaching all along the den; here they have been from their childhood, and have their legs and necks chained so that they cannot move, and can only see before them, being prevented by the chains from turning round their heads.",
        english: nil,
        chinese: "看哪！有一群人住在地下的洞穴里，洞口朝着光亮，与整个洞穴一样宽。他们从小就待在这里，腿和脖子被锁住，不能走动，只能看见前方，因为锁链让他们无法转头。",
        originalLang: jowett)],
    "republic:1": [Passage(ref: "The Republic, Book VI（Jowett 英译）",
        original: "Now take a line which has been cut into two unequal parts, and divide each of them again in the same proportion, and suppose the two main divisions to answer, one to the visible and the other to the intelligible …",
        english: nil,
        chinese: "现在取一条被分成不等两段的线，再把每一段按同样的比例分开；设想两大段分别对应可见世界与可知世界……",
        originalLang: jowett)],
    "confessions:0": [Passage(ref: "Confessions, Book XI（Pusey 英译）",
        original: "What then is time? If no one asks me, I know: if I wish to explain it to one that asketh, I know not: yet I say boldly that I know, that if nothing passed away, time past were not; and if nothing were coming, a time to come were not; and if nothing were, time present were not.",
        english: nil,
        chinese: "那么时间究竟是什么？没有人问我，我倒清楚；有人问我，我想说明，便茫然不解了。但我敢肯定地说：如果没有事物过去，就没有过去的时间；如果没有事物到来，就没有将来的时间；如果什么都不存在，也就没有现在的时间。",
        originalLang: "English（Pusey 译）")],
    "discourse:0": [Passage(ref: "Discourse on the Method, Part IV（Veitch 英译）",
        original: "… whilst I thus wished to think that all was false, it was absolutely necessary that I, who thus thought, should be somewhat; and as I observed that this truth, I think, therefore I am (COGITO ERGO SUM), was so certain …",
        english: nil,
        chinese: "……当我愿意认为一切都是假的时候，这样思想着的我必然是某种东西；我注意到“我思故我在”这条真理是如此确实……",
        originalLang: "English（Veitch 译）")],
    "meditationes:0": [
        Passage(ref: "Meditationes, II",
            original: "ego sum, ego existo",
            english: "I am, I exist.",
            chinese: "我是，我存在。",
            englishSource: ownEN, originalLang: "Latina"),
        Passage(ref: "Meditationes, II（蜡块）",
            original: "Sumamus, exempli causa, hanc ceram; nuperrime ex favis fuit educta, nondum amisit omnem saporem sui mellis, nonnihil retinet odoris florum ex quibus collecta est",
            english: "Let us take, for example, this piece of wax: it has just been taken from the honeycomb, it has not yet lost all the taste of its honey, and it retains something of the scent of the flowers from which it was gathered.",
            chinese: "举个例子，就拿这块蜡来说：它刚从蜂巢里取出，还没有失去蜂蜜的全部甜味，还保留着一点采蜜花朵的香气。",
            englishSource: ownEN, originalLang: "Latina"),
    ],
    "ethics:0": [Passage(ref: "Ethics, Part IV, Preface（Elwes 英译）",
        original: "For the eternal and infinite Being, which we call God or Nature, acts by the same necessity as that whereby it exists.",
        english: nil,
        chinese: "因为那个永恒无限的存在，我们称之为神或自然，它行动所依据的必然性，与它存在所依据的必然性相同。",
        originalLang: "English（Elwes 译）")],
    "ethics:1": [Passage(ref: "Ethics, Part II, Prop. VII（Elwes 英译）",
        original: "The order and connection of ideas is the same as the order and connection of things.",
        english: nil,
        chinese: "观念的次序和联系，与事物的次序和联系是相同的。",
        originalLang: "English（Elwes 译）")],
    "enquiry:0": [Passage(ref: "An Enquiry Concerning Human Understanding, Sect. V",
        original: "Custom, then, is the great guide of human life. It is that principle alone which renders our experience useful to us, and makes us expect, for the future, a similar train of events with those which have appeared in the past.",
        english: nil,
        chinese: "所以，习惯是人生的伟大向导。唯有这个原则使我们的经验对我们有用，并使我们期待将来出现与过去相似的一连串事件。",
        originalLang: "English")],
    "enquiry:1": [Passage(ref: "An Enquiry Concerning Human Understanding, Sect. XII",
        original: "If we take in our hand any volume; of divinity or school metaphysics, for instance; let us ask, Does it contain any abstract reasoning concerning quantity or number? No. Does it contain any experimental reasoning concerning matter of fact and existence? No. Commit it then to the flames: for it can contain nothing but sophistry and illusion.",
        english: nil,
        chinese: "如果我们手里拿起任何一本书，比如神学或经院形而上学的书，我们就问：它包含关于数量或数的抽象推理吗？没有。它包含关于实际事实和存在的经验推理吗？没有。那就把它投入火中吧，因为它只能包含诡辩和幻想。",
        originalLang: "English")],
    "zarathustra:0": [Passage(ref: "Also sprach Zarathustra, Vorrede",
        original: "Ich lehre euch den Übermenschen. Der Mensch ist Etwas, das überwunden werden soll. … Der Mensch ist ein Seil, geknüpft zwischen Thier und Übermensch, - ein Seil über einem Abgrunde.",
        english: "I TEACH YOU THE SUPERMAN. Man is something that is to be surpassed. … Man is a rope stretched between the animal and the Superman--a rope over an abyss.",
        chinese: "我教你们超人。人是应当被超越的东西。……人是一根绳索，系在动物与超人之间——一根悬在深渊上的绳索。",
        englishSource: "Common 英译", originalLang: "Deutsch")],
    "zarathustra:1": [Passage(ref: "Also sprach Zarathustra, Von den drei Verwandlungen",
        original: "Drei Verwandlungen nenne ich euch des Geistes: wie der Geist zum Kamele wird, und zum Löwen das Kameel, und zum Kinde zuletzt der Löwe.",
        english: "Three metamorphoses of the spirit do I designate to you: how the spirit becometh a camel, the camel a lion, and the lion at last a child.",
        chinese: "我向你们说出精神的三种变化：精神如何变为骆驼，骆驼如何变为狮子，狮子最后如何变为孩子。",
        englishSource: "Common 英译", originalLang: "Deutsch")],
]

// MARK: - 动画

func drawExamined(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 7])
    let cx = w / 2, cy = h * 0.48
    let shrink = b == 0 ? 1.0 : (b == 1 ? 1 - 0.6 * smooth(p) : 0.4)
    if b < 2 {
        box(&ctx, cx - 120 * shrink, cy - 30 * shrink, 240 * shrink, 60 * shrink, Moon.gold, fill: Moon.gold.opacity(0.15))
        label(&ctx, b == 0 ? "“我知道什么是勇敢”" : "勇敢是……？", cx, cy, .primary, size: 14 * max(0.7, shrink))
    }
    if b >= 1 {
        for i in 0..<6 {
            let a = Double(i) / 6 * 2 * Double.pi + t * 0.3
            let r = lerp(140, 70 * shrink + 20, b == 1 ? smooth(p) : 1)
            dot(&ctx, cx + cos(a) * r, cy + sin(a) * r * 0.7, 10, Moon.violet)
            label(&ctx, "?", cx + cos(a) * r, cy + sin(a) * r * 0.7, .primary, size: 12)
        }
    }
    if b == 2 {
        dot(&ctx, cx, cy, 22, Moon.gold)
        label(&ctx, "审视", cx, cy, .primary, size: 13)
    }
    let titles = ["一个自信的主张", "苏格拉底不断追问", "剩下的是审视本身"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "未经审视的生活不值得过", size)
}

func drawIgnorance(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 8])
    let ax = w * 0.3, bx = w * 0.7, y = h * 0.5
    ring(&ctx, ax, y, 70, Moon.violet.opacity(0.7), 2)
    label(&ctx, "自以为知", ax, y - 86, Moon.violet, size: 12)
    dot(&ctx, ax, y, 8, Moon.violet)
    dot(&ctx, bx, y, 8, Moon.gold)
    label(&ctx, "苏格拉底", bx, y + 40, Moon.gold, size: 12)
    label(&ctx, "智者", ax, y + 90, Moon.violet, size: 12)
    if b == 1 {
        let k = smooth(p / 0.5)
        ring(&ctx, bx, y, 22 * k, Moon.gold, 2)
        label(&ctx, "知道自己无知", bx, y - 40, Moon.gold.opacity(k), size: 12)
        line(&ctx, ax - 70, y - 70, ax + 70, y + 70, Color.red.opacity(0.5 * k), 1.5)
    }
    headline(&ctx, b == 0 ? "两人真正知道的都很少" : "差别在于：是否知道自己不知道", size, b == 1 ? Moon.gold : .primary)
    caption(&ctx, "我既不知道，也不以为自己知道", size)
}

func drawCave(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 6, 6, 7])
    let wallX = w * 0.12, floorY = h * 0.78
    // 洞穴与出口
    ctx.fill(Path(CGRect(x: 0, y: 0, width: w * 0.75, height: h)), with: .color(Color.primary.opacity(b == 3 ? 0.04 : 0.1)))
    line(&ctx, wallX, h * 0.2, wallX, floorY, Color.primary.opacity(0.4), 3)
    // 火
    let fx = w * 0.55, fy = h * 0.62
    dot(&ctx, fx, fy + 4 * sin(t * 2), 12, Moon.gold)
    // 墙上的影子
    for i in 0..<3 {
        let sy = h * 0.35 + Double(i) * 32 + 6 * sin(t * 0.5 + Double(i))
        box(&ctx, wallX + 4, sy, 22, 18, Color.primary.opacity(0.5), fill: Color.primary.opacity(0.35))
    }
    // 囚徒
    for i in 0..<3 {
        let px = w * 0.3, py = h * 0.48 + Double(i) * 40
        let freed = i == 1 && b >= 1
        if !freed { dot(&ctx, px, py, 10, Moon.silver) }
    }
    // 被解放的人
    if b >= 1 {
        var x = w * 0.3, y = h * 0.48 + 40
        if b == 1 { x = lerp(w * 0.3, w * 0.45, smooth(p)) }
        if b == 2 { x = lerp(w * 0.45, w * 0.85, smooth(p)); y = lerp(h * 0.52, h * 0.3, smooth(p)) }
        if b == 3 { x = w * 0.85; y = h * 0.3 }
        dot(&ctx, x, y, 12, Moon.gold)
    }
    if b == 3 {
        let k = smooth(p / 0.5)
        dot(&ctx, w * 0.88, h * 0.1, 26 * k + 4, Moon.gold)
        label(&ctx, "太阳：善的理念", w * 0.82, h * 0.1 + 40, Moon.gold.opacity(k), size: 11)
    }
    let titles = ["囚徒只看见墙上的影子", "一人被解开，回头看见火光", "他艰难地走出洞穴", "在阳光下看见事物本身"]
    headline(&ctx, titles[b], size, b == 3 ? Moon.gold : .primary)
    caption(&ctx, "从影子到理念：灵魂的转向", size)
}

func drawDividedLine(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [5, 5, 5, 5, 6])
    // 比例 1 : 2 ， 各段再按 1 : 2 分
    let segs: [(String, String, Double)] = [("影像", "想象", 1), ("实物", "信念", 2), ("数学对象", "理智", 2), ("理念", "理性", 4)]
    let total = segs.reduce(0) { $0 + $1.2 }
    let x = w * 0.42, top = 60.0, bottom = h - 60
    var y = bottom
    for (i, s) in segs.enumerated() {
        let len = (bottom - top) * s.2 / total
        let active = b == 4 || i == b
        line(&ctx, x, y, x, y - len + 3, (i < 2 ? Moon.silver : Moon.gold).opacity(active ? 1 : 0.3), active ? 8 : 5)
        label(&ctx, s.0, x - 60, y - len / 2, active ? .primary : Moon.dim, size: 13)
        label(&ctx, s.1, x + 60, y - len / 2, active ? (i < 2 ? Moon.silver : Moon.gold) : Moon.dim, size: 13)
        y -= len
    }
    let mid = bottom - (bottom - top) * 3 / total
    line(&ctx, x - 26, mid, x + 26, mid, Color.primary.opacity(0.6), 1, dash: [4, 3])
    label(&ctx, "可知世界", w * 0.86, (top + mid) / 2, Moon.gold, size: 11)
    label(&ctx, "可见世界", w * 0.86, (mid + bottom) / 2, Moon.silver, size: 11)
    if b == 4 {
        let yy = lerp(bottom, top, smooth(p))
        dot(&ctx, x, yy, 10, .white)
    }
    headline(&ctx, b < 4 ? "\(segs[b].0) — \(segs[b].1)" : "越往上，越清晰、越真实", size)
    caption(&ctx, "认识的四个层次", size)
}

func drawAugustineTime(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 6, 8])
    let y = h * 0.45
    switch b {
    case 0:
        let fade = 1 - smooth(p / 0.8)
        line(&ctx, 30, y, w / 2 - 10, y, Moon.silver.opacity(0.2 + 0.8 * fade), 6)
        line(&ctx, w / 2 + 10, y, w - 30, y, Moon.violet.opacity(0.2 + 0.8 * fade), 6)
        dot(&ctx, w / 2, y, 10, Moon.gold)
        label(&ctx, "过去：已不在", w * 0.25, y + 28, Moon.silver, size: 12)
        label(&ctx, "将来：尚未在", w * 0.75, y + 28, Moon.violet, size: 12)
        headline(&ctx, "过去与将来都不存在？", size)
    case 1:
        let r = lerp(10, 3, smooth(p))
        dot(&ctx, w / 2, y, r, Moon.gold)
        label(&ctx, "现在：转瞬即逝", w / 2, y + 30, Moon.gold, size: 12)
        headline(&ctx, "现在没有长度", size)
    default:
        let k = smooth(p / 0.5)
        let items: [(String, Color, Double)] = [("记忆", Moon.silver, -1), ("注意", Moon.gold, 0), ("期待", Moon.violet, 1)]
        ring(&ctx, w / 2, y, 110 * k + 10, Color.primary.opacity(0.3), 1, dash: [4, 4])
        for it in items {
            dot(&ctx, w / 2 + it.2 * 70 * k, y, 24, it.1)
            label(&ctx, it.0, w / 2 + it.2 * 70 * k, y, .primary, size: 13)
        }
        label(&ctx, "心灵", w / 2, y - 120 * k - 6, Color.primary.opacity(0.6), size: 12)
        headline(&ctx, "时间在心灵之中：心灵的延展", size, Moon.gold)
    }
    caption(&ctx, "没人问我，我倒清楚；要我解释，我便茫然", size)
}

func drawCogito(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [8, 6, 7])
    let cx = w / 2, cy = h / 2
    let names = ["感官", "身体", "天空", "数学", "他人", "世界", "梦", "记忆"]
    let sweep = b == 0 ? smooth(p / 0.9) : 1
    for (i, n) in names.enumerated() {
        let a = Double(i) / Double(names.count) * 2 * Double.pi
        let x = cx + cos(a) * min(w, h) * 0.34, y = cy + sin(a) * min(w, h) * 0.34
        let gone = Double(i) / Double(names.count) < sweep
        if !gone {
            dot(&ctx, x, y, 14, Moon.silver)
            label(&ctx, n, x, y + 26, Moon.dim, size: 11)
        }
    }
    if b == 0 {
        let a = sweep * 2 * Double.pi
        line(&ctx, cx, cy, cx + cos(a) * min(w, h) * 0.42, cy + sin(a) * min(w, h) * 0.42, Moon.violet.opacity(0.6), 2)
        label(&ctx, "怀疑", cx + cos(a) * min(w, h) * 0.45, cy + sin(a) * min(w, h) * 0.45, Moon.violet, size: 12)
    }
    dot(&ctx, cx, cy, b == 2 ? 22 + 8 * smooth(p / 0.5) : 18, Moon.gold)
    label(&ctx, b == 2 ? "我在" : "我思", cx, cy, .primary, size: 14)
    if b == 2 { ring(&ctx, cx, cy, 40 + 50 * smooth(p), Moon.gold.opacity(1 - smooth(p)), 2) }
    let titles = ["把一切可疑的东西都当作假的", "唯有正在怀疑的“我思”无法被怀疑", "我思，故我在"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "第一原理：COGITO ERGO SUM", size)
}

func drawWax(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 8, 7])
    let melt = b == 0 ? 0 : (b == 1 ? smooth(p / 0.85) : 1)
    let bw = lerp(90, 200, melt), bh = lerp(90, 22, melt)
    let base = h * 0.7
    box(&ctx, w / 2 - bw / 2, base - bh, bw, bh, Moon.gold, fill: Moon.gold.opacity(lerp(0.35, 0.18, melt)))
    if b >= 1 {
        for i in 0..<3 { dot(&ctx, w / 2 - 30 + Double(i) * 30, base + 40 + 3 * sin(t * 3 + Double(i)), 8, Color.orange) }
        label(&ctx, "火", w / 2, base + 66, Color.orange, size: 11)
    }
    let before = ["黄色", "方形", "花香", "坚硬", "冰冷"]
    let after = ["变色", "无定形", "无味", "液态", "发热"]
    for i in 0..<5 {
        let x = 40 + Double(i) * (w - 80) / 4
        let changed = melt > Double(i + 1) / 6
        label(&ctx, changed ? after[i] : before[i], x, 50, changed ? Moon.violet : Moon.silver, size: 12)
    }
    if b == 2 { label(&ctx, "仍是同一块蜡", w / 2, base - 50, Moon.gold, size: 16) }
    let titles = ["刚取出的蜂蜡", "靠近火：所有感官性质都变了", "认识它的是心灵，不是感官"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "Sumamus hanc ceram", size)
}

func drawOneSubstance(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 8])
    let cx = w / 2, cy = h / 2, R = min(w, h) * 0.38
    dot(&ctx, cx, cy, R, Moon.gold.opacity(0.35))
    label(&ctx, "神 = 自然", cx, cy - R + 24, .primary, size: 14)
    if b == 1 {
        let n = Int(smooth(p / 0.6) * 24)
        for i in 0..<n {
            let s = Double(i)
            let a = hash01(s) * 2 * Double.pi + t * 0.1 * (hash01(s + 2) - 0.5)
            let r = R * (0.2 + 0.6 * hash01(s + 7))
            let x = cx + cos(a) * r, y = cy + sin(a) * r
            blob(&ctx, x, y, 3 + 2 * sin(t + s), Moon.violet)
        }
        label(&ctx, "样式", cx, cy + R - 20, Moon.violet, size: 12)
    }
    headline(&ctx, b == 0 ? "唯一的实体" : "万物是它的样式，不在它之外", size, b == 0 ? .primary : Moon.gold)
    caption(&ctx, "神或自然，出于必然而存在与行动", size)
}

func drawParallelism(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [8, 8])
    let yA = h * 0.35, yB = h * 0.65
    line(&ctx, 30, yA, w - 30, yA, Moon.violet.opacity(0.5), 2)
    line(&ctx, 30, yB, w - 30, yB, Moon.silver.opacity(0.5), 2)
    label(&ctx, "观念（思想）", 70, yA - 24, Moon.violet, size: 12)
    label(&ctx, "事物（广延）", 70, yB + 24, Moon.silver, size: 12)
    for i in 0..<5 {
        let x = 40 + fract(t * 0.05 + Double(i) * 0.2) * (w - 80)
        let pulse = b == 1 && i == 2 ? 6 * abs(sin(t * 2)) : 0
        dot(&ctx, x, yA, 10 + pulse, Moon.violet)
        dot(&ctx, x, yB, 10 + pulse, Moon.silver)
        line(&ctx, x, yA + 12, x, yB - 12, Color.primary.opacity(0.18), 1, dash: [3, 4])
    }
    _ = p
    headline(&ctx, b == 0 ? "两条线上的次序完全一致" : "一边变化，另一边同时变化", size)
    caption(&ctx, "同一实体的两种属性", size)
}

func drawCustom(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 8, 7])
    let y = h * 0.45
    let cyc = fract(t / 2.5)
    let ax = lerp(w * 0.15, w * 0.45, min(1, cyc * 2))
    let bx = cyc < 0.5 ? w * 0.55 : lerp(w * 0.55, w * 0.85, (cyc - 0.5) * 2)
    dot(&ctx, ax, y, 16, Moon.silver)
    dot(&ctx, bx, y, 16, Moon.violet)
    label(&ctx, "A", ax, y, .primary, size: 12)
    label(&ctx, "B", bx, y, .primary, size: 12)
    let n = b == 0 ? 1 : (b == 1 ? 1 + Int(p * 30) : 30)
    label(&ctx, "已见 \(n) 次：A 之后 B", w / 2, y + 60, Moon.dim, size: 12)
    if b >= 1 {
        let k = b == 1 ? smooth(p) : 1
        line(&ctx, w * 0.3, y - 50, w * 0.7, y - 50, Moon.gold.opacity(k), 3)
        label(&ctx, "期待（习惯）", w / 2, y - 70, Moon.gold.opacity(k), size: 12)
    }
    if b == 2 {
        label(&ctx, "必然联系？看不见", w / 2, y + 90, Color.red.opacity(0.7), size: 13)
    }
    let titles = ["我们只看到 A 之后发生 B", "重复越多，期待越强", "期待来自习惯，而非理性"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "习惯是人生的伟大向导", size)
}

func drawHumesFork(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [5, 5, 8])
    let fx = w / 2, fy = h * 0.5
    line(&ctx, fx, h * 0.85, fx, fy, Color.primary.opacity(0.4), 3)
    line(&ctx, fx, fy, w * 0.25, h * 0.2, Moon.silver.opacity(b == 0 ? 1 : 0.4), 3)
    line(&ctx, fx, fy, w * 0.75, h * 0.2, Moon.violet.opacity(b == 1 ? 1 : 0.4), 3)
    label(&ctx, "数量与数的抽象推理", w * 0.25, h * 0.2 - 18, Moon.silver, size: 11)
    label(&ctx, "事实与存在的经验推理", w * 0.75, h * 0.2 - 18, Moon.violet, size: 11)
    if b < 2 {
        box(&ctx, fx - 30, fy + 10, 60, 40, Moon.gold, fill: Moon.gold.opacity(0.2))
        label(&ctx, "经院书", fx, fy + 30, .primary, size: 11)
        label(&ctx, b == 0 ? "有吗？没有。" : "有吗？没有。", b == 0 ? w * 0.28 : w * 0.72, h * 0.32, .red.opacity(0.8), size: 13)
    } else {
        let k = smooth(p / 0.4)
        box(&ctx, fx - 30 * (1 - k), fy + 10 + 30 * k, 60 * (1 - k) + 1, 40 * (1 - k) + 1, Moon.gold)
        for i in 0..<12 {
            let s = Double(i)
            let x = fx + (hash01(s) - 0.5) * 80
            let y = fy + 60 - fract(t * 0.5 + hash01(s + 3)) * 90
            blob(&ctx, x, y, 3 + 3 * hash01(s + 5), Color.orange.opacity(0.8))
        }
        label(&ctx, "付之一炬", fx, fy + 100, Color.orange, size: 15)
    }
    let titles = ["它有关于数量或数的推理吗？", "它有关于事实的经验推理吗？", "只有诡辩与幻想：烧掉它"]
    headline(&ctx, titles[b], size, b == 2 ? Color.orange : .primary)
    caption(&ctx, "休谟之叉", size)
}

func drawRope(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 7])
    let y = h * 0.42
    ctx.fill(Path(CGRect(x: w * 0.18, y: y + 10, width: w * 0.64, height: h - y)), with: .color(Color.primary.opacity(0.08)))
    label(&ctx, "深渊", w / 2, h * 0.8, Moon.dim, size: 12)
    var rope = Path()
    rope.move(to: CGPoint(x: w * 0.15, y: y))
    rope.addQuadCurve(to: CGPoint(x: w * 0.85, y: y), control: CGPoint(x: w / 2, y: y + 24))
    ctx.stroke(rope, with: .color(Moon.gold.opacity(0.8)), lineWidth: 2)
    dot(&ctx, w * 0.1, y, 18, Moon.silver)
    label(&ctx, "动物", w * 0.1, y + 32, Moon.silver, size: 12)
    dot(&ctx, w * 0.9, y, 18 + (b == 2 ? 6 * smooth(p) : 0), Moon.gold)
    label(&ctx, "超人", w * 0.9, y + 32, Moon.gold, size: 12)
    let u = b == 0 ? 0.2 : (b == 1 ? lerp(0.2, 0.6, smooth(p)) : 0.6 + 0.02 * sin(t * 3))
    let x = lerp(w * 0.15, w * 0.85, u)
    let yy = y + 24 * 4 * u * (1 - u) * 0.5 * 2 - 14 + 3 * sin(t * 2)
    dot(&ctx, x, yy, 12, Moon.violet)
    label(&ctx, "人", x, yy - 24, Moon.violet, size: 12)
    let titles = ["人是系在动物与超人之间的绳索", "走过深渊：危险的过渡", "人是应当被超越的东西"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "人之伟大，在于他是桥梁而不是目的", size)
}

func drawThreeMetamorphoses(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 6, 7])
    let cx = w / 2, cy = h * 0.5
    let k = smooth(p / 0.4)
    switch b {
    case 0:
        dot(&ctx, cx, cy + 20, 30, Moon.silver)
        for i in 0..<3 { box(&ctx, cx - 40 + Double(i) * 27, cy - 40 - Double(i % 2) * 8, 24, 20, Moon.violet, fill: Moon.violet.opacity(0.3)) }
        label(&ctx, "你应", cx, cy - 60, Moon.violet, size: 13)
        headline(&ctx, "骆驼：背负一切重负", size)
    case 1:
        dot(&ctx, cx, cy, 30 + 6 * sin(t * 3), Moon.gold)
        for i in 0..<3 {
            let x = cx - 60 + Double(i) * 60
            box(&ctx, x - 12, cy - 70 - 40 * k, 24, 20, Moon.violet.opacity(1 - k))
        }
        label(&ctx, "我要", cx, cy, .primary, size: 15)
        headline(&ctx, "狮子：对“你应”说“不”", size)
    default:
        let g = 0.5 + 0.5 * sin(t * 1.2)
        dot(&ctx, cx, cy, 18 + 4 * g, Moon.gold)
        ring(&ctx, cx, cy, 40 + 30 * k, Moon.gold.opacity(0.6 * (1 - k * 0.5)), 1.5)
        label(&ctx, "是", cx, cy, .primary, size: 15)
        headline(&ctx, "孩子：天真、遗忘、一个新的开始", size, Moon.gold)
    }
    caption(&ctx, "骆驼 → 狮子 → 孩子", size)
}
