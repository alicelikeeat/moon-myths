import SwiftUI

// MARK: - 数据

enum Region: String, CaseIterable {
    case china, west
    var title: String { self == .china ? "中国" : "西方" }
}

struct Thinker: Identifiable {
    let id: String
    let name: String
    let region: Region
    let born: Int          // 公元前用负数
    let died: Int
    let approx: Bool       // 生卒年有争议或只是约数
    let thesis: String
    var libraryId: String? = nil   // 已有深度内容时，指向书库里的人物
}

struct Era {
    let region: Region
    let name: String
    let start: Int
    let end: Int
}

struct Influence {
    let from: String
    let to: String
    var critical = false   // 以批判、反叛为主的影响
}

func yearText(_ y: Int) -> String { y < 0 ? "前\(-y)" : "\(y)" }

let thinkers: [Thinker] = [
    // 中国
    Thinker(id: "laozi", name: "老子", region: .china, born: -600, died: -470, approx: true,
            thesis: "以“道”为万物本源，主张无为、柔弱、返璞归真。生卒年不详。"),
    Thinker(id: "kongzi", name: "孔子", region: .china, born: -551, died: -479, approx: false,
            thesis: "以“仁”为核心、“礼”为规范，开创儒家，重视教育与修身。"),
    Thinker(id: "mozi", name: "墨子", region: .china, born: -470, died: -391, approx: true,
            thesis: "墨家创始人：兼爱、非攻、尚贤、节用，重视逻辑与实证。"),
    Thinker(id: "mengzi", name: "孟子", region: .china, born: -372, died: -289, approx: true,
            thesis: "性善论：人皆有恻隐之心；主张仁政与民本。"),
    Thinker(id: "zhuangzi", name: "庄子", region: .china, born: -369, died: -286, approx: true,
            thesis: "齐物与逍遥：打破是非、物我、生死的界限。"),
    Thinker(id: "xunzi", name: "荀子", region: .china, born: -313, died: -238, approx: true,
            thesis: "性恶论：人性需要礼义与后天教化来矫正。"),
    Thinker(id: "hanfei", name: "韩非", region: .china, born: -280, died: -233, approx: true,
            thesis: "法家集大成者：法、术、势相结合的治国之道。"),
    Thinker(id: "dongzhongshu", name: "董仲舒", region: .china, born: -179, died: -104, approx: true,
            thesis: "天人感应，推动儒学成为汉代官方学说。"),
    Thinker(id: "huineng", name: "慧能", region: .china, born: 638, died: 713, approx: false,
            thesis: "禅宗六祖：主张顿悟，明心见性，见性成佛。"),
    Thinker(id: "zhuxi", name: "朱熹", region: .china, born: 1130, died: 1200, approx: false,
            thesis: "理学集大成：格物致知，理与气不离不杂。"),
    Thinker(id: "wangyangming", name: "王阳明", region: .china, born: 1472, died: 1529, approx: false,
            thesis: "心学：心即理、知行合一、致良知。"),
    Thinker(id: "wangfuzhi", name: "王夫之", region: .china, born: 1619, died: 1692, approx: false,
            thesis: "以气为本，反思宋明理学，重视历史与实践。"),
    // 西方
    Thinker(id: "socrates", name: "苏格拉底", region: .west, born: -470, died: -399, approx: true,
            thesis: "以诘问追问定义；认为未经审视的生活不值得过。"),
    Thinker(id: "plato", name: "柏拉图", region: .west, born: -427, died: -347, approx: true,
            thesis: "理念论：可感事物只是永恒理念的摹本。"),
    Thinker(id: "aristotle", name: "亚里士多德", region: .west, born: -384, died: -322, approx: false,
            thesis: "形式与质料、四因说，奠定形式逻辑。"),
    Thinker(id: "augustine", name: "奥古斯丁", region: .west, born: 354, died: 430, approx: false,
            thesis: "信仰寻求理解；时间是心灵的延展。"),
    Thinker(id: "aquinas", name: "阿奎那", region: .west, born: 1225, died: 1274, approx: true,
            thesis: "融合亚里士多德哲学与基督教神学。"),
    Thinker(id: "descartes", name: "笛卡尔", region: .west, born: 1596, died: 1650, approx: false,
            thesis: "我思故我在；心与物是两种实体。"),
    Thinker(id: "spinoza", name: "斯宾诺莎", region: .west, born: 1632, died: 1677, approx: false,
            thesis: "神即自然：只有唯一的实体。"),
    Thinker(id: "leibniz", name: "莱布尼茨", region: .west, born: 1646, died: 1716, approx: false,
            thesis: "单子论与前定和谐。"),
    Thinker(id: "hume", name: "休谟", region: .west, born: 1711, died: 1776, approx: false,
            thesis: "因果只是习惯性的联想；归纳无法被理性证明。"),
    Thinker(id: "kant", name: "康德", region: .west, born: 1724, died: 1804, approx: false,
            thesis: "哥白尼式革命：对象符合认识的先天形式。", libraryId: "kant"),
    Thinker(id: "hegel", name: "黑格尔", region: .west, born: 1770, died: 1831, approx: false,
            thesis: "真理是全体：精神在否定中展开自身。", libraryId: "hegel"),
    Thinker(id: "nietzsche", name: "尼采", region: .west, born: 1844, died: 1900, approx: false,
            thesis: "重估一切价值；权力意志与永恒轮回。"),
    Thinker(id: "russell", name: "罗素", region: .west, born: 1872, died: 1970, approx: false,
            thesis: "用逻辑分析澄清语言、数学与知识。", libraryId: "russell"),
    Thinker(id: "wittgenstein", name: "维特根斯坦", region: .west, born: 1889, died: 1951, approx: false,
            thesis: "早期：语言的界限即世界的界限；后期：意义在于使用。"),
]

