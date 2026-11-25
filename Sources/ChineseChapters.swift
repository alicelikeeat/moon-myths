import SwiftUI

// MARK: - 章节（键：著作 id）

let chineseWorkChapters: [String: [Chapter]] = [
    "daodejing": [
        Chapter(part: "核心观点", title: "有无相生",
                thesis: "美与恶、有与无、难与易，彼此依存而生，没有一方能单独成立。",
                formula: "有 ⇄ 无 ，难 ⇄ 易 ，长 ⇄ 短 ，高 ⇄ 下",
                points: ["一旦把某物认作“美”，“恶”的观念也随之出现。",
                         "对立的双方互相规定、互相成就。",
                         "所以圣人“处无为之事，行不言之教”。"],
                body: .canvas(drawYouWu)),
        Chapter(part: "核心观点", title: "上善若水",
                thesis: "最高的善像水：利养万物而不争，安处众人厌恶的低处。",
                formula: "柔弱 · 不争 · 处下  ⟹  几于道",
                points: ["水滋养万物，却不与万物相争。",
                         "水总流向众人所厌恶的低处。",
                         "因为不争，所以没有过失。"],
                body: .canvas(drawWater)),
        Chapter(part: "核心观点", title: "道生一，一生二",
                thesis: "道生一，一生二，二生三，三生万物。",
                formula: "道 → 一 → 二 → 三 → 万物",
                points: ["万物都从“道”中化生而出。",
                         "“二”常被理解为阴与阳，“三”为阴阳交和之气。",
                         "万物负阴而抱阳，冲气以为和。"],
                body: .canvas(drawDaoShengYi)),
    ],
    "lunyu": [
        Chapter(part: "核心观点", title: "吾十有五而志于学",
                thesis: "孔子自述一生的修养历程：从立志求学到从心所欲而不逾矩。",
                formula: "15 志学 → 30 立 → 40 不惑 → 50 知天命 → 60 耳顺 → 70 从心所欲",
                points: ["修养是一个循序渐进、终身不断的过程。",
                         "最终境界：随心而行，却自然合于规矩。"],
                body: .canvas(drawConfuciusAges)),
        Chapter(part: "核心观点", title: "己所不欲，勿施于人",
                thesis: "推己及人：自己不愿承受的，不要加在别人身上。",
                formula: "我 ⇏ 不欲 ⟹ 人 ⇏ 不欲",
                points: ["仲弓问什么是仁，孔子以此作答之一。",
                         "子贡问一言以终身行之，孔子答：“其恕乎！”",
                         "这是“恕”的消极表述，与“立人”“达人”的积极表述相对。"],
                body: .canvas(drawShu)),
    ],
    "mozi": [
        Chapter(part: "核心观点", title: "兼爱",
                thesis: "看待别人的国、家、身，要像看待自己的一样。",
                formula: "爱(人) = 爱(己)",
                points: ["天下之乱，起于人人只爱自己而不爱别人。",
                         "“别爱”由近及远递减，“兼爱”一视同仁。",
                         "兼相爱，交相利。"],
                body: .canvas(drawJianAi)),
        Chapter(part: "核心观点", title: "非攻",
                thesis: "偷桃李是不义，攻打别国伤害更大，却被称为义，这是不知义与不义的区别。",
                formula: "亏人愈多 ⟹ 不义愈甚",
                points: ["从偷桃李、偷鸡犬，到杀害无辜，罪越来越重。",
                         "攻国伤害最大，却被赞誉为义。",
                         "墨子指出：这是判断标准的自相矛盾。"],
                body: .canvas(drawFeiGong)),
    ],
    "xunzi": [
        Chapter(part: "核心观点", title: "化性起伪",
                thesis: "人性本恶，善是后天人为（伪）的结果。",
                formula: "性（天生） + 伪（人为） ⟹ 善",
                points: ["弯曲的木材要经过矫正工具蒸烤才能变直。",
                         "人性需要师法教化与礼义规范。",
                         "“伪”指人为的努力，不是虚伪。"],
                body: .canvas(drawStraighten)),
        Chapter(part: "核心观点", title: "积土成山",
                thesis: "学习在于积累：积土成山，积水成渊，积善成德。",
                formula: "Σ 跬步 = 千里",
                points: ["不积跬步，无以至千里。",
                         "骐骥一跃，不能十步；驽马十驾，功在不舍。",
                         "坚持比天赋更重要。"],
                body: .canvas(drawAccumulate)),
    ],
    "chunqiufanlu": [
        Chapter(part: "核心观点", title: "天人之际",
                thesis: "天与人相通相应，合而为一。",
                formula: "天 ⇄ 人",
                points: ["天道与人事同属一个秩序。",
                         "人的作为会引起天的回应，这就是“天人感应”。",
                         "董仲舒以此论证君主应顺天行事。"],
                body: .canvas(drawTianRen)),
    ],
    "tanjing": [
        Chapter(part: "核心观点", title: "两首偈",
                thesis: "神秀主张时时勤拂拭；慧能说本来无一物，何处惹尘埃。",
                formula: "渐修  vs  顿悟",
                points: ["神秀的偈：心如明镜，要不断擦拭，不让尘埃沾染。",
                         "慧能的偈：连镜台都不存在，尘埃无处可落。",
                         "五祖弘忍因此把衣钵传给慧能。"],
                body: .canvas(drawTwoVerses)),
        Chapter(part: "核心观点", title: "风动、幡动、心动",
                thesis: "不是风动，不是幡动，是你们的心在动。",
                formula: "风动？幡动？⟹ 心动",
                points: ["两位僧人争论：一说风动，一说幡动。",
                         "慧能指出：争论的根源在心。"],
                body: .canvas(drawFlag)),
    ],
    "chuanxilu": [
        Chapter(part: "核心观点", title: "知行合一",
                thesis: "知是行的开始，行是知的完成；二者本是一回事。",
                formula: "知 ≡ 行",
                points: ["徐爱认为：知道该孝却不孝，可见知与行是两件事。",
                         "阳明回答：那是被私欲隔断，不是真知。",
                         "真知必能行，不行只是未知。"],
                body: .canvas(drawZhiXing)),
        Chapter(part: "核心观点", title: "山中观花",
                thesis: "你未看花时，花与你的心同归于寂；你来看时，花的颜色一时明白起来。",
                formula: "花 ∈ 心",
                points: ["有人问：深山里的花自开自落，与我心何干？",
                         "阳明并非否认花的存在，而是说意义在心物相遇中显现。"],
                body: .canvas(drawFlower)),
    ],
    "zhuangzi": [
        Chapter(part: "核心观点", title: "濠梁之辩",
                thesis: "庄子与惠子争论：你不是鱼，怎么知道鱼的快乐？",
                formula: "子非鱼，安知鱼之乐？",
                points: ["惠子：你不是鱼，不能知道鱼的快乐。",
                         "庄子：你不是我，怎么知道我不知道？",
                         "这场辩论关于认识他心的可能。"],
                body: .canvas(drawFishDebate)),
        Chapter(part: "核心观点", title: "庄周梦蝶",
                thesis: "不知是庄周梦为蝴蝶，还是蝴蝶梦为庄周。",
                formula: "庄周 ⇄ 蝴蝶 （物化）",
                points: ["梦中只觉是蝴蝶，不知自己是庄周。",
                         "醒来才发现自己是庄周。",
                         "二者必有分别，这种转化叫“物化”。"],
                body: .canvas(drawButterfly)),
    ],
]

