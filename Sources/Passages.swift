import SwiftUI

/// 一段原文的三语对照
struct Passage {
    let ref: String          // 出处
    let original: String     // 原文（德文或英文）
    let english: String?     // 英译；原文是英文时为 nil
    let chinese: String
    var englishSource: String = "Meiklejohn 英译（1855）"
}

private let ownEN = "本应用英译"

/// 键：书籍 id + ":" + 章节序号
let passages: [String: [Passage]] = [
    // MARK: 康德《纯粹理性批判》（德文据 1787 年第二版；A/B 为第一、二版页码）
    "kant-cpr:0": [Passage(ref: "B XVI，第二版序言",
        original: "Bisher nahm man an, alle unsere Erkenntnis müsse sich nach den Gegenständen richten … Man versuche es daher einmal, ob wir nicht in den Aufgaben der Metaphysik damit besser fortkommen, daß wir annehmen, die Gegenstände müssen sich nach unserem Erkenntnis richten.",
        english: "It has hitherto been assumed that our cognition must conform to the objects … Let us then make the experiment whether we may not be more successful in metaphysics, if we assume that the objects must conform to our cognition.",
        chinese: "迄今为止，人们都假定我们的一切知识必须以对象为准……那么不妨试试：假定对象必须以我们的认识为准，看看在形而上学的任务上是否会进展得更好。")],
    "kant-cpr:1": [Passage(ref: "B19，导论",
        original: "Die eigentliche Aufgabe der reinen Vernunft ist nun in der Frage enthalten: Wie sind synthetische Urteile a priori möglich?",
        english: "The proper problem of pure reason, then, is contained in the question: “How are synthetical judgements a priori possible?”",
        chinese: "纯粹理性真正的课题就包含在这个问题里：先天综合判断是如何可能的？")],
    "kant-cpr:2": [Passage(ref: "A24 / B38",
        original: "Der Raum ist eine notwendige Vorstellung a priori, die allen äußeren Anschauungen zum Grunde liegt.",
        english: "Space then is a necessary representation a priori, which serves for the foundation of all external intuitions.",
        chinese: "空间是一个必然的先天表象，它是一切外部直观的基础。")],
    "kant-cpr:3": [Passage(ref: "A31 / B46",
        original: "Die Zeit ist eine notwendige Vorstellung, die allen Anschauungen zum Grunde liegt.",
        english: "Time is a necessary representation, lying at the foundation of all our intuitions.",
        chinese: "时间是一个必然的表象，它是一切直观的基础。")],
    "kant-cpr:4": [Passage(ref: "A51 / B75",
        original: "Ohne Sinnlichkeit würde uns kein Gegenstand gegeben, und ohne Verstand keiner gedacht werden. Gedanken ohne Inhalt sind leer, Anschauungen ohne Begriffe sind blind.",
        english: "Without the sensuous faculty no object would be given to us, and without the understanding no object would be thought. Thoughts without content are void; intuitions without conceptions, blind.",
        chinese: "没有感性，就没有对象被给予我们；没有知性，就没有对象被思维。思维无内容则空，直观无概念则盲。")],
    "kant-cpr:5": [Passage(ref: "A79 / B104–105",
        original: "Dieselbe Funktion, welche den verschiedenen Vorstellungen in einem Urteile Einheit gibt, die gibt auch der bloßen Synthesis verschiedene Vorstellungen in einer Anschauung Einheit, welche, allgemein ausgedrückt, der reine Verstandesbegriff heißt.",
        english: "The same function which gives unity to the different representation in a judgement, gives also unity to the mere synthesis of different representations in an intuition; and this unity we call the pure conception of the understanding.",
        chinese: "在一个判断中给不同表象以统一性的那个功能，也给一个直观中不同表象的单纯综合以统一性；这种统一性，一般地说，就叫作纯粹知性概念。")],
    "kant-cpr:6": [Passage(ref: "B131–132，§16",
        original: "Das: Ich denke, muß alle meine Vorstellungen begleiten können; denn sonst würde etwas in mir vorgestellt werden, was garnicht gedacht werden könnte.",
        english: "The “I think” must accompany all my representations, for otherwise something would be represented in me which could not be thought.",
        chinese: "“我思”必须能够伴随我的一切表象；否则就会有某种根本无法被思维的东西在我之中被表象。")],
    "kant-cpr:7": [Passage(ref: "A140 / B179–180",
        original: "Diese Vorstellung nun von einem allgemeinen Verfahren der Einbildungskraft, einem Begriff sein Bild zu verschaffen, nenne ich das Schema zu diesem Begriffe.",
        english: "Now this representation of a general procedure of the imagination to present its image to a conception, I call the schema of this conception.",
        chinese: "想象力为一个概念提供其图像的普遍程序，这一表象我称之为该概念的图型。")],
    "kant-cpr:8": [Passage(ref: "B202，直观的公理",
        original: "Das Prinzip derselben ist: Alle Anschauungen sind extensive Größen.",
        english: "Their principle is: all intuitions are extensive quantities.",
        chinese: "其原理是：一切直观都是广延量。", englishSource: ownEN)],
    "kant-cpr:9": [Passage(ref: "B207，知觉的预测",
        original: "In allen Erscheinungen hat das Reale, was ein Gegenstand der Empfindung ist, intensive Größe, d.i. einen Grad.",
        english: "In all phenomena the Real, that which is an object of sensation, has Intensive Quantity, that is, has a Degree.",
        chinese: "在一切现象中，作为感觉对象的实在之物都具有强度量，也就是具有一个度。")],
    "kant-cpr:10": [
        Passage(ref: "B224，第一类比",
            original: "Bei allem Wechsel der Erscheinungen beharrt die Substanz, und das Quantum derselben wird in der Natur weder vermehrt noch vermindert.",
            english: "In all changes of phenomena, substance is permanent, and the quantum thereof in nature is neither increased nor diminished.",
            chinese: "在现象的一切变化中，实体持存不变，它在自然中的量既不增加也不减少。"),
        Passage(ref: "B232，第二类比",
            original: "Alle Veränderungen geschehen nach dem Gesetze der Verknüpfung der Ursache und Wirkung.",
            english: "All changes take place according to the law of the connection of cause and effect.",
            chinese: "一切变化都按照因果联结的规律发生。", englishSource: ownEN),
        Passage(ref: "B256，第三类比",
            original: "Alle Substanzen, sofern sie im Raume, als zugleich wahrgenommen werden können, sind in durchgängiger Wechselwirkung.",
            english: "All substances, in so far as they can be perceived in space as simultaneous, are in thoroughgoing reciprocity.",
            chinese: "一切实体，只要能在空间中被知觉为同时存在，就处在普遍的交互作用之中。", englishSource: ownEN),
    ],
    "kant-cpr:11": [Passage(ref: "B275，驳斥唯心论",
        original: "Das bloße, aber empirisch bestimmte, Bewußtsein meines eigenen Daseins beweist das Dasein der Gegenstände im Raum außer mir.",
        english: "The simple but empirically determined consciousness of my own existence proves the existence of external objects in space.",
        chinese: "对我自身存在的单纯的、但经验地被规定了的意识，证明了在我之外的空间中对象的存在。")],
    "kant-cpr:12": [Passage(ref: "A255 / B310–311",
        original: "Der Begriff eines Noumenon ist also bloß ein Grenzbegriff, um die Anmaßung der Sinnlichkeit einzuschränken, und also nur von negativem Gebrauche.",
        english: "The conception of a noumenon is therefore merely a limitative conception and therefore only of negative use.",
        chinese: "所以本体的概念只是一个界限概念，用来限制感性的僭越，因而只有消极的用途。")],
    "kant-cpr:13": [Passage(ref: "A264 / B320，反思概念的歧义",
        original: "Die Verschiedenheit der Örter macht die Vielheit und Unterscheidung der Gegenstände, als Erscheinungen, ohne weitere Bedingungen, schon für sich nicht allein möglich, sondern auch notwendig.",
        english: "The difference of places by itself, without further conditions, makes the plurality and distinction of objects as appearances not only possible but also necessary.",
        chinese: "单是位置的不同，无需其他条件，就使作为现象的对象的多样与区别不仅成为可能，而且成为必然。", englishSource: ownEN)],
    "kant-cpr:14": [Passage(ref: "A297 / B354，先验幻相",
        original: "… so wenig selbst der Astronom verhindern kann, daß ihm der Mond im Aufgange nicht größer scheine, ob er gleich durch diesen Schein nicht betrogen wird.",
        english: "… as even the astronomer cannot prevent himself from seeing the moon larger at its rising than some time afterwards, although he is not deceived by this illusion.",
        chinese: "……正如天文学家也无法阻止月亮在初升时看起来更大，尽管他并不受这一假象的欺骗。")],
    "kant-cpr:15": [Passage(ref: "A307–308 / B364",
        original: "Die Vernunft fordert dieses nach dem Grundsatze: wenn das Bedingte gegeben ist, so ist auch die ganze Summe der Bedingungen, mithin das schlechthin Unbedingte gegeben.",
        english: "Reason demands this according to the principle: if the conditioned is given, then the whole sum of conditions, and hence the absolutely unconditioned, is also given.",
        chinese: "理性依据这样一条原理提出要求：如果有条件者被给予，那么条件的全部总和，从而绝对无条件者，也就被给予了。", englishSource: ownEN)],
    "kant-cpr:16": [Passage(ref: "A345–346 / B404，谬误推理",
        original: "Zum Grunde derselben können wir aber nichts anderes legen, als die einfache und für sich selbst an Inhalt gänzlich leere Vorstellung: Ich.",
        english: "We can, however, lay at the foundation of this science nothing but the simple and in itself perfectly contentless representation “I”.",
        chinese: "但我们能为这门学问奠基的，只是那个单纯的、本身在内容上完全空洞的表象：我。")],
    "kant-cpr:17": [Passage(ref: "A426 / B454，第一个二律背反（正题）",
        original: "Die Welt hat einen Anfang in der Zeit, und ist dem Raum nach auch in Grenzen eingeschlossen.",
        english: "The world has a beginning in time, and is also limited in regard to space.",
        chinese: "世界在时间上有开端，在空间上也被包围在界限之中。")],
    "kant-cpr:18": [Passage(ref: "A598–599 / B626–627",
        original: "Sein ist offenbar kein reales Prädikat … Hundert wirkliche Taler enthalten nicht das mindeste mehr, als hundert mögliche.",
        english: "Being is evidently not a real predicate … A hundred real dollars contain no more than a hundred possible dollars.",
        chinese: "“存在”显然不是实在的谓词……一百个现实的塔勒所包含的，丝毫不多于一百个可能的塔勒。")],
    "kant-cpr:19": [Passage(ref: "A644 / B672，辩证论附录",
        original: "… in einen Punkt zusammenlaufen, der, ob er zwar nur eine Idee (focus imaginarius) … ist, … dennoch dazu dient, ihnen die größte Einheit neben der größten Ausbreitung zu verschaffen.",
        english: "This point—though a mere idea (focus imaginarius) … —serves, notwithstanding, to give to these conceptions the greatest possible unity combined with the greatest possible extension.",
        chinese: "这个点虽然只是一个理念（虚焦点）……却能使知性概念在获得最大扩展的同时，获得最大的统一。")],
    "kant-cpr:20": [Passage(ref: "A713 / B741，纯粹理性的训练",
        original: "Die philosophische Erkenntnis ist die Vernunfterkenntnis aus Begriffen, die mathematische aus der Konstruktion der Begriffe.",
        english: "Philosophical cognition is the cognition of reason by means of conceptions; mathematical cognition is cognition by means of the construction of conceptions.",
        chinese: "哲学知识是出自概念的理性知识，数学知识是出自概念之构造的理性知识。")],
    "kant-cpr:21": [
        Passage(ref: "A805 / B833，纯粹理性的法规",
            original: "1. Was kann ich wissen? 2. Was soll ich tun? 3. Was darf ich hoffen?",
            english: "1. What can I know? 2. What ought I to do? 3. What may I hope?",
            chinese: "一、我能知道什么？二、我应当做什么？三、我可以希望什么？"),
        Passage(ref: "B XXX，第二版序言",
            original: "Ich mußte also das Wissen aufheben, um zum Glauben Platz zu bekommen.",
            english: "I must, therefore, abolish knowledge, to make room for belief.",
            chinese: "因此，我必须扬弃知识，以便为信仰腾出地盘。"),
    ],
    "kant-cpr:22": [Passage(ref: "A832 / B860",
        original: "Ich verstehe unter einer Architektonik die Kunst der Systeme.",
        english: "By the term architectonic I mean the art of constructing a system.",
        chinese: "我所说的建筑术，是指构造系统的艺术。")],
    "kant-cpr:23": [Passage(ref: "A856 / B884，全书最后",
        original: "Der kritische Weg ist allein noch offen.",
        english: "The critical path alone is still open.",
        chinese: "唯有批判的道路仍然敞开。")],

    // MARK: 黑格尔《精神现象学》（德文据 1807 年版）
    "hegel-phen:0": [Passage(ref: "序言",
        original: "Das Wahre ist das Ganze. Das Ganze aber ist nur das durch seine Entwicklung sich vollendende Wesen.",
        english: "The true is the whole. But the whole is only the essence that completes itself through its development.",
        chinese: "真理是全体。但全体只是通过自身的发展而完成自己的那个本质。", englishSource: ownEN),
        Passage(ref: "序言",
        original: "Die Knospe verschwindet in dem Hervorbrechen der Blüte, und man könnte sagen, daß jene von dieser widerlegt wird, ebenso wird durch die Frucht die Blüte für ein falsches Dasein der Pflanze erklärt.",
        english: "The bud disappears when the blossom breaks forth, and one could say that the former is refuted by the latter; likewise the fruit declares the blossom a false form of the plant's existence.",
        chinese: "花朵绽放时花蕾消失，人们可以说花蕾被花朵驳倒了；同样，果实又宣告花朵是植物的一种虚假存在。", englishSource: ownEN)],
    "hegel-phen:1": [Passage(ref: "第一章 感性确定性",
        original: "Auf die Frage: Was ist das Itzt? antworten wir also zum Beispiel: Das Itzt ist die Nacht. … Sehen wir itzt, diesen Mittag, die aufgeschriebene Wahrheit wieder an, so werden wir sagen müssen, daß sie schal geworden ist.",
        english: "To the question “What is the Now?” we answer, for example: “The Now is night.” … If we look again at the written-down truth now, this noon, we shall have to say that it has become stale.",
        chinese: "对“这时是什么？”这个问题，我们比如回答：“这时是夜晚。”……到了现在、这个中午，再看那条写下来的真理，我们就不得不说：它已经变得陈腐了。", englishSource: ownEN)],
    "hegel-phen:2": [Passage(ref: "第三章 力与知性",
        original: "Das Übersinnliche ist also die Erscheinung als Erscheinung.",
        english: "The supersensible is therefore appearance as appearance.",
        chinese: "所以，超感官的东西就是作为现象的现象。", englishSource: ownEN)],
    "hegel-phen:3": [Passage(ref: "第四章 自我意识",
        original: "Das Selbstbewußtsein erreicht seine Befriedigung nur in einem andern Selbstbewußtsein.",
        english: "Self-consciousness achieves its satisfaction only in another self-consciousness.",
        chinese: "自我意识只有在另一个自我意识中才获得它的满足。", englishSource: ownEN),
        Passage(ref: "第四章 A 主人与奴隶",
        original: "Die Wahrheit des selbstständigen Bewußtseins ist demnach das knechtische Bewußtsein.",
        english: "The truth of the independent consciousness is accordingly the servile consciousness.",
        chinese: "因此，独立意识的真理是奴隶意识。", englishSource: ownEN)],
    "hegel-phen:4": [Passage(ref: "第四章 B 苦恼意识",
        original: "Dieses unglückliche, in sich entzweite Bewußtsein muß also … in dem einen Bewußtsein immer auch das andere haben.",
        english: "This unhappy consciousness, divided within itself, must therefore … always have the one consciousness within the other.",
        chinese: "这个苦恼的、自身分裂的意识，因此……总是在一个意识中同时拥有另一个意识。", englishSource: ownEN)],
    "hegel-phen:5": [Passage(ref: "第八章 绝对知识（全书结尾）",
        original: "Das Ziel, das absolute Wissen, oder der sich als Geist wissende Geist hat zu seinem Wege die Erinnerung der Geister, wie sie an ihnen selbst sind.",
        english: "The goal, absolute knowing, or spirit that knows itself as spirit, has for its path the recollection of the spirits as they are in themselves.",
        chinese: "目标，即绝对知识，或者说知道自己是精神的精神，以对诸精神形态本来面目的回忆作为它的道路。", englishSource: ownEN)],

    // MARK: 黑格尔《逻辑学》（德文据初版，保留 Seyn 等旧拼写）
    "hegel-logic:0": [Passage(ref: "第一卷 存在论",
        original: "Seyn, reines Seyn,—ohne alle weitere Bestimmung. … Das reine Seyn und das reine Nichts ist also dasselbe.",
        english: "Being, pure being—without any further determination. … Pure being and pure nothing are, therefore, the same.",
        chinese: "有，纯有——没有任何进一步的规定。……所以，纯有与纯无是同一个东西。", englishSource: ownEN)],
    "hegel-logic:1": [Passage(ref: "第一卷 度",
        original: "Nach der qualitativen Seite wird daher das bloß quantitative Fortgehen der Allmähligkeit … absolut abgebrochen; … ist der Übergang ein Sprung.",
        english: "On the qualitative side, therefore, the merely quantitative progression of gradualness … is absolutely broken off; … the transition is a leap.",
        chinese: "因此在质的方面，单纯量的渐进过程……被绝对地打断了；……过渡是一个飞跃。", englishSource: ownEN)],
    "hegel-logic:2": [Passage(ref: "本质论 第二部分 现象",
        original: "Das Wesen muß erscheinen.",
        english: "Essence must appear.",
        chinese: "本质必须显现。", englishSource: ownEN)],
    "hegel-logic:3": [Passage(ref: "概念论 推理",
        original: "Der Schluß ist daher nicht nur vernünftig, sondern alles Vernünftige ist ein Schluß.",
        english: "The syllogism is therefore not only rational; rather, everything rational is a syllogism.",
        chinese: "所以推理不仅是合理的，而且一切合理的东西都是推理。", englishSource: ownEN)],
    "hegel-logic:4": [Passage(ref: "第一卷 关于“扬弃”的注释",
        original: "Aufheben hat in der Sprache den gedoppelten Sinn, daß es so viel als aufbewahren, erhalten bedeutet, und zugleich so viel als aufhören lassen, ein Ende machen.",
        english: "“To sublate” has a twofold meaning in the language: it means to preserve, to maintain, and at the same time to cause to cease, to put an end to.",
        chinese: "“扬弃”在语言中有双重意义：它既意味着保存、保持，同时又意味着使之停止、加以终结。", englishSource: ownEN)],

    // MARK: 罗素（原文为英文）
    "russell-denoting:0": [Passage(ref: "On Denoting, Mind 14 (1905)",
        original: "If we enumerated the things that are bald, and then the things that are not bald, we should not find the present King of France in either list. Hegelians, who love a synthesis, will probably conclude that he wears a wig.",
        english: nil,
        chinese: "如果我们把秃头的东西列一张单子，再把不秃头的东西列一张单子，两张单子里都找不到当今的法国国王。喜欢综合的黑格尔派大概会断定：他戴着假发。")],
    "russell-denoting:1": [Passage(ref: "On Denoting, Mind 14 (1905)",
        original: "Now George IV wished to know whether Scott was the author of Waverley; and in fact Scott was the author of Waverley. Hence we may substitute Scott for the author of “Waverley”, and thereby prove that George IV wished to know whether Scott was Scott.",
        english: nil,
        chinese: "乔治四世想知道司各特是否是《威弗利》的作者；而司各特事实上就是《威弗利》的作者。于是我们可以用“司各特”替换“《威弗利》的作者”，从而证明乔治四世想知道司各特是否是司各特。")],
    "russell-pm:0": [Passage(ref: "Principia Mathematica, Introduction, ch. II",
        original: "Let w be the class of all those classes which are not members of themselves. Then, whatever class x may be, “x is a w” is equivalent to “x is not an x.” Hence, giving to x the value w, “w is a w” is equivalent to “w is not a w.”",
        english: nil,
        chinese: "设 w 是所有不以自身为成员的类所组成的类。那么无论 x 是什么类，“x 是一个 w”都等价于“x 不是一个 x”。因此令 x 取值为 w，“w 是一个 w”就等价于“w 不是一个 w”。")],
    "russell-pm:1": [Passage(ref: "Principia Mathematica, Introduction, ch. II（恶性循环原则）",
        original: "Whatever involves all of a collection must not be one of the collection.",
        english: nil,
        chinese: "凡涉及一个总体之全部成员的东西，本身不得是这个总体的成员。")],
    "russell-pm:2": [Passage(ref: "Principia Mathematica, *54.43",
        original: "From this proposition it will follow, when arithmetical addition has been defined, that 1 + 1 = 2.",
        english: nil,
        chinese: "等到算术加法被定义之后，由这个命题就可以推出 1 + 1 = 2。")],
    "russell-problems:0": [Passage(ref: "第一章 现象与实在",
        original: "Although I believe that the table is 'really' of the same colour all over, the parts that reflect the light look much brighter than the other parts … I know that, if I move, the parts that reflect the light will be different, so that the apparent distribution of colours on the table will change.",
        english: nil,
        chinese: "虽然我相信这张桌子“实际上”通体是同一种颜色，可是反光的部分看起来比其他部分亮得多……我知道，只要我一移动，反光的部分就会不同，桌上颜色的表面分布也就随之改变。")],
    "russell-problems:1": [Passage(ref: "第五章 亲知的知识与描述的知识",
        original: "Every proposition which we can understand must be composed wholly of constituents with which we are acquainted.",
        english: nil,
        chinese: "我们能够理解的每一个命题，都必须完全由我们所亲知的成分构成。")],
    "russell-problems:2": [Passage(ref: "第六章 论归纳",
        original: "The man who has fed the chicken every day throughout its life at last wrings its neck instead, showing that more refined views as to the uniformity of nature would have been useful to the chicken.",
        english: nil,
        chinese: "那个每天喂鸡、喂了它一辈子的人，最后却拧断了它的脖子。这说明，对自然的齐一性抱有更精细的看法，本来会对那只鸡有用。")],
]

