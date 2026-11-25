import SwiftUI

// MARK: - 学者观点（试点：《纯粹理性批判》24 章）
// 每条都是对学者立场的概括（不是原文引用），注明代表作与年份。

struct ScholarView: Identifiable {
    var id: String { name }
    let name: String
    let tag: String          // 年代 / 学派
    let work: String         // 代表作（年份）
    let view: String         // 观点概括
    let pos: Double          // 在“观点光谱”上的位置 0…1
}

struct ScholarTopic {
    let question: String     // 争论的问题
    let left: String         // 光谱左端
    let right: String        // 光谱右端
    let views: [ScholarView]
    var links: [(String, String)] = []
}

private let sepKant = ("斯坦福哲学百科：Immanuel Kant", "https://plato.stanford.edu/entries/kant/")
private let sepTI = ("斯坦福哲学百科：Kant's Transcendental Idealism", "https://plato.stanford.edu/entries/kant-transcendental-idealism/")

let scholarTopics: [String: ScholarTopic] = [
    "kant-cpr:0": ScholarTopic(
        question: "“哥白尼式革命”究竟颠倒了什么？", left: "认识论的转向", right: "形而上学的转向",
        views: [
            ScholarView(name: "亨利·阿利森 Henry Allison", tag: "美国 · 当代", work: "Kant's Transcendental Idealism（1983/2004）",
                        view: "革命在于提出“认识条件”这一新视角：对象必须从我们认识它的条件来考察，这是方法上的转向，而不是说外物由心灵造出。", pos: 0.2),
            ScholarView(name: "P. F. 斯特劳森 Strawson", tag: "英国 · 分析哲学", work: "The Bounds of Sense（1966）",
                        view: "康德真正的贡献是勾画“任何可理解的经验”必须具有的结构；至于物自体与心灵“构造”世界的说法，他认为可以剥离。", pos: 0.35),
            ScholarView(name: "保罗·盖耶 Paul Guyer", tag: "美国 · 当代", work: "Kant and the Claims of Knowledge（1987）",
                        view: "康德确实主张空间、时间只属于我们的表象，这是一种实质性的形而上学立场，而不仅是方法上的视角。", pos: 0.75),
            ScholarView(name: "海德格尔 Heidegger", tag: "德国 · 现象学", work: "《康德与形而上学疑难》（1929）",
                        view: "《批判》不是知识论，而是为形而上学奠基；核心在于有限的人如何先行理解“存在”。", pos: 0.9),
        ],
        links: [sepKant, sepTI]),
    "kant-cpr:1": ScholarTopic(
        question: "先天综合判断真的存在吗？", left: "不存在 / 区分不成立", right: "存在",
        views: [
            ScholarView(name: "弗雷格 Frege", tag: "德国 · 逻辑", work: "《算术基础》（1884）",
                        view: "算术真理可以从逻辑与定义推出，是分析的；但他同意康德，几何学是先天综合的。", pos: 0.45),
            ScholarView(name: "罗素 Russell", tag: "英国 · 逻辑主义", work: "《数学原理》（1910–1913）",
                        view: "纯数学可以还原为逻辑，不需要康德所说的直观，因此不是先天综合的。", pos: 0.2),
            ScholarView(name: "蒯因 Quine", tag: "美国 · 分析哲学", work: "“经验论的两个教条”（1951）",
                        view: "分析与综合的区分本身就划不清，康德的问题因此失去了基础。", pos: 0.05),
            ScholarView(name: "迈克尔·弗里德曼 Michael Friedman", tag: "美国 · 科学哲学", work: "Dynamics of Reason（2001）",
                        view: "保留康德的洞见，但把先天原则“相对化”：每个科学时代都有自己构成性的先天框架，会随科学革命改变。", pos: 0.7),
        ],
        links: [sepKant, ("斯坦福哲学百科：The Analytic/Synthetic Distinction", "https://plato.stanford.edu/entries/analytic-synthetic/")]),
    "kant-cpr:2": ScholarTopic(
        question: "空间只是我们直观的形式吗？", left: "只是主观形式", right: "也可能是物自体的性质",
        views: [
            ScholarView(name: "库诺·费舍尔 Kuno Fischer", tag: "德国 · 19 世纪", work: "《近代哲学史·康德》（1860 年代）",
                        view: "捍卫康德：既然空间是先天直观形式，它就只能属于现象。", pos: 0.15),
            ScholarView(name: "特伦德伦堡 Trendelenburg", tag: "德国 · 19 世纪", work: "《逻辑研究》（1840）",
                        view: "提出“被忽视的选项”：空间可以既是先天的形式，同时也是物自体的实在性质，康德没有排除这种可能。", pos: 0.85),
            ScholarView(name: "爱因斯坦以后的物理学", tag: "20 世纪 · 科学", work: "广义相对论（1915）",
                        view: "物理空间可以是非欧几里得的，这让“欧氏几何是先天必然的”这一说法受到挑战；康德派的回应是区分直观空间与物理空间。", pos: 0.6),
        ],
        links: [("斯坦福哲学百科：Kant's Views on Space and Time", "https://plato.stanford.edu/entries/kant-spacetime/")]),
    "kant-cpr:3": ScholarTopic(
        question: "时间的观念性意味着什么？", left: "只是我们看世界的方式", right: "关乎实在本身",
        views: [
            ScholarView(name: "阿利森", tag: "美国 · 当代", work: "Kant's Transcendental Idealism（2004）",
                        view: "说时间是“观念的”，是说时间是我们认识事物的条件，并不否认事物在经验上真实地在时间中。", pos: 0.25),
            ScholarView(name: "叔本华", tag: "德国 · 19 世纪", work: "《作为意志和表象的世界》附录“康德哲学批判”（1819）",
                        view: "高度肯定感性论，认为时间、空间只属于表象世界；物自体就是没有时间形式的意志。", pos: 0.7),
            ScholarView(name: "海德格尔", tag: "德国 · 现象学", work: "《康德与形而上学疑难》（1929）",
                        view: "时间不只是一种直观形式，而是有限主体理解存在的根本境域。", pos: 0.9),
        ],
        links: [("斯坦福哲学百科：Kant's Views on Space and Time", "https://plato.stanford.edu/entries/kant-spacetime/")]),
    "kant-cpr:4": ScholarTopic(
        question: "直观可以没有概念吗？", left: "概念论：都需要概念", right: "非概念论：直观独立",
        views: [
            ScholarView(name: "约翰·麦克道尔 John McDowell", tag: "美国 · 当代", work: "Mind and World（1994）",
                        view: "借康德“思维无内容则空，直观无概念则盲”：经验本身就已经充满概念能力，否则无法为判断提供理由。", pos: 0.1),
            ScholarView(name: "威尔弗里德·塞拉斯 Sellars", tag: "美国 · 分析哲学", work: "Science and Metaphysics（1968）",
                        view: "从康德出发批判“所予的神话”：没有任何未经概念加工的东西能直接充当知识的基础。", pos: 0.2),
            ScholarView(name: "露西·阿莱 Lucy Allais 等", tag: "当代 · 非概念论", work: "Manifest Reality（2015）",
                        view: "康德承认直观可以独立于概念把对象给予我们，概念是后来加工整理的。", pos: 0.8),
        ],
        links: [("斯坦福哲学百科：Kant's View of the Mind and Consciousness of Self", "https://plato.stanford.edu/entries/kant-mind/")]),
    "kant-cpr:5": ScholarTopic(
        question: "范畴真能从判断表推出来吗？", left: "推导失败、表格随意", right: "推导有系统依据",
        views: [
            ScholarView(name: "黑格尔", tag: "德国 · 19 世纪", work: "《哲学史讲演录》",
                        view: "批评康德从逻辑教科书现成拿来判断形式，范畴没有被真正“推演”出来。", pos: 0.15),
            ScholarView(name: "斯特劳森", tag: "英国 · 分析哲学", work: "The Bounds of Sense（1966）",
                        view: "形而上学演绎基本是失败的，可以舍弃；康德真正有价值的是先验演绎。", pos: 0.2),
            ScholarView(name: "贝亚特丽丝·隆格内斯 Béatrice Longuenesse", tag: "法国 / 美国 · 当代", work: "Kant and the Capacity to Judge（1998）",
                        view: "判断形式虽取自当时的逻辑书，但康德挑选的正是把表象联系到对象所不可缺少的那些形式；“线索”有系统的根据。", pos: 0.85),
        ],
        links: [("斯坦福哲学百科：Kant's Theory of Judgment", "https://plato.stanford.edu/entries/kant-judgment/")]),
    "kant-cpr:6": ScholarTopic(
        question: "先验演绎的论证结构是什么？", left: "可剥离的“论证骨架”", right: "离不开心理学式的综合",
        views: [
            ScholarView(name: "迪特·亨利希 Dieter Henrich", tag: "德国 · 当代", work: "“The Proof-Structure of Kant's Transcendental Deduction”（1969）",
                        view: "第二版演绎分为两步（§20 与 §26），任何解释都必须说明为何第一步不够、第二步如何补足。这个问题至今仍是研究焦点。", pos: 0.45),
            ScholarView(name: "斯特劳森", tag: "英国 · 分析哲学", work: "The Bounds of Sense（1966）",
                        view: "可以把论证读成：自我意识要求经验具有客观、统一的结构；不必依赖“先验心理学”。", pos: 0.15),
            ScholarView(name: "帕特里夏·基切尔 Patricia Kitcher", tag: "美国 · 当代", work: "Kant's Transcendental Psychology（1990）",
                        view: "康德关于心灵综合活动的说法不是累赘，而是论证的实质部分，可以与认知科学对话。", pos: 0.85),
        ],
        links: [("斯坦福哲学百科：Transcendental Arguments", "https://plato.stanford.edu/entries/transcendental-arguments/")]),
    "kant-cpr:7": ScholarTopic(
        question: "图型法是必需的吗？", left: "多余", right: "关键环节",
        views: [
            ScholarView(name: "G. J. 沃诺克 Warnock", tag: "英国 · 分析哲学", work: "“Concepts and Schematism”（1949）",
                        view: "认为图型法要解决的问题并不存在：会使用一个概念，本身就包括会把它用到实例上，不需要第三者。", pos: 0.1),
            ScholarView(name: "海德格尔", tag: "德国 · 现象学", work: "《康德与形而上学疑难》（1929）",
                        view: "图型法是整部书的核心：想象力把范畴与时间结合起来，正是理解存在的关键。", pos: 0.95),
            ScholarView(name: "隆格内斯", tag: "当代", work: "Kant and the Capacity to Judge（1998）",
                        view: "图型是判断能力作用于感性的方式，承接演绎、连接原理，不可或缺。", pos: 0.75),
        ],
        links: [sepKant]),
    "kant-cpr:8": ScholarTopic(
        question: "数学为什么能运用于经验？", left: "因为直观的构造", right: "因为逻辑本身",
        views: [
            ScholarView(name: "康德派传统", tag: "—", work: "直观的公理",
                        view: "一切现象都是外延量，所以数学可以无条件地应用于经验。", pos: 0.15),
            ScholarView(name: "罗素", tag: "英国 · 逻辑主义", work: "《数学的原理》（1903）",
                        view: "数学是逻辑的延伸，并不依赖时空直观；康德的说法被现代逻辑取代。", pos: 0.85),
            ScholarView(name: "迈克尔·弗里德曼", tag: "美国 · 当代", work: "Kant and the Exact Sciences（1992）",
                        view: "在康德的时代，没有多重量词逻辑，直观的构造正好承担了现代逻辑的工作；这样看，他的立场是合理的。", pos: 0.4),
        ],
        links: [("斯坦福哲学百科：Kant's Philosophy of Mathematics", "https://plato.stanford.edu/entries/kant-mathematics/")]),
    "kant-cpr:9": ScholarTopic(
        question: "“知觉的预测”可信吗？", left: "过时的物理学", right: "仍有哲学价值",
        views: [
            ScholarView(name: "马堡学派 赫尔曼·柯亨 Hermann Cohen", tag: "德国 · 新康德主义", work: "《康德的经验理论》（1871）",
                        view: "重视“强度量”与微积分的联系，认为这一原理是理解实在概念的关键。", pos: 0.85),
            ScholarView(name: "多数分析派评论者", tag: "20 世纪", work: "—",
                        view: "这一部分与当时的物理学纠缠较深，一般认为哲学上的价值不如类比与演绎。", pos: 0.2),
        ],
        links: [sepKant]),
    "kant-cpr:10": ScholarTopic(
        question: "康德回答休谟了吗？", left: "没有", right: "成功回答",
        views: [
            ScholarView(name: "埃里克·沃特金斯 Eric Watkins", tag: "美国 · 当代", work: "Kant and the Metaphysics of Causality（2005）",
                        view: "康德的因果观要放回莱布尼茨—沃尔夫传统中理解：因果是实体的力量发挥作用，而不只是事件的规则相继。", pos: 0.6),
            ScholarView(name: "斯特劳森", tag: "英国 · 分析哲学", work: "The Bounds of Sense（1966）",
                        view: "认为第二类比从“客观时间顺序”直接推出“因果必然”，这一步推不过去。", pos: 0.15),
            ScholarView(name: "盖耶", tag: "美国 · 当代", work: "Kant and the Claims of Knowledge（1987）",
                        view: "类比的论证要靠“认识时间关系需要规则”来重建，部分成功。", pos: 0.5),
        ],
        links: [("斯坦福哲学百科：Kant and Hume on Causality", "https://plato.stanford.edu/entries/kant-hume-causality/")]),
    "kant-cpr:11": ScholarTopic(
        question: "“驳斥唯心论”成功了吗？", left: "失败", right: "成功",
        views: [
            ScholarView(name: "盖耶", tag: "美国 · 当代", work: "Kant and the Claims of Knowledge（1987）",
                        view: "把驳斥看成康德后期最重要的论证之一，并认为它要求外物在某种意义上独立于表象。", pos: 0.7),
            ScholarView(name: "很多分析派学者", tag: "—", work: "—",
                        view: "质疑：如果外物也只是表象，驳斥究竟驳斥了谁？这正是先验唯心论与驳斥之间的张力。", pos: 0.3),
        ],
        links: [sepTI]),
    "kant-cpr:12": ScholarTopic(
        question: "物自体是什么？", left: "同一事物的另一面", right: "另一个世界",
        views: [
            ScholarView(name: "阿利森", tag: "两方面说", work: "Kant's Transcendental Idealism（1983/2004）",
                        view: "现象与物自体是看同一事物的两个角度，而不是两类事物。", pos: 0.1),
            ScholarView(name: "瑞·兰顿 Rae Langton", tag: "英国 · 当代", work: "Kantian Humility（1998）",
                        view: "我们只认识事物的关系性质，不认识它们的内在性质；这是“认识上的谦卑”，而不是唯心论。", pos: 0.35),
            ScholarView(name: "盖耶", tag: "两世界说倾向", work: "Kant and the Claims of Knowledge（1987）",
                        view: "康德的文本确有把现象当作心灵表象、物自体当作另一实在的成分。", pos: 0.8),
            ScholarView(name: "牟宗三", tag: "中国 · 当代新儒家", work: "《现象与物自身》（1975）",
                        view: "康德否认人有“智的直觉”，因而物自体不可知；而儒释道认为人可以有智的直觉，物自体是价值意味的存在。", pos: 0.6),
        ],
        links: [sepTI]),
    "kant-cpr:13": ScholarTopic(
        question: "康德对莱布尼茨的批评公平吗？", left: "不公平", right: "击中要害",
        views: [
            ScholarView(name: "兰顿", tag: "英国 · 当代", work: "Kantian Humility（1998）",
                        view: "“反思概念的歧义”是理解物自体的钥匙：莱布尼茨把内在性质当成可认识的，康德恰恰否认这一点。", pos: 0.8),
            ScholarView(name: "部分莱布尼茨研究者", tag: "—", work: "—",
                        view: "康德把莱布尼茨简化为“把现象理智化”，忽略了莱布尼茨自己对现象与实体的区分。", pos: 0.25),
        ],
        links: [sepKant]),
    "kant-cpr:14": ScholarTopic(
        question: "先验幻相为什么不可避免？", left: "只是推理错误", right: "理性本身的倾向",
        views: [
            ScholarView(name: "米歇尔·格里尔 Michelle Grier", tag: "美国 · 当代", work: "Kant's Doctrine of Transcendental Illusion（2001）",
                        view: "幻相不同于逻辑谬误，它来自理性本身的原理，即使被看穿也不会消失；这也是理念能起调节作用的根源。", pos: 0.9),
            ScholarView(name: "贝内特", tag: "英国 · 分析哲学", work: "Kant's Dialectic（1974）",
                        view: "倾向于把辩证论读成对一系列具体谬误的诊断，幻相的“必然性”说法较难辩护。", pos: 0.25),
        ],
        links: [("斯坦福哲学百科：Kant's Account of Reason", "https://plato.stanford.edu/entries/kant-reason/")]),
    "kant-cpr:15": ScholarTopic(
        question: "理念有什么用？", left: "毫无认识价值", right: "引导科学研究",
        views: [
            ScholarView(name: "格里尔", tag: "美国 · 当代", work: "Kant's Doctrine of Transcendental Illusion（2001）",
                        view: "理念虽然不构成对象，却推动知识追求系统统一，对科学不可缺少。", pos: 0.85),
            ScholarView(name: "逻辑实证主义者", tag: "20 世纪", work: "—",
                        view: "超出经验的理念没有认识意义，只是形而上学的残余。", pos: 0.1),
        ],
        links: [("斯坦福哲学百科：Kant's Account of Reason", "https://plato.stanford.edu/entries/kant-reason/")]),
    "kant-cpr:16": ScholarTopic(
        question: "“我思”能证明灵魂实体吗？", left: "不能（康德）", right: "能（理性心理学）",
        views: [
            ScholarView(name: "卡尔·阿梅里克斯 Karl Ameriks", tag: "美国 · 当代", work: "Kant's Theory of Mind（1982）",
                        view: "康德只是否认能“证明”灵魂单纯、不朽，并没有否认灵魂可能是实体；他的立场比通常认为的更温和。", pos: 0.35),
            ScholarView(name: "斯特劳森", tag: "英国 · 分析哲学", work: "The Bounds of Sense（1966）",
                        view: "高度评价谬误推理章：自我意识的统一，并不等于对一个实体的认识。", pos: 0.1),
        ],
        links: [("斯坦福哲学百科：Kant's View of the Mind and Consciousness of Self", "https://plato.stanford.edu/entries/kant-mind/")]),
    "kant-cpr:17": ScholarTopic(
        question: "二律背反证明了先验唯心论吗？", left: "没有", right: "间接证明了",
        views: [
            ScholarView(name: "康德自己", tag: "—", work: "《纯粹理性批判》",
                        view: "宇宙论的矛盾只有把世界当作现象才能解决，因此是先验唯心论的间接证明。", pos: 0.9),
            ScholarView(name: "黑格尔", tag: "德国 · 19 世纪", work: "《逻辑学》",
                        view: "矛盾不该被归给理性的错用，它属于事物本身；康德对矛盾太“温柔”了。", pos: 0.2),
            ScholarView(name: "贝内特", tag: "英国 · 分析哲学", work: "Kant's Dialectic（1974）",
                        view: "逐一检查正反题的证明，认为其中不少论证本身就不成立。", pos: 0.15),
        ],
        links: [sepTI]),
    "kant-cpr:18": ScholarTopic(
        question: "存在是不是谓词？", left: "不是（康德）", right: "可以是",
        views: [
            ScholarView(name: "弗雷格", tag: "德国 · 逻辑", work: "《算术基础》（1884）",
                        view: "用现代逻辑重述：“存在”是二阶概念，说的是一个概念有实例，而不是对象的性质。", pos: 0.1),
            ScholarView(name: "艾伦·伍德 Allen Wood", tag: "美国 · 当代", work: "Kant's Rational Theology（1978）",
                        view: "系统梳理康德对本体论、宇宙论、自然神学三种证明的批判，指出后两者最终都依赖本体论证明。", pos: 0.3),
            ScholarView(name: "普兰丁格等", tag: "当代宗教哲学", work: "The Nature of Necessity（1974）",
                        view: "用模态逻辑重构本体论证明，认为它不必依赖“存在是谓词”。", pos: 0.8),
        ],
        links: [("斯坦福哲学百科：Kant's Philosophy of Religion", "https://plato.stanford.edu/entries/kant-religion/")]),
    "kant-cpr:19": ScholarTopic(
        question: "调节性原理只是“好用的假设”吗？", left: "只是启发法", right: "具有先验地位",
        views: [
            ScholarView(name: "格里尔", tag: "美国 · 当代", work: "Kant's Doctrine of Transcendental Illusion（2001）",
                        view: "系统统一的要求有某种先验的必然性，不只是方便的研究策略。", pos: 0.8),
            ScholarView(name: "盖耶", tag: "美国 · 当代", work: "“Reason and Reflective Judgment”（1990）",
                        view: "调节性原理与第三批判的反思判断力关系密切，地位介于主观与客观之间。", pos: 0.55),
        ],
        links: [("斯坦福哲学百科：Kant's Account of Reason", "https://plato.stanford.edu/entries/kant-reason/")]),
    "kant-cpr:20": ScholarTopic(
        question: "哲学能像数学那样从定义出发吗？", left: "不能（康德）", right: "能（理性主义）",
        views: [
            ScholarView(name: "康德", tag: "—", work: "《纯粹理性批判》方法论",
                        view: "数学在直观中构造概念，哲学只能分析概念；把数学方法搬进哲学只会产生空中楼阁。", pos: 0.1),
            ScholarView(name: "斯宾诺莎（被批评的一方）", tag: "17 世纪", work: "《伦理学》（1677）",
                        view: "以几何学方式，从定义与公理推出全部哲学。", pos: 0.9),
        ],
        links: [("斯坦福哲学百科：Kant's Philosophy of Mathematics", "https://plato.stanford.edu/entries/kant-mathematics/")]),
    "kant-cpr:21": ScholarTopic(
        question: "第一批判与道德、宗教是什么关系？", left: "认识论为主", right: "实践目的为主",
        views: [
            ScholarView(name: "李泽厚", tag: "中国 · 当代", work: "《批判哲学的批判》（1979）",
                        view: "以“主体性”重读康德：认识论问题背后是人的实践与历史；对中国的康德研究影响很大。", pos: 0.6),
            ScholarView(name: "伍德", tag: "美国 · 当代", work: "Kant's Moral Religion（1970）",
                        view: "“法规”一章预示了实践理性对上帝、不朽的“公设”：信仰的根据在道德，不在思辨。", pos: 0.85),
        ],
        links: [sepKant]),
    "kant-cpr:22": ScholarTopic(
        question: "哲学体系必须是“建筑术”的吗？", left: "体系是束缚", right: "体系是必要",
        views: [
            ScholarView(name: "黑格尔", tag: "德国 · 19 世纪", work: "《精神现象学》序言（1807）",
                        view: "同意哲学必须是体系，但认为康德的体系只是外在拼接，真正的体系应当是概念自身的发展。", pos: 0.8),
            ScholarView(name: "尼采", tag: "德国 · 19 世纪", work: "《偶像的黄昏》（1889）",
                        view: "对体系的意志是缺乏正直的表现。", pos: 0.1),
        ],
        links: [sepKant]),
    "kant-cpr:23": ScholarTopic(
        question: "批判之后，形而上学还可能吗？", left: "终结了", right: "以新方式重生",
        views: [
            ScholarView(name: "维也纳学派", tag: "20 世纪 · 逻辑实证主义", work: "—",
                        view: "沿着康德拒斥独断形而上学的方向走得更远：形而上学命题没有意义。", pos: 0.1),
            ScholarView(name: "德国观念论（费希特、谢林、黑格尔）", tag: "19 世纪", work: "—",
                        view: "从康德出发建立新的形而上学体系，克服现象与物自体的二元。", pos: 0.9),
            ScholarView(name: "斯特劳森", tag: "英国 · 分析哲学", work: "Individuals（1959）",
                        view: "提出“描述的形而上学”：描述我们思考世界时实际使用的概念框架，这正是康德式的工作。", pos: 0.6),
        ],
        links: [sepKant]),
]