func workParts(_ id: String) -> [String] {
    var seen: [String] = []
    for c in workChapters[id] ?? [] where !seen.contains(c.part) { seen.append(c.part) }
    return seen
}

// MARK: - 原文（逐字核对自公有领域文本）

private let legge = "Legge 英译"
private let ownEN = "本应用英译"

let chineseWorkPassages: [String: [Passage]] = [
    "daodejing:0": [Passage(ref: "《道德經》第二章",
        original: "天下皆知美之為美，斯惡矣；皆知善之為善，斯不善矣。故有無相生，難易相成，長短相形，高下相傾，音聲相和，前後相隨。",
        english: "All in the world know the beauty of the beautiful, and in doing this they have (the idea of) what ugliness is; they all know the skill of the skilful, and in doing this they have (the idea of) what the want of skill is.",
        chinese: "天下人都知道美之所以为美，丑的观念也就有了；都知道善之所以为善，不善的观念也就有了。所以有与无相互生成，难与易相互促成，长与短相互比较，高与下相互依存。",
        englishSource: legge, originalLang: "文言")],
    "daodejing:1": [Passage(ref: "《道德經》第八章",
        original: "上善若水。水善利萬物而不爭。處眾人之所惡，故幾於道。",
        english: "The highest excellence is like (that of) water. The excellence of water appears in its benefiting all things, and in its occupying, without striving (to the contrary), the low place which all men dislike. Hence (its way) is near to (that of) the Tao.",
        chinese: "最高的善像水一样。水善于滋养万物而不与之相争，停留在众人都厌恶的低处，所以最接近于道。",
        englishSource: legge, originalLang: "文言")],
    "daodejing:2": [Passage(ref: "《道德經》第四十二章",
        original: "道生一，一生二，二生三，三生萬物。萬物負陰而抱陽，沖氣以為和。",
        english: "The Tao produced One; One produced Two; Two produced Three; Three produced All things.",
        chinese: "道产生一，一产生二，二产生三，三产生万物。万物背阴而向阳，阴阳之气相互激荡而成和谐。",
        englishSource: legge, originalLang: "文言")],
    "lunyu:0": [Passage(ref: "《論語·為政第二》",
        original: "子曰：「吾十有五而志于學，三十而立，四十而不惑，五十而知天命，六十而耳順，七十而從心所欲，不踰矩。」",
        english: "At fifteen, I had my mind bent on learning. 'At thirty, I stood firm. 'At forty, I had no doubts. 'At fifty, I knew the decrees of Heaven. … 'At sixty, my ear was an obedient organ for the reception of truth. 'At seventy, I could follow what my heart desired, without transgressing what was right.'",
        chinese: "孔子说：“我十五岁立志求学，三十岁能自立，四十岁不再迷惑，五十岁懂得天命，六十岁听到什么都能理解，七十岁随心所欲却不越出规矩。”",
        englishSource: legge, originalLang: "文言")],
    "lunyu:1": [Passage(ref: "《論語·顏淵第十二》",
        original: "仲弓問仁。子曰：「出門如見大賓，使民如承大祭。己所不欲，勿施於人。在邦無怨，在家無怨。」",
        english: "Chung-kung asked about perfect virtue. The Master said, 'It is, when you go abroad, to behave to every one as if you were receiving a great guest; to employ the people as if you were assisting at a great sacrifice; not to do to others as you would not wish done to yourself; to have no murmuring against you in the country, and none in the family.'",
        chinese: "仲弓问什么是仁。孔子说：“出门做事如同接待贵宾，役使百姓如同承办大祭；自己不愿意的，不要施加给别人。这样在诸侯国里没有怨恨，在卿大夫家里也没有怨恨。”",
        englishSource: legge, originalLang: "文言")],
    "mozi:0": [Passage(ref: "《墨子·兼愛中》",
        original: "視人之國若視其國，視人之家若視其家，視人之身若視其身。",
        english: "Regard the states of others as one's own state, the houses of others as one's own house, and the persons of others as one's own person.",
        chinese: "看待别人的国家就像看待自己的国家，看待别人的家族就像看待自己的家族，看待别人的身体就像看待自己的身体。",
        englishSource: ownEN, originalLang: "文言")],
    "mozi:1": [Passage(ref: "《墨子·非攻上》",
        original: "今至大為攻國，則弗知非，從而譽之，謂之義。此可謂知義與不義之別乎？",
        english: "Now when it comes to the greatest wrong of all, attacking another state, they do not know it is wrong; they praise it and call it righteous. Can this be called knowing the difference between righteousness and unrighteousness?",
        chinese: "如今对于最大的不义——攻打别国，却不知道它是错的，反而赞美它，称之为义。这能说是懂得义与不义的区别吗？",
        englishSource: ownEN, originalLang: "文言")],
    "xunzi:0": [Passage(ref: "《荀子·性惡篇第二十三》",
        original: "人之性惡，其善者偽也。……故枸木必將待檃栝烝矯然後直，鈍金必將待礱厲然後利。",
        english: "Human nature is bad; its goodness is the result of conscious effort. … Thus crooked wood must await the press-frame and steaming before it becomes straight; blunt metal must await the whetstone before it becomes sharp.",
        chinese: "人的本性是恶的，人的善良是人为努力的结果。……所以弯曲的木材必须经过矫正工具的蒸烤矫揉才能变直，钝的金属必须经过磨砺才能锋利。",
        englishSource: ownEN, originalLang: "文言")],
    "xunzi:1": [Passage(ref: "《荀子·勸學篇第一》",
        original: "積土成山，風雨興焉；積水成淵，蛟龍生焉；積善成德，而神明自得，聖心備焉。故不積蹞步，無以致千里；不積小流，無以成江海。",
        english: "Pile up earth into a mountain, and wind and rain will arise from it; pile up water into a deep pool, and dragons will be born in it; pile up good deeds into virtue, and spiritual clarity will come of itself. Without accumulating half-steps, one cannot reach a thousand li; without accumulating small streams, one cannot form rivers and seas.",
        chinese: "堆积土石成了高山，风雨就从那里兴起；汇积水流成了深渊，蛟龙就在那里生长；积累善行成为美德，自然会达到很高的智慧，具备圣人的心境。所以不积累一步半步，就无法到达千里之外；不汇聚细小的水流，就无法形成江海。",
        englishSource: ownEN, originalLang: "文言")],
    "chunqiufanlu:0": [Passage(ref: "《春秋繁露·深察名號第三十五》（原文无标点）",
        original: "天人之際合而為一同而通理動而相益順而相受謂之德道",
        english: "At the boundary of Heaven and man, the two unite as one: sharing one principle, they benefit each other when they move and receive from each other when they accord; this is called the Way of virtue.",
        chinese: "天与人相交之处，合而为一：同循一理，动则相互助益，顺则相互承受，这叫作德之道。",
        englishSource: ownEN, originalLang: "文言")],
    "tanjing:0": [Passage(ref: "《六祖壇經·自序品第一》神秀偈",
        original: "身是菩提樹，心如明鏡臺，時時勤拂拭，勿使惹塵埃。",
        english: "The body is the Bodhi tree, the mind is like a bright mirror stand; wipe it diligently at all times, and let no dust alight.",
        chinese: "身体是菩提树，心如明亮的镜台，要时时勤加擦拭，不让它沾染尘埃。",
        englishSource: ownEN, originalLang: "文言"),
        Passage(ref: "《六祖壇經·自序品第一》慧能偈",
        original: "菩提本無樹，明鏡亦非臺，本來無一物，何處惹塵埃。",
        english: "Bodhi originally has no tree, the bright mirror is no stand either; originally there is not a single thing—where could dust alight?",
        chinese: "菩提本来没有树，明镜也不是台；本来空无一物，哪里会沾染尘埃？",
        englishSource: ownEN, originalLang: "文言")],
    "tanjing:1": [Passage(ref: "《六祖壇經·自序品第一》",
        original: "因二僧論風幡義，一曰風動，一曰幡動，議論不已。惠能進曰：「不是風動，不是幡動，仁者心動。」",
        english: "Two monks were debating the flag in the wind: one said the wind moved, the other said the flag moved, and they argued without end. Huineng stepped forward and said: “It is not the wind that moves, nor the flag that moves; it is your minds that move.”",
        chinese: "两位僧人议论风吹幡动，一个说是风在动，一个说是幡在动，争论不休。慧能上前说：“不是风在动，也不是幡在动，是你们的心在动。”",
        englishSource: ownEN, originalLang: "文言")],
    "chuanxilu:0": [Passage(ref: "《傳習錄》徐愛錄",
        original: "某嘗說知是行的主意。行是知的功夫。知是行之始。行是知之成。若會得時，只說一箇知，已自有行在。只說一箇行，已自有知在。",
        english: "I have said that knowing is the intent of acting, and acting is the effort of knowing; knowing is the beginning of acting, and acting is the completion of knowing. If one grasps this, then in speaking only of knowing, acting is already present; in speaking only of acting, knowing is already present.",
        chinese: "我曾说，知是行的主旨，行是知的功夫；知是行的开端，行是知的完成。如果领会了这一点，只说一个“知”，其中已经有“行”；只说一个“行”，其中已经有“知”。",
        englishSource: ownEN, originalLang: "文言")],
    "chuanxilu:1": [Passage(ref: "《傳習錄》黃省曾錄",
        original: "先生曰：「你未看此花時，此花與汝心同歸於寂：你來看此花時，則此花顏色一時明白起來：便知此花不在你的心外。」",
        english: "The Master said: “When you have not yet looked at this flower, the flower and your mind both return to stillness. When you come to look at it, its colours at once become clear. From this you know the flower is not outside your mind.”",
        chinese: "先生说：“你没有看这朵花的时候，这花和你的心一同归于寂静；你来看这朵花的时候，这花的颜色就一下子明白起来，由此可知这花不在你的心外。”",
        englishSource: ownEN, originalLang: "文言")],
    "zhuangzi:0": [Passage(ref: "Chuang Tzŭ（Giles 英译，1889）秋水篇",
        original: "Chuang Tzŭ and Hui Tzŭ had strolled on to the bridge over the Hao, when the former observed, \"See how the minnows are darting about! That is the pleasure of fishes.\" \"You not being a fish yourself,\" said Hui Tzŭ, \"how can you possibly know in what consists the pleasure of fishes?\" \"And you not being I,\" retorted Chuang Tzŭ, \"how can you know that I do not know?\"",
        english: nil,
        chinese: "庄子和惠子在濠水的桥上游玩。庄子说：“你看鲦鱼游得多么从容，这是鱼的快乐啊。”惠子说：“你不是鱼，怎么知道鱼的快乐？”庄子说：“你不是我，怎么知道我不知道鱼的快乐？”",
        originalLang: "English（Giles 译）")],
    "zhuangzi:1": [Passage(ref: "Chuang Tzŭ（Giles 英译，1889）齐物论",
        original: "Once upon a time, I, Chuang Tzŭ, dreamt I was a butterfly, fluttering hither and thither, to all intents and purposes a butterfly. … Suddenly, I awaked, and there I lay, myself again. Now I do not know whether I was then a man dreaming I was a butterfly, or whether I am now a butterfly dreaming I am a man.",
        english: nil,
        chinese: "从前庄周梦见自己变成蝴蝶，翩翩飞舞，完全是一只蝴蝶……忽然醒来，自己分明又是庄周。不知道是庄周做梦变成了蝴蝶，还是蝴蝶做梦变成了庄周。",
        originalLang: "English（Giles 译）")],
]

