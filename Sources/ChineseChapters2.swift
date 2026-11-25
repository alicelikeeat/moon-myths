import SwiftUI

// MARK: - 孟子、韩非子、朱子语类（原文据漢籍リポジトリ）

let chineseWorkChapters2: [String: [Chapter]] = [
    "mengzi": [
        Chapter(part: "核心观点", title: "四端",
                thesis: "人皆有不忍人之心；恻隐、羞恶、辞让、是非四心，是仁义礼智的萌芽。",
                formula: "四端 →（扩而充之）→ 仁 · 义 · 礼 · 智",
                points: ["看见孩子将掉进井里，人人都会惊惧同情，这不为任何好处。",
                         "四端就像人有四肢一样，是天生的。",
                         "端只是萌芽，要“扩而充之”才能长成德性。"],
                body: .canvas(drawFourSprouts)),
        Chapter(part: "核心观点", title: "民贵君轻",
                thesis: "民为贵，社稷次之，君为轻。",
                formula: "民  >  社稷  >  君",
                points: ["得到百姓拥护的人才能成为天子。",
                         "国君危害社稷，就可以更换。",
                         "这是对权力合法性来源的重新排序。"],
                body: .canvas(drawPeopleFirst)),
    ],
    "hanfeizi": [
        Chapter(part: "核心观点", title: "二柄",
                thesis: "明主控制臣下，只靠两个把柄：刑与德（杀戮与庆赏）。",
                formula: "君 ─ 刑（罚）／德（赏）→ 臣",
                points: ["臣下畏惧惩罚、贪图奖赏。",
                         "赏罚之权必须出自君主自己。",
                         "一旦赏罚之权落到臣下手中，国人就会畏惧臣下而轻视君主。"],
                body: .canvas(drawTwoHandles)),
        Chapter(part: "核心观点", title: "以法为教",
                thesis: "明主之国，不用书简之文，以法为教；不用先王之语，以吏为师。",
                formula: "教化 = 法 ， 老师 = 吏",
                points: ["古今异俗，新旧异备，不能用宽缓之政治理急世之民。",
                         "儒墨称颂先王，但先王之道不能治今天。",
                         "百姓的言谈行动都要合于法。"],
                body: .canvas(drawLawAsTeaching)),
    ],
    "zhuziyulei": [
        Chapter(part: "核心观点", title: "理在气先",
                thesis: "未有天地之先，毕竟也只是理；有此理，便有此天地。",
                formula: "理 →（有理便有气）→ 气 → 天地万物",
                points: ["理是天地万物之所以然。",
                         "有理便有气流行，发育万物。",
                         "理与气不相离，但从逻辑上说理在先。"],
                body: .canvas(drawLiBeforeQi)),
        Chapter(part: "核心观点", title: "人人有一太极",
                thesis: "太极只是一个极好至善的道理；人人有一太极，物物有一太极。",
                formula: "一理 ↦ 万物各具一太极（理一分殊）",
                points: ["太极是天地人物万善至好的总名。",
                         "每个人、每个物都完整地具有这个理。",
                         "就像天上只有一个月亮，却映在所有江湖里。"],
                body: .canvas(drawMoonInRivers)),
    ],
]

private let ownEN = "本应用英译"