let eras: [Era] = [
    Era(region: .china, name: "春秋", start: -770, end: -476),
    Era(region: .china, name: "战国", start: -475, end: -221),
    Era(region: .china, name: "秦汉", start: -221, end: 220),
    Era(region: .china, name: "魏晋南北朝", start: 220, end: 589),
    Era(region: .china, name: "隋唐", start: 589, end: 907),
    Era(region: .china, name: "宋元", start: 960, end: 1368),
    Era(region: .china, name: "明", start: 1368, end: 1644),
    Era(region: .china, name: "清", start: 1644, end: 1912),
    Era(region: .west, name: "古希腊", start: -600, end: -323),
    Era(region: .west, name: "希腊化与罗马", start: -323, end: 476),
    Era(region: .west, name: "中世纪", start: 476, end: 1400),
    Era(region: .west, name: "文艺复兴", start: 1400, end: 1600),
    Era(region: .west, name: "近代哲学", start: 1600, end: 1781),
    Era(region: .west, name: "德国古典", start: 1781, end: 1831),
    Era(region: .west, name: "现代哲学", start: 1831, end: 2000),
]

let influences: [Influence] = [
    Influence(from: "kongzi", to: "mengzi"), Influence(from: "kongzi", to: "xunzi"),
    Influence(from: "xunzi", to: "hanfei"), Influence(from: "laozi", to: "zhuangzi"),
    Influence(from: "kongzi", to: "dongzhongshu"), Influence(from: "mengzi", to: "zhuxi"),
    Influence(from: "zhuxi", to: "wangyangming", critical: true),
    Influence(from: "socrates", to: "plato"), Influence(from: "plato", to: "aristotle"),
    Influence(from: "plato", to: "augustine"), Influence(from: "aristotle", to: "aquinas"),
    Influence(from: "descartes", to: "spinoza"), Influence(from: "descartes", to: "leibniz"),
    Influence(from: "leibniz", to: "kant"), Influence(from: "hume", to: "kant"),
    Influence(from: "kant", to: "hegel"), Influence(from: "hegel", to: "russell", critical: true),
    Influence(from: "russell", to: "wittgenstein"),
]

// MARK: - 布局

private let minYear = -800
private let maxYear = 2000