// MARK: - 动画

private func pairColor(_ i: Int) -> Color { i % 2 == 0 ? Moon.gold : Moon.violet }

func drawYouWu(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 7])
    let pairs = [("美", "恶"), ("有", "无"), ("难", "易"), ("长", "短"), ("高", "下")]
    switch b {
    case 0:
        let k = smooth(p / 0.5)
        dot(&ctx, w * 0.32, h * 0.45, 30, Moon.gold)
        label(&ctx, "美", w * 0.32, h * 0.45, .primary, size: 18)
        dot(&ctx, w * 0.68, h * 0.45, 30 * k, Moon.violet.opacity(k))
        if k > 0.3 { label(&ctx, "恶", w * 0.68, h * 0.45, .primary, size: 18) }
        headline(&ctx, "一旦认出“美”，“恶”同时出现", size)
    case 1:
        let shown = min(5, 1 + Int(p * 5))
        for i in 0..<shown {
            let y = 60 + Double(i) * (h - 120) / 5 + 20
            let swing = sin(t * 0.8 + Double(i))
            let ra = 16 + 6 * swing, rb = 16 - 6 * swing
            line(&ctx, w * 0.32, y, w * 0.68, y, Color.primary.opacity(0.2), 1)
            dot(&ctx, w * 0.32, y, ra, Moon.gold)
            dot(&ctx, w * 0.68, y, rb, Moon.violet)
            label(&ctx, pairs[i].0, w * 0.32, y, .primary, size: 14)
            label(&ctx, pairs[i].1, w * 0.68, y, .primary, size: 14)
        }
        headline(&ctx, "一方增，一方减；相生、相成、相形、相倾", size)
    default:
        let k = smooth(p / 0.7)
        for i in 0..<5 {
            let a = Double(i) / 5 * 2 * Double.pi + t * 0.15
            let r = lerp(min(w, h) * 0.32, 18, k)
            let x = w / 2 + cos(a) * r, y = h / 2 + sin(a) * r
            dot(&ctx, x - 12 * (1 - k), y, 14, Moon.gold)
            dot(&ctx, x + 12 * (1 - k), y, 14, Moon.violet)
        }
        if k > 0.8 { label(&ctx, "相生", w / 2, h / 2 + 50, .primary, size: 16) }
        headline(&ctx, "对立的双方彼此依存", size)
    }
    caption(&ctx, "有无相生，难易相成，长短相形，高下相倾", size)
}