// MARK: - 原文阅读视图

enum PassageLang: String, CaseIterable, Identifiable {
    case all, chinese, english, original
    var id: String { rawValue }
    var title: String {
        switch self {
        case .all: return "三语"
        case .chinese: return "中文"
        case .english: return "English"
        case .original: return "原文"
        }
    }
}

struct PassagesView: View {
    let items: [Passage]
    let book: Book
    let key: String
    @AppStorage("passageLang") private var langRaw = PassageLang.all.rawValue

    var body: some View {
        let lang = PassageLang(rawValue: langRaw) ?? .all
        VStack(alignment: .leading, spacing: 14) {
            Picker("语言", selection: $langRaw) {
                ForEach(PassageLang.allCases) { Text($0.title).tag($0.rawValue) }
            }
            .pickerStyle(.segmented)

            if items.isEmpty {
                Text("本章暂无原文节选。")
                    .font(.subheadline).foregroundStyle(Color.primary.opacity(0.6))
            }
            ForEach(Array(items.enumerated()), id: \.offset) { _, p in
                VStack(alignment: .leading, spacing: 12) {
                    Text(p.ref)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Moon.silver)
                    if lang == .all || lang == .original {
                        block(tag: p.english == nil ? "原文 · English" : "原文 · Deutsch",
                              text: p.original, serif: true)
                    }
                    if let en = p.english, lang == .all || lang == .english {
                        block(tag: "English · \(p.englishSource)", text: en, serif: true)
                    }
                    if p.english == nil && lang == .english {
                        block(tag: "English（原文即英文）", text: p.original, serif: true)
                    }
                    if lang == .all || lang == .chinese {
                        block(tag: "中文 · 本应用译", text: p.chinese, serif: false)
                    }
                    if let tid = textId(forPassage: key, book: book.id) {
                        NavigationLink {
                            BookReaderView(book: book, initialText: tid, query: anchor(from: p.original))
                        } label: {
                            Label("在全文中查看", systemImage: "text.magnifyingglass")
                                .font(.footnote.weight(.semibold))
                        }
                        .buttonStyle(.glass)
                    }
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: .rect(cornerRadius: 24))
            }
            Text(items.contains { $0.english != nil }
                 ? "德文原文与 Meiklejohn 英译来自公有领域版本（Project Gutenberg）；标注“本应用译”的译文由本应用提供。"
                 : "原文为罗素的英文原著，出处见各段标注；中文由本应用翻译。")
                .font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
        }
    }

    private func block(tag: String, text: String, serif: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tag).font(.caption2.weight(.medium)).foregroundStyle(Color.primary.opacity(0.5))
            Text(text)
                .font(serif ? .system(.callout, design: .serif) : .callout)
                .foregroundStyle(Color.primary.opacity(0.9))
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
