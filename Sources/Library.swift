import SwiftUI

struct Book: Identifiable {
    let id: String
    let title: String
    let original: String
    let year: String
    let summary: String
    let parts: [String]
    let chapters: [Chapter]
}

struct Philosopher: Identifiable {
    let id: String
    let name: String
    let dates: String
    let line: String
    let books: [Book]
}

let library: [Philosopher] = [
    Philosopher(id: "kant", name: "康德", dates: "1724–1804",
                line: "认识的边界：我们能知道什么？",
                books: [
                    Book(id: "kant-cpr", title: "纯粹理性批判", original: "Kritik der reinen Vernunft", year: "1781 / 1787",
                         summary: "先天综合判断如何可能，以及理性越界时的必然幻相。",
                         parts: kantParts, chapters: kantChapters),
                ]),
    Philosopher(id: "hegel", name: "黑格尔", dates: "1770–1831",
                line: "真理是全体：精神在否定中展开自身。",
                books: [
                    Book(id: "hegel-phen", title: "精神现象学", original: "Phänomenologie des Geistes", year: "1807",
                         summary: "意识从最朴素的感性确定性出发，一步步上升到绝对知识。",
                         parts: hegelPhenParts, chapters: hegelPhenChapters),
                    Book(id: "hegel-logic", title: "逻辑学", original: "Wissenschaft der Logik", year: "1812–1816",
                         summary: "从最空洞的“有”出发，推演出全部思维规定。",
                         parts: hegelLogicParts, chapters: hegelLogicChapters),
                ]),
    Philosopher(id: "russell", name: "罗素", dates: "1872–1970",
                line: "用逻辑分析澄清语言、数学与知识。",
                books: [
                    Book(id: "russell-denoting", title: "论指称", original: "On Denoting", year: "1905",
                         summary: "摹状词理论：看似指称对象的短语，其实是量化结构。",
                         parts: ["摹状词理论"], chapters: russellDenotingChapters),
                    Book(id: "russell-pm", title: "数学原理", original: "Principia Mathematica（与怀特海合著）", year: "1910–1913",
                         summary: "罗素悖论、类型论，以及把数学还原为逻辑的尝试。",
                         parts: ["悖论与类型", "逻辑主义"], chapters: russellPMChapters),
                    Book(id: "russell-problems", title: "哲学问题", original: "The Problems of Philosophy", year: "1912",
                         summary: "现象与实在、亲知与描述、归纳的根据。",
                         parts: ["现象与实在", "知识的种类", "归纳"], chapters: russellProblemsChapters),
                ]),
]

func findBook(_ id: String) -> Book? {
    (library.flatMap(\.books) + thinkerWorks.values.flatMap { $0 }).first { $0.id == id }
}

private var appVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
}

// MARK: - 首页：人物 → 书籍

struct HomeView: View {
    @State private var showSettings = false
    @AppStorage("homeStyle") private var style = "tree"
    private let styles: [(String, String, String)] = [
        ("tree", "世界树", "tree"), ("pyramid", "金字塔", "triangle"), ("table", "圆桌", "circle.circle"),
        ("heaven", "天堂", "sun.max"), ("temple", "罗马神殿", "building.columns"), ("list", "书目", "list.bullet"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop()
                Group {
                    switch style {
                    case "list": list
                    case "pyramid": PyramidView()
                    case "table": RoundTableView()
                    case "heaven": HeavenView()
                    case "temple": TempleView()
                    default: WorldTreeView()
                    }
                }
                .id(style)
                .transition(.opacity)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("首页", selection: Binding(get: { style }, set: { v in withAnimation(.smooth(duration: 0.4)) { style = v } })) {
                            ForEach(styles, id: \.0) { s in Label(s.1, systemImage: s.2).tag(s.0) }
                        }
                    } label: {
                        Label("首页样式", systemImage: styles.first { $0.0 == style }?.2 ?? "tree")
                    }
                    .accessibilityIdentifier("home.style")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("外观", systemImage: "paintpalette") { showSettings = true }
                }
            }
            .sheet(isPresented: $showSettings) { BackdropSettings() }
        }
    }

    private var list: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pure")
                            .font(.system(size: 44, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        Text("\(thinkers.count) 位哲学家 · \(thinkers.map { booksFor($0).count }.reduce(0, +)) 本书 · v\(appVersion)")
                            .font(.subheadline).foregroundStyle(Color.primary.opacity(0.6))
                            .padding(.bottom, 6)
                        NavigationLink {
                            HistoryTimelineView()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "timeline.selection")
                                    .font(.title3)
                                    .frame(width: 46, height: 46)
                                    .glassEffect(Glass.regular.tint(Moon.gold.opacity(0.2)), in: .circle)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("哲学时间轴").font(.body.weight(.semibold))
                                    Text("中国与西方 · \(thinkers.count) 位哲学家 · 从春秋与古希腊到 20 世纪")
                                        .font(.caption).foregroundStyle(Color.primary.opacity(0.6))
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Moon.dim)
                            }
                            .foregroundStyle(Color.primary)
                            .padding(16)
                            .contentShape(.rect(cornerRadius: 24))
                            .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 24))
                        }
                        .buttonStyle(.plain)
                        ForEach(Region.allCases, id: \.self) { region in
                            Text(region.title)
                                .font(.system(size: 30, weight: .semibold, design: .serif))
                                .foregroundStyle(Color.primary)
                                .padding(.top, 22)
                            ForEach(thinkers.filter { $0.region == region }.sorted { $0.born < $1.born }) { t in
                                ThinkerSection(thinker: t)
                            }
                        }
                    }
                    .padding(20)
                }
    }
}