func drawWater(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 7, 7])
    // 阶梯地形：左高右低
    let steps: [(Double, Double)] = [(0, 0.35), (0.25, 0.5), (0.5, 0.65), (0.75, 0.8)]
    var ground = Path()
    ground.move(to: CGPoint(x: 0, y: h))
    for (x0, y0) in steps {
        ground.addLine(to: CGPoint(x: w * x0, y: h * y0))
        ground.addLine(to: CGPoint(x: w * (x0 + 0.25), y: h * y0))
    }
    ground.addLine(to: CGPoint(x: w, y: h))
    ground.closeSubpath()
    fillPath(&ctx, ground, Color.primary.opacity(0.08))
    // 低处水池
    let fill = b == 2 ? smooth(p) : (b == 1 ? 0.2 : 0)
    let poolTop = h * 0.8 - 30 * fill
    fillPath(&ctx, Path(CGRect(x: w * 0.75, y: poolTop, width: w * 0.25, height: h * 0.8 - poolTop + 2)), Moon.silver.opacity(0.45))
    // 水滴沿台阶流下
    for i in 0..<10 {
        let u = fract(t * 0.12 + Double(i) / 10)
        let seg = min(3, Int(u * 4)), f = u * 4 - Double(seg)
        let (x0, y0) = steps[seg]
        var x = w * (x0 + 0.25 * f), y = h * y0 - 8
        if f > 0.85, seg < 3 { y += (h * steps[seg + 1].1 - h * y0) * (f - 0.85) / 0.15 }
        if b >= 1, seg == 1 { y -= 10 * sin(f * Double.pi) ; x += 0 }   // 绕过石头
        dot(&ctx, x, y, 6, Moon.silver)
    }
    if b >= 1 {
        dot(&ctx, w * 0.375, h * 0.5 - 14, 14, Moon.violet)
        label(&ctx, "石", w * 0.375, h * 0.5 - 14, .primary, size: 11)
    }
    let titles = ["水往低处流", "遇到阻碍，绕行而不争", "汇聚在众人厌恶的低处"]
    headline(&ctx, titles[b], size)
    caption(&ctx, "上善若水：利万物而不争", size)
}