let chineseWorkPassages2: [String: [Passage]] = [
    "mengzi:0": [Passage(ref: "孟子·公孫丑上",
        original: "孟子曰：「人皆有不忍人之心。… 惻隱之心，仁之端也；羞惡之心，義之端也；辭讓之心，禮之端也；是非之心，智之端也。",
        english: "Mencius said: \"All people have a heart that cannot bear the suffering of others. … The heart of compassion is the sprout of benevolence; the heart of shame is the sprout of righteousness; the heart of deference is the sprout of propriety; the heart of right and wrong is the sprout of wisdom.\"",
        chinese: "孟子说：“人人都有不忍心看别人受苦的心。……同情心是仁的萌芽；羞耻心是义的萌芽；谦让心是礼的萌芽；是非心是智的萌芽。”",
        englishSource: ownEN, originalLang: "原文")],
    "mengzi:1": [Passage(ref: "孟子·盡心下",
        original: "孟子曰：「民為貴，社稷次之，君為輕。是故得乎丘民而為天子，得乎天子為諸侯，得乎諸侯為大夫。",
        english: "Mencius said: \"The people are the most important, the altars of the state come next, and the ruler is the least. Therefore whoever wins the common people becomes the Son of Heaven; whoever wins the Son of Heaven becomes a feudal lord; whoever wins a feudal lord becomes a great officer.\"",
        chinese: "孟子说：“百姓最重要，国家次之，君主最轻。所以得到百姓拥护的人成为天子，得到天子赏识的人成为诸侯，得到诸侯赏识的人成为大夫。”",
        englishSource: ownEN, originalLang: "原文")],
    "hanfeizi:0": [Passage(ref: "韓非子·二柄第七（四庫本，標點為本應用所加）",
        original: "明主之所導制其臣者，二柄而已矣。二柄者，刑、徳也。何謂刑徳？曰：殺戮之謂刑，慶賞之謂徳。",
        english: "What the enlightened ruler uses to guide and control his ministers is nothing but the two handles. The two handles are punishment and reward. What are punishment and reward? To kill and execute is called punishment; to honor and reward is called reward.",
        chinese: "英明的君主用来引导和控制臣下的，只有两个把柄。两个把柄就是刑和德。什么叫刑和德？杀戮叫作刑，庆赏叫作德。",
        englishSource: ownEN, originalLang: "原文")],
    "hanfeizi:1": [Passage(ref: "韓非子·五蠧第四十九（四庫本，標點為本應用所加）",
        original: "故明主之國，無書簡之文，以法為教；無先王之語，以吏為師。",
        english: "Therefore in the state of an enlightened ruler there are no writings on bamboo slips: the law is the teaching. There are no sayings of the former kings: the officials are the teachers.",
        chinese: "所以英明君主的国家，没有书本典籍，用法令来教化；没有先王的言论，以官吏为老师。",
        englishSource: ownEN, originalLang: "原文")],
    "zhuziyulei:0": [Passage(ref: "朱子語類·卷一·理氣上（四庫本，標點為本應用所加）",
        original: "問：昨謂未有天地之先，畢竟是先有理，如何？曰：未有天地之先，畢竟也只是理。有此理，便有此天地；若無此理，便亦無天地，無人無物，都無該載了。有理，便有氣流行，發育萬物。",
        english: "Asked: \"Yesterday you said that before heaven and earth existed there was, after all, principle first. What does that mean?\" Answer: \"Before heaven and earth existed, there was after all only principle. Because there is this principle, there are this heaven and earth; without this principle there would be no heaven and earth, no people, no things, nothing to carry anything. Where there is principle, there is qi flowing, bringing forth the ten thousand things.\"",
        chinese: "问：昨天您说没有天地之前，毕竟先有理，这是什么意思？答：没有天地之前，毕竟也只有理。有这个理，才有这个天地；如果没有这个理，也就没有天地、没有人、没有物，什么都无所承载。有理，便有气流行，生育万物。",
        englishSource: ownEN, originalLang: "原文")],
    "zhuziyulei:1": [Passage(ref: "朱子語類·卷九十四·周子之書·太極圖（四庫本，標點為本應用所加）",
        original: "或問太極。曰：太極只是箇極好至善底道理。人人有一太極，物物有一太極。周子所謂太極，是天地人物萬善至好底表德。",
        english: "Someone asked about the Supreme Ultimate. Answer: \"The Supreme Ultimate is simply the most excellent and supremely good principle. Every person has a Supreme Ultimate; every thing has a Supreme Ultimate. What Master Zhou called the Supreme Ultimate is the name for all the excellence of heaven, earth, people and things.\"",
        chinese: "有人问太极。答：太极只是一个极好、至善的道理。每个人都有一个太极，每个物都有一个太极。周敦颐所说的太极，是天地人物一切善的总称。",
        englishSource: ownEN, originalLang: "原文")],
    "zhuangzi:0": [Passage(ref: "莊子·秋水",
        original: "莊子與惠子遊於濠梁之上。莊子曰：「儵魚出游從容，是魚樂也。」 惠子曰：「子非魚，安知魚之樂？」 莊子曰：「子非我，安知我不知魚之樂？」",
        english: "Chuang Tzŭ and Hui Tzŭ had strolled on to the bridge over the Hao, when the former observed, \"See how the minnows are darting about! That is the pleasure of fishes.\" \"You not being a fish yourself,\" said Hui Tzŭ, \"how can you possibly know in what consists the pleasure of fishes?\" \"And you not being I,\" retorted Chuang Tzŭ, \"how can you know that I do not know?\"",
        chinese: "庄子和惠子在濠水的桥上游玩。庄子说：“你看鲦鱼游得多么从容，这是鱼的快乐啊。”惠子说：“你不是鱼，怎么知道鱼的快乐？”庄子说：“你不是我，怎么知道我不知道鱼的快乐？”",
        englishSource: "Giles 英译（1889）", originalLang: "原文")],
    "zhuangzi:1": [Passage(ref: "莊子·齊物論",
        original: "昔者莊周夢為胡蝶，栩栩然胡蝶也，自喻適志與！不知周也。俄然覺，則蘧蘧然周也。不知周之夢為胡蝶與，胡蝶之夢為周與？",
        english: "Once upon a time, I, Chuang Tzŭ, dreamt I was a butterfly, fluttering hither and thither, to all intents and purposes a butterfly. … Suddenly, I awaked, and there I lay, myself again. Now I do not know whether I was then a man dreaming I was a butterfly, or whether I am now a butterfly dreaming I am a man.",
        chinese: "从前庄周梦见自己变成蝴蝶，翩翩飞舞，完全是一只蝴蝶，自在得意，忘了自己是庄周。忽然醒来，自己分明又是庄周。不知道是庄周做梦变成了蝴蝶，还是蝴蝶做梦变成了庄周。",
        englishSource: "Giles 英译（1889）", originalLang: "原文")],
]