private struct Placed {
    let thinker: Thinker
    let x: Double, y: Double, w: Double
}

private struct Layout {
    var placed: [Placed] = []
    var tops: [Region: Double] = [:]
    var heights: [Region: Double] = [:]
    var total = 0.0
}

/// 每条泳道按需要的行数自动加高，人物胶囊互不重叠
private func layout(scale: Double) -> Layout {
    var L = Layout()
    var top = 70.0
    for region in Region.allCases {
        var rowEnds: [Double] = []
        for t in thinkers.filter({ $0.region == region }).sorted(by: { $0.born < $1.born }) {
            let x = Double(t.born - minYear) * scale
            let w = max(Double(t.died - t.born) * scale, 78)
            let row = rowEnds.firstIndex { $0 + 8 <= x } ?? rowEnds.count
            if row == rowEnds.count { rowEnds.append(x + w) } else { rowEnds[row] = x + w }
            L.placed.append(Placed(thinker: t, x: x, y: top + 44 + Double(row) * 44, w: w))
        }
        let h = 60 + Double(rowEnds.count) * 44 + 24
        L.tops[region] = top
        L.heights[region] = h
        top += h + 20
    }
    L.total = top + 10
    return L
}

// MARK: - 视图

struct HistoryTimelineView: View {
    @State private var scale = 0.8           // 每年多少点
    @GestureState private var pinch = 1.0
    @State private var selected: Thinker?