func drawDaoShengYi(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [5, 5, 5, 7])
    let cx = w / 2, cy = h / 2
    let k = smooth(p / 0.6)
    switch b {
    case 0:
        dot(&ctx, cx, cy, 10 + 18 * k, Moon.gold)
        label(&ctx, "一", cx, cy, .primary, size: 18)
        headline(&ctx, "道生一", size)
    case 1:
        dot(&ctx, cx - 50 * k, cy, 22, Moon.gold); label(&ctx, "阳", cx - 50 * k, cy, .primary, size: 14)
        dot(&ctx, cx + 50 * k, cy, 22, Moon.violet); label(&ctx, "阴", cx + 50 * k, cy, .primary, size: 14)
        headline(&ctx, "一生二：阴与阳", size)
    case 2:
        dot(&ctx, cx - 50, cy + 20, 22, Moon.gold)
        dot(&ctx, cx + 50, cy + 20, 22, Moon.violet)
        dot(&ctx, cx, cy - 60 * k, 18 * k + 4, Moon.silver)
        line(&ctx, cx - 50, cy + 20, cx, cy - 60 * k, Color.primary.opacity(0.25))
        line(&ctx, cx + 50, cy + 20, cx, cy - 60 * k, Color.primary.opacity(0.25))
        label(&ctx, "冲气", cx, cy - 60 * k - 30, Moon.silver, size: 12)
        headline(&ctx, "二生三：阴阳相交而生和气", size)
    default:
        let n = 40
        for i in 0..<n {
            let s = Double(i)
            let a = hash01(s) * 2 * Double.pi + t * 0.05
            let r = (30 + hash01(s + 5) * min(w, h) * 0.38) * smooth(p / 0.8)
            dot(&ctx, cx + cos(a) * r, cy + sin(a) * r, i % 3 == 0 ? 6 : 3, i % 2 == 0 ? Moon.gold : Moon.violet)
        }
        headline(&ctx, "三生万物", size)
    }
    caption(&ctx, "万物负阴而抱阳，冲气以为和", size)
}

func drawConfuciusAges(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let stages = [("15", "志于学"), ("30", "而立"), ("40", "不惑"), ("50", "知天命"), ("60", "耳顺"), ("70", "从心所欲，不逾矩")]
    let (b, p) = beats(t, [5, 5, 5, 5, 5, 7])
    let stepW = (w - 60) / 6, stepH = (h - 130) / 6
    for i in 0..<6 {
        let x = 30 + Double(i) * stepW, y = h - 60 - Double(i + 1) * stepH
        box(&ctx, x, y, stepW - 4, stepH * Double(i + 1), i <= b ? Moon.gold : Moon.silver,
            fill: i <= b ? Moon.gold.opacity(0.15) : nil)
        label(&ctx, stages[i].0, x + stepW / 2, y + 14, i <= b ? .primary : Moon.dim, size: 13)
    }
    let x = 30 + (Double(b) + 0.5) * stepW
    let y = h - 60 - Double(b + 1) * stepH - 16 - 6 * sin(t * 2) * (1 - smooth(p))
    dot(&ctx, x, y, 12, Moon.gold)
    headline(&ctx, "\(stages[b].0) 岁：\(stages[b].1)", size, Moon.gold)
    caption(&ctx, "修养是一生循序渐进的攀登", size)
}

func drawShu(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 7])
    let me = (w * 0.3, h * 0.5), other = (w * 0.7, h * 0.5)
    switch b {
    case 0:
        let k = smooth(p / 0.6)
        let bx = lerp(w * 0.05, me.0 - 30, k)
        dot(&ctx, bx, me.1 - 40, 8, .red.opacity(0.8))
        dot(&ctx, me.0, me.1, 28 - 6 * max(0, k - 0.8) * 5, Moon.gold)
        dot(&ctx, other.0, other.1, 28, Moon.violet)
        headline(&ctx, "我不愿承受的……", size)
    case 1:
        let k = smooth(p / 0.5)
        let bx = lerp(me.0 + 30, w / 2, k)
        dot(&ctx, me.0, me.1, 28, Moon.gold)
        dot(&ctx, other.0, other.1, 28, Moon.violet)
        dot(&ctx, bx, me.1 - 40, 8 * (1 - smooth((p - 0.6) / 0.4)), .red.opacity(0.8))
        line(&ctx, w / 2, h * 0.3, w / 2, h * 0.7, Moon.gold.opacity(0.6), 2, dash: [5, 5])
        headline(&ctx, "……推想他人也不愿：停下", size)
    default:
        let g = 0.5 + 0.5 * sin(t * 1.2)
        dot(&ctx, me.0, me.1, 28 + 4 * g, Moon.gold)
        dot(&ctx, other.0, other.1, 28 + 4 * g, Moon.violet)
        line(&ctx, me.0 + 30, me.1, other.0 - 30, other.1, Moon.gold.opacity(0.5), 1.5)
        headline(&ctx, "推己及人：恕", size, Moon.gold)
    }
    label(&ctx, "我", me.0, me.1 + 46, .primary, size: 14)
    label(&ctx, "人", other.0, other.1 + 46, .primary, size: 14)
    caption(&ctx, "己所不欲，勿施于人", size)
}