// MARK: - 动画

func drawFourSprouts(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 7, 8])
    let names = [("恻隐", "仁"), ("羞恶", "义"), ("辞让", "礼"), ("是非", "智")]
    let ground = h * 0.78
    if b == 0 {
        // 孺子将入于井
        ring(&ctx, w * 0.62, ground - 6, 26, Moon.silver, 2)
        let k = smooth(p / 0.8)
        dot(&ctx, lerp(w * 0.25, w * 0.55, k), ground - 30, 9, Moon.gold)
        label(&ctx, "孺子", lerp(w * 0.25, w * 0.55, k), ground - 52, Moon.gold, size: 12)
        let shock = smooth((p - 0.5) / 0.3)
        dot(&ctx, w * 0.2, ground - 40, 14, Moon.silver)
        if shock > 0 { ring(&ctx, w * 0.2, ground - 40, 20 + 22 * shock, Moon.violet.opacity(1 - shock), 2) }
        label(&ctx, "怵惕恻隐", w * 0.2, ground - 78, Moon.violet.opacity(shock), size: 12)
        headline(&ctx, "乍见孺子将入于井", size)
    } else {
        line(&ctx, 20, ground, w - 20, ground, Color.primary.opacity(0.25), 2)
        for (i, n) in names.enumerated() {
            let x = w * (0.17 + 0.22 * Double(i))
            let grow = b == 1 ? smooth(p / 0.7) * 0.25 : 0.25 + 0.75 * smooth(p / 0.8)
            let top = ground - grow * h * 0.5
            line(&ctx, x, ground, x, top, Moon.gold.opacity(0.8), 3)
            let leaf = 6 + 22 * grow
            dot(&ctx, x - leaf * 0.5, top + 8, leaf * 0.45, Moon.gold.opacity(0.7))
            dot(&ctx, x + leaf * 0.5, top + 4, leaf * 0.45, Moon.gold.opacity(0.7))
            label(&ctx, n.0, x, ground + 18, Moon.dim, size: 12)
            if b == 2 && p > 0.6 { label(&ctx, n.1, x, top - 24, Moon.gold, size: 18) }
        }
        headline(&ctx, b == 1 ? "四端：人皆有之，如有四体" : "扩而充之：长成仁义礼智", size, b == 2 ? Moon.gold : .primary)
    }
    caption(&ctx, "端 = 萌芽", size)
}