// MARK: - 界面：观点光谱 + 观点卡片

struct ScholarsView: View {
    let topic: ScholarTopic
    @State private var shown = 0
    @State private var selected: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(topic.question)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(Color.primary)

            // 观点光谱
            VStack(spacing: 6) {
                GeometryReader { geo in
                    let w = geo.size.width
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(LinearGradient(colors: [Moon.silver.opacity(0.5), Moon.gold.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            .frame(height: 3)
                            .frame(maxHeight: .infinity)
                        ForEach(Array(topic.views.enumerated()), id: \.offset) { i, v in
                            let on = i < shown
                            let sel = selected == v.name
                            let y: CGFloat = i % 2 == 0 ? -22 : 22
                            Button {
                                withAnimation(.spring(duration: 0.4, bounce: 0.25)) { selected = sel ? nil : v.name }
                            } label: {
                                VStack(spacing: 3) {
                                    Circle().fill(sel ? Moon.gold : Moon.silver).frame(width: sel ? 16 : 12, height: sel ? 16 : 12)
                                        .glassEffect(.regular.interactive(), in: .circle)
                                    Text(shortName(v.name)).font(.caption2.weight(.medium)).lineLimit(1).fixedSize()
                                        .foregroundStyle(sel ? Moon.gold : Color.primary.opacity(0.75))
                                }
                            }
                            .buttonStyle(.plain)
                            .position(x: 16 + (w - 32) * v.pos, y: geo.size.height / 2 + y)
                            .opacity(on ? 1 : 0)
                            .scaleEffect(on ? 1 : 0.3)
                        }
                    }
                }
                .frame(height: 96)
                HStack {
                    Text(topic.left)
                    Spacer()
                    Text(topic.right)
                }
                .font(.caption2)
                .foregroundStyle(Color.primary.opacity(0.55))
            }
            .padding(14)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))