func drawJianAi(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [8, 8])
    let names = ["身", "家", "国"]
    if b == 0 {
        let cx = w / 2, cy = h / 2
        for i in (0..<3).reversed() {
            let r = 40 + Double(i) * 45
            ring(&ctx, cx, cy, r, Moon.gold.opacity(1 - Double(i) * 0.3), 3 - Double(i))
            label(&ctx, names[i], cx + r - 12, cy - 8, Moon.gold.opacity(1 - Double(i) * 0.3), size: 12)
        }
        dot(&ctx, cx, cy, 16, Moon.gold)
        label(&ctx, "我", cx, cy, .primary, size: 13)
        headline(&ctx, "别爱：越远越淡", size)
    } else {
        let k = smooth(p / 0.5)
        let centers = [(w * 0.25, h * 0.4), (w * 0.75, h * 0.4), (w * 0.5, h * 0.72)]
        for (i, c) in centers.enumerated() {
            ring(&ctx, c.0, c.1, 48, Moon.gold.opacity(0.4 + 0.5 * k), 2)
            dot(&ctx, c.0, c.1, 16, i == 0 ? Moon.gold : Moon.violet)
            label(&ctx, i == 0 ? "我之国" : "人之国", c.0, c.1 + 64, .primary, size: 12)
        }
        for i in 0..<3 {
            let a = centers[i], c = centers[(i + 1) % 3]
            line(&ctx, a.0, a.1, c.0, c.1, Moon.gold.opacity(0.6 * k), 1.5)
        }
        headline(&ctx, "兼爱：视人之国若视其国", size, Moon.gold)
    }
    caption(&ctx, "兼相爱，交相利", size)
}

func drawFeiGong(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [5, 5, 5, 8])
    let acts = [("窃桃李", 0.15), ("攘鸡犬", 0.3), ("杀不辜", 0.55), ("攻国", 1.0)]
    let bw = (w - 80) / 4
    for i in 0...b {
        let x = 40 + Double(i) * bw
        let full = (h - 150) * acts[i].1
        let hh = i == b ? full * smooth(p / 0.5) : full
        box(&ctx, x + 6, h - 70 - hh, bw - 12, max(1, hh), i == 3 ? .red : Moon.silver,
            fill: (i == 3 ? Color.red : Moon.silver).opacity(0.18))
        label(&ctx, acts[i].0, x + bw / 2, h - 52, .primary, size: 13)
        let verdict = i < 3 ? "不义" : (p > 0.55 || b > 3 ? "却称“义”？" : "")
        label(&ctx, verdict, x + bw / 2, h - 86 - hh, i < 3 ? Moon.violet : .red, size: 12)
    }
    headline(&ctx, b < 3 ? "亏人越多，罪越重" : "最大的不义，反被赞誉", size, b < 3 ? .primary : .red)
    caption(&ctx, "此可谓知义与不义之别乎？", size)
}

func drawStraighten(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 8, 6])
    let amp = b == 0 ? 26.0 : (b == 1 ? 26 * (1 - smooth(p / 0.85)) : 0)
    let y = h * 0.5
    var wood = Path()
    for i in 0...60 {
        let x = 40 + Double(i) / 60 * (w - 80)
        let yy = y + amp * sin(Double(i) / 60 * 3 * Double.pi)
        if i == 0 { wood.move(to: CGPoint(x: x, y: yy)) } else { wood.addLine(to: CGPoint(x: x, y: yy)) }
    }
    strokePath(&ctx, wood, Moon.gold, style: StrokeStyle(lineWidth: 10, lineCap: .round))
    if b == 1 {
        let cx = 40 + (w - 80) * smooth(p / 0.85)
        box(&ctx, cx - 22, y - 46, 44, 26, Moon.silver)
        box(&ctx, cx - 22, y + 20, 44, 26, Moon.silver)
        label(&ctx, "檃栝", cx, y - 60, Moon.silver, size: 11)
        for i in 0..<5 { blob(&ctx, cx + Double(i - 2) * 8, y - 70 - fract(t * 0.5 + Double(i) * 0.2) * 30, 2, Color.primary.opacity(0.3)) }
    }
    let titles = ["性：生来弯曲的木材", "伪：经过檃栝蒸烤矫正", "善：人为努力的结果"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "人之性恶，其善者伪也", size)
}

func drawAccumulate(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 7, 7])
    switch b {
    case 0:
        let n = Int(smooth(p / 0.85) * 21)
        var k = 0
        for row in 0..<6 {
            for col in 0..<(6 - row) where k < n {
                let x = w / 2 + (Double(col) - Double(5 - row) / 2) * 30
                box(&ctx, x - 13, h - 80 - Double(row) * 26, 26, 22, Moon.silver)
                k += 1
            }
        }
        if n >= 21 {
            for i in 0..<6 { line(&ctx, w * 0.3 + Double(i) * 24, 70 + fract(t * 0.8 + Double(i) * 0.3) * 60, w * 0.3 + Double(i) * 24 - 6, 82 + fract(t * 0.8 + Double(i) * 0.3) * 60, Moon.silver.opacity(0.6), 1.5) }
        }
        headline(&ctx, "积土成山，风雨兴焉", size)
    case 1:
        let level = smooth(p / 0.8)
        let top = h - 70 - (h - 190) * level
        fillPath(&ctx, Path(roundedRect: CGRect(x: w * 0.25, y: top, width: w * 0.5, height: h - 70 - top), cornerRadius: 12), Moon.silver.opacity(0.35))
        for i in 0..<6 { blob(&ctx, w * 0.3 + Double(i) * w * 0.08, 60 + fract(t * 0.6 + Double(i) * 0.17) * (top - 60), 3, Moon.silver) }
        if level > 0.9 {
            dot(&ctx, w / 2 + sin(t * 0.8) * w * 0.15, (top + h - 70) / 2, 12, Moon.gold)
            label(&ctx, "蛟龙", w / 2 + sin(t * 0.8) * w * 0.15, (top + h - 70) / 2 + 24, Moon.gold, size: 11)
        }
        headline(&ctx, "积水成渊，蛟龙生焉", size)
    default:
        let n = Int(smooth(p / 0.8) * 30)
        for i in 0..<30 {
            let x = 30 + Double(i) / 29 * (w - 60)
            let y = h * 0.55 + sin(Double(i) * 0.4) * 30
            if i < n { blob(&ctx, x, y, 3, Moon.gold) } else { blob(&ctx, x, y, 1.5, Moon.dim) }
        }
        label(&ctx, "千里", w - 40, h * 0.55 + sin(29 * 0.4) * 30 - 24, n >= 30 ? Moon.gold : Moon.dim, size: 13)
        headline(&ctx, "不积跬步，无以至千里", size)
    }
    caption(&ctx, "积善成德，而神明自得", size)
}