private struct PhilosopherSection: View {
    let philosopher: Philosopher

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(philosopher.name)
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.primary)
                Text(philosopher.dates)
                    .font(.footnote.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.5))
            }
            .padding(.top, 14)
            Text(philosopher.line).font(.subheadline).foregroundStyle(Color.primary.opacity(0.7))
            GlassEffectContainer(spacing: 10) {
                VStack(spacing: 10) {
                    ForEach(philosopher.books) { b in
                        NavigationLink {
                            BookView(book: b)
                        } label: {
                            BookRow(book: b)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct BookRow: View {
    let book: Book
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "book.closed")
                .font(.title3)
                .foregroundStyle(Color.primary.opacity(0.9))
                .frame(width: 46, height: 46)
                .glassEffect(Glass.regular.tint(Color.primary.opacity(0.12)), in: .circle)
            VStack(alignment: .leading, spacing: 3) {
                Text("《\(book.title)》").font(.body.weight(.semibold)).foregroundStyle(Color.primary)
                HStack(spacing: 6) {
                    Text(book.chapters.isEmpty ? "\(book.year) · 全文" : "\(book.year) · \(book.chapters.count) 章").font(.caption).foregroundStyle(Color.primary.opacity(0.55))
                    if let a = authenticity?.books[book.id] { AuthBadge(score: a.total) }
                }
                Text(book.summary).font(.caption).foregroundStyle(Color.primary.opacity(0.7)).lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Moon.dim)
        }
        .padding(16)
        .contentShape(.rect(cornerRadius: 24))
        .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 24))
    }
}

// MARK: - 书：章节目录

struct BookView: View {
    let book: Book

    var body: some View {
        ZStack {
            Backdrop()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    Text("《\(book.title)》")
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.primary)
                    Text("\(book.original) · \(book.year)")
                        .font(.footnote).foregroundStyle(Color.primary.opacity(0.55))
                    Text(book.summary)
                        .font(.subheadline).foregroundStyle(Color.primary.opacity(0.8))
                        .padding(.bottom, 6)
                    if fullTexts[book.id] != nil {
                        NavigationLink {
                            BookReaderView(book: book)
                        } label: {
                            Label("阅读全文", systemImage: "text.book.closed")
                                .font(.callout.weight(.semibold))
                                .padding(.horizontal, 6).padding(.vertical, 4)
                        }
                        .buttonStyle(.glassProminent)
                    } else {
                        Text("该书在部分地区仍受版权保护，本应用只提供节选。")
                            .font(.caption).foregroundStyle(Color.primary.opacity(0.5))
                    }
                    if let doc = authenticity, let a = doc.books[book.id] {
                        AuthCard(score: a, rubric: doc.rubric).padding(.top, 8)
                    }
                    if let ed = bookEditions[book.id], !ed.isEmpty {
                        EditionsSection(editions: ed)
                    }
                    ForEach(book.parts, id: \.self) { part in
                        Text(part)
                            .font(.footnote.weight(.semibold)).foregroundStyle(Color.primary.opacity(0.6))
                            .padding(.top, 12)
                        GlassEffectContainer(spacing: 10) {
                            VStack(spacing: 10) {
                                ForEach(Array(book.chapters.enumerated()).filter { $0.element.part == part }, id: \.offset) { item in
                                    NavigationLink {
                                        ChapterView(book: book, index: item.offset)
                                    } label: {
                                        ChapterRow(number: item.offset + 1, chapter: item.element)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ChapterRow: View {
    let number: Int
    let chapter: Chapter
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(format: "%02d", number))
                .font(.system(.callout, design: .monospaced).weight(.semibold))
                .foregroundStyle(Color.primary.opacity(0.9))
                .frame(width: 40, height: 40)
                .glassEffect(Glass.regular.tint(Color.primary.opacity(0.12)), in: .circle)
            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title).font(.body.weight(.semibold)).foregroundStyle(Color.primary)
                Text(chapter.thesis).font(.caption).foregroundStyle(Color.primary.opacity(0.6)).lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Moon.dim)
        }
        .padding(16)
        .contentShape(.rect(cornerRadius: 22))
        .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 22))
    }
}