            // 观点卡片
            ForEach(Array(topic.views.enumerated()), id: \.offset) { i, v in
                let sel = selected == v.name
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(v.name).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(v.tag).font(.caption2).foregroundStyle(Color.primary.opacity(0.5))
                    }
                    Text(v.work).font(.caption).foregroundStyle(Moon.gold)
                    Text(v.view).font(.callout).foregroundStyle(Color.primary.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(sel ? .regular.tint(Moon.gold.opacity(0.15)) : .regular, in: .rect(cornerRadius: 18))
                .opacity(i < shown ? 1 : 0)
                .offset(y: i < shown ? 0 : 12)
                .onTapGesture { withAnimation(.spring(duration: 0.4)) { selected = sel ? nil : v.name } }
            }

            if !topic.links.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("延伸阅读").font(.caption.weight(.semibold)).foregroundStyle(Color.primary.opacity(0.6))
                    ForEach(topic.links, id: \.1) { l in
                        Link(destination: URL(string: l.1)!) {
                            Label(l.0, systemImage: "arrow.up.right.square").font(.caption)
                        }
                    }
                }
            }
            Text("以上为对各家观点的概括，不是原文引用；同一问题上学界仍有争论，排列位置只表示大致倾向。")
                .font(.caption2)
                .foregroundStyle(Color.primary.opacity(0.45))
        }
        .task {
            for i in topic.views.indices {
                try? await Task.sleep(for: .milliseconds(i == 0 ? 250 : 420))
                withAnimation(.spring(duration: 0.55, bounce: 0.3)) { shown = i + 1 }
            }
        }
    }

    private func shortName(_ n: String) -> String {
        String(n.split(separator: " ").first ?? Substring(n))
    }
}