func drawTianRen(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [8, 9])
    let sky = h * 0.3, man = h * 0.72
    label(&ctx, "天", 30, sky, Moon.gold, size: 16)
    label(&ctx, "人", 30, man, Moon.violet, size: 16)
    let names = ["春", "夏", "秋", "冬"]
    let disturb = b == 1 && p > 0.3 ? sin(t * 4) * 10 * (1 - smooth((p - 0.3) / 0.6)) : 0
    for i in 0..<4 {
        let x = w * (0.25 + 0.17 * Double(i))
        let dy = i == 2 ? disturb : 0
        dot(&ctx, x, sky + dy * 0.8, 16, Moon.gold)
        dot(&ctx, x, man + dy, 16, Moon.violet)
        label(&ctx, names[i], x, sky - 28, Moon.gold, size: 11)
        if b == 1 { line(&ctx, x, sky + 18, x, man - 18, Color.primary.opacity(0.3 * smooth(p / 0.3)), 1, dash: [4, 4]) }
    }
    headline(&ctx, b == 0 ? "天有四时，人有喜怒哀乐" : "人事一动，天象相应", size)
    caption(&ctx, "天人之际，合而为一", size)
}

func drawTwoVerses(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [8, 8, 6])
    let mx = w / 2, my = h * 0.48, mw = w * 0.46, mh = h * 0.42
    let mirrorAlpha = b == 0 ? 1.0 : (b == 1 ? 1 - smooth(p / 0.5) : 0)
    if mirrorAlpha > 0.02 {
        box(&ctx, mx - mw / 2, my - mh / 2, mw, mh, Moon.silver.opacity(mirrorAlpha))
        label(&ctx, "明镜台", mx, my + mh / 2 + 16, Moon.silver.opacity(mirrorAlpha), size: 12)
    }
    let wipeX = b == 0 ? mx - mw / 2 + mw * fract(p * 2) : -100
    for i in 0..<18 {
        let s = Double(i)
        let x = mx - mw / 2 + hash01(s) * mw
        let fall = fract(t * 0.15 + hash01(s + 3))
        var y = my - mh / 2 - 40 + fall * (mh + 120)
        if b == 0 { y = min(y, my + hash01(s + 9) * mh / 2) }
        let wiped = b == 0 && abs(x - wipeX) < 18
        if !wiped { blob(&ctx, x, y, 2.5, Color.primary.opacity(0.45)) }
    }
    if b == 0 { line(&ctx, wipeX, my - mh / 2, wipeX, my + mh / 2, Moon.gold.opacity(0.7), 3) }
    let titles = ["神秀：时时勤拂拭，勿使惹尘埃", "慧能：明镜亦非台", "本来无一物，何处惹尘埃"]
    headline(&ctx, titles[b], size, b == 0 ? .primary : Moon.gold)
    caption(&ctx, b == 0 ? "渐修：不断擦拭" : "顿悟：尘埃无处可落", size)
}

func drawFlag(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, _) = beats(t, [6, 6, 8])
    let px = w * 0.4, top = h * 0.2
    line(&ctx, px, top, px, h * 0.8, Color.primary.opacity(0.6), 3)
    var flag = Path()
    flag.move(to: CGPoint(x: px, y: top))
    for i in 0...20 {
        let u = Double(i) / 20
        flag.addLine(to: CGPoint(x: px + u * 110, y: top + 8 * sin(u * 6 - t * 1.5) * u))
    }
    for i in (0...20).reversed() {
        let u = Double(i) / 20
        flag.addLine(to: CGPoint(x: px + u * 110, y: top + 60 + 8 * sin(u * 6 - t * 1.5) * u))
    }
    flag.closeSubpath()
    fillPath(&ctx, flag, (b == 1 ? Moon.gold : Moon.violet).opacity(b == 2 ? 0.25 : 0.6))
    for i in 0..<4 {
        let y = top + 10 + Double(i) * 14
        let x = 20 + fract(t * 0.3 + Double(i) * 0.25) * (px - 30)
        line(&ctx, x, y, x + 30, y, (b == 0 ? Moon.gold : Color.primary).opacity(b == 2 ? 0.15 : 0.6), 2)
    }
    if b == 2 {
        let g = 0.5 + 0.5 * sin(t * 1.5)
        dot(&ctx, w / 2, h * 0.68, 22 + 6 * g, Moon.gold)
        label(&ctx, "心", w / 2, h * 0.68, .primary, size: 16)
    }
    let titles = ["一僧曰：风动", "一僧曰：幡动", "慧能：仁者心动"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "不是风动，不是幡动", size)
}

func drawZhiXing(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 6, 8])
    let gap = b == 0 ? 90.0 : (b == 1 ? 90 * (1 - smooth(p / 0.9)) : 0)
    let cy = h * 0.5
    for (i, name) in ["知", "行"].enumerated() {
        let y = cy + (i == 0 ? -gap : gap) / 2
        line(&ctx, 50, y, w - 30, y, (i == 0 ? Moon.gold : Moon.violet).opacity(0.7), 3)
        if gap > 10 { label(&ctx, name, 30, y, i == 0 ? Moon.gold : Moon.violet, size: 16) }
    }
    if b == 2 {
        label(&ctx, "知行", 30, cy, Moon.gold, size: 15)
        for i in 0..<5 {
            let x = 50 + fract(t * 0.12 + Double(i) * 0.2) * (w - 80)
            dot(&ctx, x, cy, 8, Moon.gold)
        }
        label(&ctx, "始", 60, cy - 24, .primary, size: 12)
        label(&ctx, "成", w - 40, cy - 24, .primary, size: 12)
    }
    let titles = ["徐爱：知与行分明是两件", "阳明：被私欲隔断，才成了两件", "知是行之始，行是知之成"]
    headline(&ctx, titles[b], size, b == 2 ? Moon.gold : .primary)
    caption(&ctx, "只说一个知，已自有行在", size)
}

