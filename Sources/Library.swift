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
    library.flatMap(\.books).first { $0.id == id }
}

private var appVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
}

// MARK: - 首页：人物 → 书籍

struct HomeView: View {
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pure")
                            .font(.system(size: 44, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        Text("\(library.count) 位哲学家 · \(library.flatMap(\.books).count) 本书 · v\(appVersion)")
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
                        ForEach(library) { p in
                            PhilosopherSection(philosopher: p)
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("外观", systemImage: "paintpalette") { showSettings = true }
                }
            }
            .sheet(isPresented: $showSettings) { BackdropSettings() }
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
                Text("\(book.year) · \(book.chapters.count) 章").font(.caption).foregroundStyle(Color.primary.opacity(0.55))
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
    @State private var show3D = ProcessInfo.processInfo.arguments.contains("-show3D")

    var body: some View {
        let c = book.chapters[index]
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("《\(book.title)》 · 第 \(index + 1) / \(book.chapters.count) 章 · \(c.part)")
                        .font(.caption).foregroundStyle(Moon.silver)
                    Picker("内容", selection: $mode) {
                        Text("解读").tag(0)
                        Text("原文").tag(1)
                    }
                    .pickerStyle(.segmented)
                    if mode == 1 {
                        Text(c.title)
                            .font(.system(size: 30, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        PassagesView(items: passages["\(book.id):\(index)"] ?? [], book: book, key: "\(book.id):\(index)")
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
                    Header(title: c.title, formula: live(clock.time(tl.date.timeIntervalSinceReferenceDate)), subtitle: c.thesis)
                }
            } else {
                Header(title: c.title, formula: c.formula, subtitle: c.thesis)
            }
            if let scene = threeDScenes["\(book.id):\(index)"] {
                Picker("视图", selection: $show3D) {
                    Text("2D").tag(false)
                    Text("3D").tag(true)
                }
                .pickerStyle(.segmented)
                if show3D {
                    Stage(height: 420) { scene(clock) }
                        .playbackControls(clock)
                }
            }
            if !show3D || threeDScenes["\(book.id):\(index)"] == nil {
                Stage(height: 380) {
                    LiveCanvas(clock: clock) { ctx, size, t in
                        draw(&ctx, size, t)
                    }
                }
                .playbackControls(clock)
            }
        case .interactive(let view):
            view
        }
    }
}