    var body: some View {
        let s = min(4, max(0.12, scale * pinch))
        let L = layout(scale: s)
        let placed = L.placed
        let width = Double(maxYear - minYear) * s + 60
        ZStack {
            Backdrop()
            ScrollView(.horizontal) {
                ZStack(alignment: .topLeading) {
                    lanes(s, L)
                    links(placed)
                    ForEach(placed, id: \.thinker.id) { p in
                        Button { selected = p.thinker } label: {
                            capsule(p)
                        }
                        .buttonStyle(.plain)
                        .position(x: p.x + p.w / 2 + 30, y: p.y)
                    }
                }
                .frame(width: width, height: L.total, alignment: .topLeading)
            }
            .scrollIndicators(.hidden)
            .simultaneousGesture(
                MagnifyGesture()
                    .updating($pinch) { v, st, _ in st = v.magnification }
                    .onEnded { v in scale = min(4, max(0.12, scale * v.magnification)) }
            )
        }
        .navigationTitle("时间轴")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Text("双指缩放 · 左右滑动 · 点人物看详情")
                .font(.caption).foregroundStyle(Color.primary.opacity(0.6))
                .padding(.horizontal, 16).padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
                .padding(.bottom, 6)
        }
        .sheet(item: $selected) { t in ThinkerSheet(thinker: t) }
    }

    private func lanes(_ s: Double, _ L: Layout) -> some View {
        Canvas { ctx, size in
            for region in Region.allCases {
                let top = L.tops[region] ?? 0
                let height = L.heights[region] ?? 200
                let lane = Path(roundedRect: CGRect(x: 10, y: top, width: Double(size.width) - 20, height: height), cornerRadius: 24)
                ctx.fill(lane, with: .color(Color.primary.opacity(0.04)))
                ctx.draw(Text(region.title).font(.system(size: 13, weight: .semibold)).foregroundColor(Moon.silver),
                         at: CGPoint(x: 40, y: top + 14))
                for (ei, e) in eras.filter({ $0.region == region }).enumerated() {
                    let x0 = Double(e.start - minYear) * s + 30, x1 = Double(e.end - minYear) * s + 30
                    let r = CGRect(x: x0, y: top + 24, width: max(1, x1 - x0), height: height - 30)
                    ctx.fill(Path(r), with: .color((ei % 2 == 0 ? Moon.violet : Moon.silver).opacity(0.06)))
                    if x1 - x0 > 30 {
                        ctx.draw(Text(e.name).font(.system(size: 11)).foregroundColor(Color.primary.opacity(0.45)),
                                 at: CGPoint(x: (x0 + x1) / 2, y: top + height - 14))
                    }
                }
            }
            // 年代刻度
            let step = s > 1.5 ? 50 : (s > 0.5 ? 100 : 200)
            var y = (minYear / step) * step
            while y <= maxYear {
                let x = Double(y - minYear) * s + 30
                ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: 40)); p.addLine(to: CGPoint(x: x, y: 50)) },
                           with: .color(Color.primary.opacity(0.35)), lineWidth: 1)
                ctx.draw(Text(y == 0 ? "公元" : yearText(y)).font(.system(size: 10).monospacedDigit())
                            .foregroundColor(Color.primary.opacity(0.5)),
                         at: CGPoint(x: x, y: 30))
                y += step
            }
        }
        .allowsHitTesting(false)
    }

    private func links(_ placed: [Placed]) -> some View {
        Canvas { ctx, _ in
            let pos = Dictionary(uniqueKeysWithValues: placed.map { ($0.thinker.id, $0) })
            for inf in influences {
                guard let a = pos[inf.from], let b = pos[inf.to] else { continue }
                let p0 = CGPoint(x: a.x + a.w / 2 + 30, y: a.y)
                let p1 = CGPoint(x: b.x + b.w / 2 + 30, y: b.y)
                var path = Path()
                path.move(to: p0)
                path.addQuadCurve(to: p1, control: CGPoint(x: (p0.x + p1.x) / 2, y: min(p0.y, p1.y) - 30))
                ctx.stroke(path, with: .color((inf.critical ? Moon.violet : Moon.gold).opacity(0.55)),
                           style: StrokeStyle(lineWidth: 1.2, dash: inf.critical ? [4, 4] : []))
            }
        }
        .allowsHitTesting(false)
    }

    private func capsule(_ p: Placed) -> some View {
        let t = p.thinker
        let deep = t.libraryId != nil
        return VStack(spacing: 0) {
            Text(t.name).font(.system(size: 13, weight: .semibold))
            Text("\(t.approx ? "约" : "")\(yearText(t.born))–\(yearText(t.died))")
                .font(.system(size: 9).monospacedDigit()).opacity(0.7)
        }
        .foregroundStyle(Color.primary)
        .frame(width: p.w, height: 36)
        .mask {
            // 生卒年不确定时两端渐隐
            LinearGradient(stops: t.approx
                           ? [.init(color: .black.opacity(0.35), location: 0), .init(color: .black, location: 0.2),
                              .init(color: .black, location: 0.8), .init(color: .black.opacity(0.35), location: 1)]
                           : [.init(color: .black, location: 0), .init(color: .black, location: 1)],
                           startPoint: .leading, endPoint: .trailing)
        }
        .glassEffect(Glass.regular.tint((deep ? Moon.gold : (t.region == .china ? Moon.violet : Moon.silver)).opacity(deep ? 0.35 : 0.18)).interactive(),
                     in: .capsule)
    }
}

// MARK: - 人物卡片