func drawPeopleFirst(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 8, 7])
    let rows = ["君", "社稷", "民"]
    let k = b == 0 ? 0 : (b == 1 ? smooth(p / 0.8) : 1)
    for (i, r) in rows.enumerated() {
        // 旧序：君在上面最宽；新序：民最宽
        let oldW = [0.8, 0.55, 0.3][i], newW = [0.22, 0.5, 0.86][i]
        let bw = w * lerp(oldW, newW, k)
        let y = h * (0.28 + 0.2 * Double(i))
        let col: Color = i == 2 ? Moon.gold : (i == 0 ? Moon.violet : Moon.silver)
        box(&ctx, w / 2 - bw / 2, y - 18, bw, 36, col.opacity(i == 2 ? 0.4 + 0.6 * k : 1))
        label(&ctx, r, w / 2, y, .primary, size: 15)
    }
    if b == 2 {
        let n = 40
        for i in 0..<n {
            let x = w * 0.08 + Double(i) / Double(n - 1) * w * 0.84
            blob(&ctx, x, h * 0.76 + 6 * sin(t * 2 + Double(i)), 2.5, Moon.gold.opacity(0.8))
        }
        label(&ctx, "得乎丘民而为天子", w / 2, h * 0.86, Moon.gold, size: 13)
    }
    let titles = ["通常的想象：君最重", "孟子重新排序", "民为贵，社稷次之，君为轻"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "宽度 = 重要性", size)
}

func drawTwoHandles(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 8, 8])
    let king = (w / 2, h * 0.32)
    let holder = b == 2 ? (lerp(king.0, w * 0.22, smooth(p / 0.6)), lerp(king.1, h * 0.62, smooth(p / 0.6))) : king
    dot(&ctx, king.0, king.1, 22, Moon.gold.opacity(b == 2 ? 0.4 + 0.6 * (1 - smooth(p / 0.6)) : 1))
    label(&ctx, "君", king.0, king.1 - 34, Moon.gold, size: 14)
    let ministers = 5
    for i in 0..<ministers {
        let x = w * (0.15 + 0.175 * Double(i)), y = h * 0.66
        let sway = b >= 1 ? 4 * sin(t * 2 + Double(i)) : 0
        dot(&ctx, x + sway, y, 11, i == 0 && b == 2 ? Moon.violet : Moon.silver)
        if b >= 1 {
            line(&ctx, holder.0 - 8, holder.1 + 10, x - 4, y - 12, Color.red.opacity(0.45), 1.5)
            line(&ctx, holder.0 + 8, holder.1 + 10, x + 4, y - 12, Moon.gold.opacity(0.6), 1.5)
        }
    }
    label(&ctx, "臣", w * 0.85, h * 0.66 + 26, Moon.dim, size: 12)
    if b >= 1 {
        label(&ctx, "刑", holder.0 - 34, holder.1 + 10, .red.opacity(0.8), size: 15)
        label(&ctx, "德", holder.0 + 34, holder.1 + 10, Moon.gold, size: 15)
    }
    if b == 2 && p > 0.6 { label(&ctx, "权臣", w * 0.22, h * 0.62 - 30, Moon.violet, size: 13) }
    let titles = ["君主居上，群臣在下", "两个把柄：杀戮之谓刑，庆赏之谓德", "把柄若落到臣下手中，君就失去了国"]
    headline(&ctx, titles[b], size, b == 1 ? Moon.gold : .primary)
    caption(&ctx, "赏罚之权必须出于君主自己", size)
}