// MARK: - 章节页

struct ChapterView: View {
    let book: Book
    @State var index: Int
    @AppStorage("chapterMode") private var mode = 0   // 0 解读  1 原文
    @State private var clock = PlaybackClock()

    var body: some View {
        let c = book.chapters[index]
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("《\(book.title)》 · 第 \(index + 1) / \(book.chapters.count) 章 · \(c.part)")
                        .font(.caption).foregroundStyle(Moon.silver)
                    let topic = scholarTopics["\(book.id):\(index)"]
                    Picker("内容", selection: $mode) {
                        Text("解读").tag(0)
                        Text("原文").tag(1)
                        if topic != nil { Text("学者").tag(2) }
                    }
                    .pickerStyle(.segmented)
                    if mode == 2, let topic {
                        Text(c.title)
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        ScholarsView(topic: topic)
                            .id("scholars\(index)")
                    } else if mode == 1 {
                        Text(c.title)
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        PassagesView(items: passages["\(book.id):\(index)"] ?? workPassages["\(book.id):\(index)"] ?? [], book: book, key: "\(book.id):\(index)")
                    } else {
                    content(c)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("要点").font(.headline).foregroundStyle(Color.primary)
                        ForEach(c.points, id: \.self) { pt in
                            HStack(alignment: .top, spacing: 8) {
                                Circle().fill(Color.primary.opacity(0.8)).frame(width: 5, height: 5).padding(.top, 7)
                                Text(pt).font(.subheadline).foregroundStyle(Color.primary.opacity(0.85))
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: .rect(cornerRadius: 24))
                    }
                    GlassEffectContainer(spacing: 12) {
                        HStack {
                            Button { withAnimation(.spring(duration: 0.5)) { index -= 1 } } label: {
                                Label("上一章", systemImage: "chevron.left").padding(.vertical, 4)
                            }
                            .buttonStyle(.glass)
                            .disabled(index == 0)
                            Spacer()
                            Button { withAnimation(.spring(duration: 0.5)) { index += 1 } } label: {
                                Label("下一章", systemImage: "chevron.right").padding(.vertical, 4)
                            }
                            .buttonStyle(.glassProminent)
                            .disabled(index == book.chapters.count - 1)
                        }
                    }
                    .font(.callout.weight(.semibold))
                    .tint(Color.primary.opacity(0.25))
                }
                .padding(20)
                .id(index)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ c: Chapter) -> some View {
        switch c.body {
        case .canvas(let draw):
            if let live = liveFormulas["\(book.id):\(index)"] {
                TimelineView(.animation(minimumInterval: 0.05)) { tl in
                    Header(title: c.title, formula: live(clock.time(tl.date.timeIntervalSinceReferenceDate)), subtitle: c.thesis,
                           explainKey: c.formula)
                }
                // 放在 TimelineView 外面：不随每帧重建，展开状态才稳定
                FormulaExplainer(formula: c.formula)
            } else {
                Header(title: c.title, formula: c.formula, subtitle: c.thesis)
            }
            Stage(height: 380) {
                LiveCanvas(clock: clock, custom3D: threeDScenes["\(book.id):\(index)"].map { make in { make(clock) } }) { ctx, size, t in
                    draw(&ctx, size, t)
                }
            }
            .playbackControls(clock)
        case .interactive(let view):
            view
        }
    }
}


/// 某位哲学家名下的全部书：有章节动画的书 + 只有全文的著作
func booksFor(_ t: Thinker) -> [Book] {
    let deep = t.libraryId.flatMap { id in library.first { $0.id == id }?.books } ?? []
    return deep + (thinkerWorks[t.id] ?? [])
}

private struct ThinkerSection: View {
    let thinker: Thinker

    var body: some View {
        let books = booksFor(thinker)
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(thinker.name)
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.primary)
                Text("\(thinker.approx ? "约" : "")\(yearText(thinker.born))–\(yearText(thinker.died))")
                    .font(.footnote.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.5))
            }
            .padding(.top, 12)
            Text(thinker.thesis).font(.subheadline).foregroundStyle(Color.primary.opacity(0.7))
            if books.isEmpty {
                Text("暂缺可用的公有领域全文，章节动画将逐步加入。")
                    .font(.caption).foregroundStyle(Color.primary.opacity(0.45))
            } else {
                GlassEffectContainer(spacing: 10) {
                    VStack(spacing: 10) {
                        ForEach(books) { b in
                            NavigationLink {
                                BookView(book: b)
                            } label: {
                                BookRow(book: b)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}