func drawFlower(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [7, 8])
    var mountain = Path()
    mountain.move(to: CGPoint(x: 0, y: h * 0.75))
    mountain.addLine(to: CGPoint(x: w * 0.35, y: h * 0.3))
    mountain.addLine(to: CGPoint(x: w * 0.6, y: h * 0.55))
    mountain.addLine(to: CGPoint(x: w * 0.8, y: h * 0.38))
    mountain.addLine(to: CGPoint(x: w, y: h * 0.75))
    mountain.closeSubpath()
    fillPath(&ctx, mountain, Color.primary.opacity(0.07))
    let bright = b == 0 ? 0.0 : smooth(p / 0.5)
    let fx = w * 0.5, fy = h * 0.62
    for i in 0..<5 {
        let a = Double(i) / 5 * 2 * Double.pi + t * 0.1
        let c = Color(hue: 0.92, saturation: 0.55 * bright, brightness: 0.55 + 0.4 * bright)
        dot(&ctx, fx + cos(a) * 14, fy + sin(a) * 14, 11, c)
    }
    dot(&ctx, fx, fy, 7, Moon.gold.opacity(0.4 + 0.6 * bright))
    if b == 1 {
        let ex = lerp(w + 20, w * 0.78, smooth(p / 0.4))
        dot(&ctx, ex, h * 0.82, 14, Moon.silver)
        label(&ctx, "看花人", ex, h * 0.82 + 24, Moon.silver, size: 11)
        line(&ctx, ex - 14, h * 0.82, fx + 16, fy, Moon.silver.opacity(0.4 * smooth(p / 0.4)), 1, dash: [4, 4])
    }
    headline(&ctx, b == 0 ? "未看此花时：花与心同归于寂" : "来看此花时：颜色一时明白起来", size, b == 1 ? Moon.gold : .primary)
    caption(&ctx, "便知此花不在你的心外", size)
}

func drawFishDebate(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, _) = beats(t, [6, 6, 6, 6])
    let bridgeY = h * 0.4
    line(&ctx, 20, bridgeY, w - 20, bridgeY, Color.primary.opacity(0.5), 4)
    let zx = w * 0.35, hx = w * 0.65
    dot(&ctx, zx, bridgeY - 24, 16, b == 0 || b == 2 ? Moon.gold : Moon.silver)
    dot(&ctx, hx, bridgeY - 24, 16, b == 1 || b == 3 ? Moon.violet : Moon.silver)
    label(&ctx, "庄子", zx, bridgeY - 52, Moon.gold, size: 12)
    label(&ctx, "惠子", hx, bridgeY - 52, Moon.violet, size: 12)
    fillPath(&ctx, Path(CGRect(x: 0, y: h * 0.58, width: w, height: h * 0.3)), Moon.silver.opacity(0.15))
    for i in 0..<5 {
        let s = Double(i)
        let x = fract(t * 0.06 + hash01(s)) * w
        let y = h * 0.66 + hash01(s + 4) * h * 0.18 + sin(t * 1.2 + s) * 6
        blob(&ctx, x, y, 4, Moon.gold.opacity(0.8))
        line(&ctx, x - 10, y, x - 4, y, Moon.gold.opacity(0.5), 2)
    }
    let lines = ["庄子：鲦鱼出游从容，是鱼之乐也", "惠子：子非鱼，安知鱼之乐？", "庄子：子非我，安知我不知鱼之乐？", "惠子：我非子，固不知子矣……"]
    headline(&ctx, lines[b], size, b % 2 == 0 ? Moon.gold : Moon.violet)
    caption(&ctx, "我们能否知道他者的感受？", size)
}

func drawButterfly(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
    let w = Double(size.width), h = Double(size.height)
    let (b, p) = beats(t, [6, 7, 8])
    let cx = w / 2, cy = h / 2
    func butterfly(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ a: Double) {
        let flap = 0.6 + 0.4 * abs(sin(t * 3))
        dot(&ctx, x - 14 * flap, y - 6, 13 * flap, Moon.violet.opacity(a))
        dot(&ctx, x + 14 * flap, y - 6, 13 * flap, Moon.violet.opacity(a))
        blob(&ctx, x, y, 3, Color.primary.opacity(a))
    }
    switch b {
    case 0:
        dot(&ctx, cx - 60, cy + 30, 24, Moon.gold)
        label(&ctx, "庄周", cx - 60, cy + 66, Moon.gold, size: 13)
        for i in 0..<3 { label(&ctx, "z", cx - 30 + Double(i) * 12, cy - 10 - Double(i) * 14 - fract(t * 0.4) * 8, Moon.dim, size: 12 + Double(i) * 3) }
        headline(&ctx, "庄周入梦", size)
    case 1:
        let x = cx + sin(t * 0.6) * w * 0.3, y = cy - 20 + sin(t * 1.1) * 40
        butterfly(&ctx, x, y, 1)
        dot(&ctx, cx - 60, cy + 30, 24, Moon.gold.opacity(0.25))
        headline(&ctx, "栩栩然蝴蝶也：只知是蝴蝶", size, Moon.violet)
    default:
        let k = smooth(p / 0.6)
        dot(&ctx, lerp(cx - 60, cx - 14, k), cy, 24, Moon.gold)
        butterfly(&ctx, lerp(cx + 80, cx + 14, k), cy, 1)
        label(&ctx, "?", cx, cy - 50, .primary, size: 22)
        headline(&ctx, "是周梦为蝶，还是蝶梦为周？", size, Moon.gold)
    }
    caption(&ctx, "此之谓物化", size)
}