func drawLawAsTeaching(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 8])
    let fade = b == 0 ? 1 : (b == 1 ? 1 - smooth(p / 0.6) : 0)
    for i in 0..<5 {
        let x = w * (0.18 + 0.16 * Double(i)), y = h * 0.3
        box(&ctx, x - 9, y - 22, 18, 44, Moon.silver.opacity(0.8 * fade))
    }
    label(&ctx, "书简之文 · 先王之语", w / 2, h * 0.3 + 40, Moon.dim.opacity(fade), size: 12)
    if b >= 1 {
        let k = smooth(p / 0.6)
        box(&ctx, w / 2 - 40, h * 0.3 - 22, 80, 44, Moon.gold.opacity(b == 1 ? k : 1))
        label(&ctx, "法", w / 2, h * 0.3, .primary.opacity(b == 1 ? k : 1), size: 20)
    }
    // 百姓：从散乱到整齐
    let n = 24
    let order = b == 2 ? smooth(p / 0.7) : 0
    for i in 0..<n {
        let s = Double(i)
        let rx = w * 0.1 + hash01(s) * w * 0.8, ry = h * 0.58 + hash01(s + 9) * h * 0.28
        let gx = w * (0.14 + 0.72 * Double(i % 8) / 7), gy = h * (0.6 + 0.11 * Double(i / 8))
        let x = lerp(rx + sin(t + s) * 6, gx, order), y = lerp(ry + cos(t * 0.8 + s) * 6, gy, order)
        blob(&ctx, x, y, 4, (b == 2 ? Moon.gold : Moon.silver).opacity(0.85))
    }
    if b == 2 { label(&ctx, "吏", w * 0.9, h * 0.5, Moon.gold, size: 14) }
    let titles = ["儒墨称颂先王，书简满天下", "去掉书简与先王之语，只留下法", "以法为教，以吏为师：言动皆轨于法"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "古今异俗，新故异备", size)
}

func drawLiBeforeQi(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 7, 8])
    let cx = w / 2, cy = h * 0.45
    dot(&ctx, cx, cy, 14 + 3 * sin(t * 1.4), Moon.gold)
    label(&ctx, "理", cx, cy - 32, Moon.gold, size: 16)
    if b >= 1 {
        let n = 60
        let k = b == 1 ? smooth(p / 0.8) : 1
        for i in 0..<Int(Double(n) * k) {
            let s = Double(i)
            let a = s * 2.399 + t * 0.25
            let r = 30 + fract(s * 0.137 + t * 0.06) * min(w, h) * 0.42
            blob(&ctx, cx + cos(a) * r, cy + sin(a) * r * 0.8, 2.5, Moon.silver.opacity(0.7))
        }
        label(&ctx, "气流行", cx + min(w, h) * 0.36, cy - min(w, h) * 0.3, Moon.silver, size: 12)
    }
    if b == 2 {
        let k = smooth(p / 0.7)
        line(&ctx, 30, h * 0.82, 30 + (w - 60) * k, h * 0.82, Moon.silver, 2)
        let things = ["天", "地", "人", "物"]
        for (i, s) in things.enumerated() where k > Double(i) * 0.25 {
            let x = w * (0.2 + 0.2 * Double(i))
            dot(&ctx, x, h * 0.74, 10, Moon.violet)
            label(&ctx, s, x, h * 0.74 - 22, .primary, size: 13)
        }
    }
    let titles = ["未有天地之先，毕竟也只是理", "有理，便有气流行", "发育万物：有此理，便有此天地"]
    headline(&ctx, titles[b], size, b == 0 ? Moon.gold : .primary)
    caption(&ctx, "理在逻辑上先于气", size)
}

func drawMoonInRivers(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 8, 8])
    let mx = w / 2, my = h * 0.2
    dot(&ctx, mx, my, 22, Moon.gold)
    label(&ctx, "太极", mx + 44, my, Moon.gold, size: 13)
    let waters: [(Double, Double, Double)] = [(0.15, 0.6, 46), (0.4, 0.72, 60), (0.68, 0.58, 40), (0.85, 0.78, 34), (0.28, 0.86, 30), (0.58, 0.88, 26)]
    for (i, wv) in waters.enumerated() {
        let x = w * wv.0, y = h * wv.1, r = wv.2
        ring(&ctx, x, y, r, Moon.silver.opacity(0.5), 1.5)
        let show = b == 0 ? 0 : (b == 1 ? smooth((p - Double(i) * 0.12) / 0.2) : 1)
        if show > 0 {
            dot(&ctx, x + 2 * sin(t * 2 + Double(i)), y, r * 0.28, Moon.gold.opacity(show))
            if b == 1 { line(&ctx, mx, my + 22, x, y - r * 0.3, Moon.gold.opacity(0.25 * show), 1, dash: [3, 4]) }
        }
    }
    if b == 2 { label(&ctx, "每一处都是完整的月", w / 2, h * 0.45, Moon.gold, size: 13) }
    let titles = ["天上只有一个月亮", "散在江湖，随处可见", "人人有一太极，物物有一太极"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "理一分殊：月并没有被分开", size)
}