// MARK: - 历代注疏（与原文段落对齐；全部为公有领域原文）

struct CommentDoc: Codable {
    struct Source: Codable { let name: String; let items: [String: String] }
    let id: String
    let sources: [Source]
}

@MainActor
final class CommentStore {
    static let shared = CommentStore()
    private var docs: [String: CommentDoc] = [:]
    private var fetched: Set<String> = []

    private let dir: URL = {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("comments", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }()

    func load(_ id: String) async -> CommentDoc? {
        let file = dir.appendingPathComponent("\(id).json")
        if docs[id] == nil,
           let src = FileManager.default.fileExists(atPath: file.path) ? file : TextStore.bundled("comments", id),
           let data = try? Data(contentsOf: src), let doc = try? JSONDecoder().decode(CommentDoc.self, from: data) {
            docs[id] = doc
        }
        if !fetched.contains(id) {
            let url = URL(string: "https://raw.githubusercontent.com/alicelikeeat/moon-myths/main/comments/\(id).json")!
            let result = await Task.detached { try? await URLSession.shared.data(from: url) }.value
            if let res = result, (res.1 as? HTTPURLResponse)?.statusCode == 200,
               let doc = try? JSONDecoder().decode(CommentDoc.self, from: res.0) {
                try? res.0.write(to: file, options: .atomic)
                docs[id] = doc
                fetched.insert(id)
            } else if (result?.1 as? HTTPURLResponse)?.statusCode == 404 {
                fetched.insert(id)          // 这本书没有注疏
            }
        }
        return docs[id]
    }
}

struct CommentaryBox: View {
    let notes: [(String, String)]   // (来源, 注文)
    @State private var open = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.snappy(duration: 0.25)) { open.toggle() }
            } label: {
                Label(open ? "收起注疏" : "注疏 · \(notes.map(\.0).joined(separator: "、"))", systemImage: "text.book.closed")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.primary.opacity(0.6))
                    .lineLimit(1)
            }
            .buttonStyle(.glass)
            if open {
                ForEach(notes, id: \.0) { n in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(n.0).font(.caption.weight(.semibold)).foregroundStyle(Moon.gold)
                        Text(n.1.replacingOccurrences(of: " ○ ", with: "\n○ "))
                            .font(.system(size: 15, design: .serif))
                            .foregroundStyle(Color.primary.opacity(0.8))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .textSelection(.enabled)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: .rect(cornerRadius: 14))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}