private struct ThinkerSheet: View {
    let thinker: Thinker

    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(thinker.name)
                            .font(.system(size: 34, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        Text("\(thinker.region.title) · \(thinker.approx ? "约" : "")\(yearText(thinker.born))–\(yearText(thinker.died))\(thinker.approx ? "（生卒年说法不一）" : "")")
                            .font(.subheadline).foregroundStyle(Color.primary.opacity(0.6))
                        Text(thinker.thesis)
                            .font(.title3).foregroundStyle(Color.primary)
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.regular, in: .rect(cornerRadius: 22))
                        relations
                        if let pid = thinker.libraryId, let p = library.first(where: { $0.id == pid }) {
                            Text("深度内容").font(.headline).foregroundStyle(Color.primary).padding(.top, 6)
                            ForEach(p.books) { b in
                                NavigationLink {
                                    BookView(book: b)
                                } label: {
                                    Label("《\(b.title)》 · \(b.chapters.count) 章", systemImage: "book.closed")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(14)
                                        .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if let works = thinkerWorks[thinker.id] {
                            Text("全文").font(.headline).foregroundStyle(Color.primary).padding(.top, 6)
                            ForEach(works) { b in
                                NavigationLink {
                                    BookReaderView(book: b)
                                } label: {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Label("《\(b.title)》", systemImage: "text.book.closed").font(.body.weight(.semibold))
                                        Text("\(b.year) · \(b.summary)").font(.caption).foregroundStyle(Color.primary.opacity(0.6))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if thinker.libraryId == nil {
                            Text(thinkerWorks[thinker.id] == nil
                                 ? "暂无可用的公有领域全文；章节动画将逐步加入。"
                                 : "章节动画与三语原文将逐步加入。")
                                .font(.footnote).foregroundStyle(Color.primary.opacity(0.5))
                        }
                    }
                    .padding(20)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private var relations: some View {
        let from = influences.filter { $0.to == thinker.id }.compactMap { i in thinkers.first { $0.id == i.from }.map { ($0, i.critical) } }
        let to = influences.filter { $0.from == thinker.id }.compactMap { i in thinkers.first { $0.id == i.to }.map { ($0, i.critical) } }
        if !from.isEmpty || !to.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                if !from.isEmpty {
                    Text("思想来源：" + from.map { $0.0.name + ($0.1 ? "（批判继承）" : "") }.joined(separator: "、"))
                }
                if !to.isEmpty {
                    Text("影响了：" + to.map { $0.0.name + ($0.1 ? "（批判继承）" : "") }.joined(separator: "、"))
                }
            }
            .font(.subheadline).foregroundStyle(Color.primary.opacity(0.8))
        }
    }
}

// MARK: - 时间轴人物的著作全文（只收公有领域版本）

private func work(_ id: String, _ title: String, _ original: String, _ year: String, _ summary: String) -> Book {
    Book(id: id, title: title, original: original, year: year, summary: summary,
         parts: workParts(id), chapters: workChapters[id] ?? [])
}

let thinkerWorks: [String: [Book]] = [
    "kongzi": [work("lunyu", "论语", "論語", "春秋末至战国初", "孔子及其弟子的言行录。原文 + 理雅各（Legge）英译。")],
    "laozi": [work("daodejing", "道德经", "道德經", "约战国", "五千言，八十一章。原文 + 理雅各英译。")],
    "zhuangzi": [work("zhuangzi", "庄子", "Chuang Tzu (tr. Giles)", "战国", "原文全文（漢籍リポジトリ）+ 翟理斯（Giles）1889 年英译。")],
    "mengzi": [work("mengzi", "孟子", "孟子", "战国", "性善、四端、仁政、民贵君轻。原文全文。")],
    "hanfei": [work("hanfeizi", "韩非子", "韓非子（四庫本）", "战国末", "法、术、势；二柄；以法为教。四库全书本原文（无标点）。")],
    "zhuxi": [work("zhuziyulei", "朱子语类", "朱子語類（四庫本）", "1270 年编成", "朱熹与弟子的问答，共 140 卷：理气、性理、为学、四书。四库全书本原文（无标点），分四册。")],
    "mozi": [work("mozi", "墨子", "墨子", "战国", "兼爱、非攻、尚贤、节用，以及墨辩。")],
    "xunzi": [work("xunzi", "荀子集解", "荀子集解（王先謙）", "战国 / 清代集解", "《荀子》原文与王先谦集解（1891）。")],
    "dongzhongshu": [work("chunqiufanlu", "春秋繁露", "春秋繁露", "西汉", "以阴阳五行解释《春秋》，提出天人感应。")],
    "huineng": [work("tanjing", "六祖坛经", "六祖大師法寶壇經", "唐", "慧能说法，弟子法海集录。")],
    "wangyangming": [work("chuanxilu", "传习录", "傳習錄", "明", "王阳明与弟子的问答语录。")],
    "socrates": [work("apology", "申辩篇", "Apology (Plato, tr. Jowett)", "约前 399 年后", "柏拉图记述的苏格拉底受审答辩。乔伊特英译。")],
    "plato": [work("republic", "理想国", "The Republic (tr. Jowett)", "约前 375 年", "正义、理念与洞穴之喻。乔伊特英译。")],
    "augustine": [work("confessions", "忏悔录", "The Confessions (tr. Pusey)", "约 400 年", "包含著名的时间之问。蒲赛英译。")],
    "descartes": [
        work("discourse", "谈谈方法", "Discourse on the Method (tr. Veitch)", "1637", "“我思故我在”首次出现于此。维奇英译。"),
        work("meditationes", "第一哲学沉思集", "Meditationes de prima philosophia", "1641", "拉丁文原文。"),
    ],
    "spinoza": [work("ethics", "伦理学", "Ethics (tr. Elwes)", "1677", "按几何学方式证明。埃尔维斯英译。")],
    "hume": [work("enquiry", "人类理解研究", "An Enquiry Concerning Human Understanding", "1748", "因果、习惯与归纳问题。英文原著。")],
    "aristotle": [work("nicomachean", "尼各马可伦理学", "The Ethics of Aristotle (tr. Chase)", "约前 4 世纪", "幸福、德性与中道。蔡斯（Chase）1847 年英译。")],
    "aquinas": [work("summa", "神学大全（第一集）", "Summa Theologica, Part I", "1265–1274", "包含证明上帝存在的“五路”。多明我会英译。")],
    "leibniz": [work("monadologie", "单子论", "La Monadologie", "1714", "法文原文（皮亚 1909 年校注本）。")],
    "wittgenstein": [work("tractatus", "逻辑哲学论", "Logisch-philosophische Abhandlung", "1921", "德文原文，526 条编号命题。")],
    "nietzsche": [work("zarathustra", "查拉图斯特拉如是说", "Also sprach Zarathustra", "1883–1885", "德文原文 + 康芒（Common）英译。")],
]

/// 时间轴人物著作的全文版本
let thinkerFullTexts: [String: [FullText]] = [
    "lunyu": [FullText(id: "lunyu-zh", label: "原文"), FullText(id: "lunyu-en", label: "English")],
    "daodejing": [FullText(id: "daodejing-zh", label: "原文"), FullText(id: "daodejing-en", label: "English")],
    "zhuangzi": [FullText(id: "zhuangzi-zh", label: "原文"), FullText(id: "zhuangzi-en", label: "English")],
    "mengzi": [FullText(id: "mengzi-zh", label: "原文")],
    "hanfeizi": [FullText(id: "hanfeizi-zh", label: "原文")],
    "zhuziyulei": [FullText(id: "zhuziyulei-1-zh", label: "卷1–35"), FullText(id: "zhuziyulei-36-zh", label: "卷36–70"),
                   FullText(id: "zhuziyulei-71-zh", label: "卷71–105"), FullText(id: "zhuziyulei-106-zh", label: "卷106–140")],
    "mozi": [FullText(id: "mozi-zh", label: "原文")],
    "xunzi": [FullText(id: "xunzi-zh", label: "原文")],
    "chunqiufanlu": [FullText(id: "chunqiufanlu-zh", label: "原文")],
    "tanjing": [FullText(id: "tanjing-zh", label: "原文")],
    "chuanxilu": [FullText(id: "chuanxilu-zh", label: "原文")],
    "apology": [FullText(id: "apology-en", label: "English")],
    "republic": [FullText(id: "republic-en", label: "English")],
    "confessions": [FullText(id: "confessions-en", label: "English")],
    "discourse": [FullText(id: "discourse-en", label: "English")],
    "meditationes": [FullText(id: "meditationes-la", label: "Latina")],
    "ethics": [FullText(id: "ethics-en", label: "English")],
    "enquiry": [FullText(id: "enquiry-en", label: "English")],
    "zarathustra": [FullText(id: "zarathustra-de", label: "Deutsch"), FullText(id: "zarathustra-en", label: "English")],
    "nicomachean": [FullText(id: "ethics-aristotle-en", label: "English")],
    "summa": [FullText(id: "summa-en", label: "English")],
    "monadologie": [FullText(id: "monadologie-fr", label: "Français")],
    "tractatus": [FullText(id: "tractatus-de", label: "Deutsch")],
]
