import SwiftUI
import UIKit
import Observation

// MARK: - 数据

struct FullText: Identifiable {
    let id: String
    let label: String     // 例如 “Deutsch” “English” “第一卷”
    var lang: String {
        if id.hasSuffix("-zh") { return "zh" }
        if id.hasSuffix("-en") { return "en" }
        if id.hasSuffix("-la") { return "la" }
        if id.hasSuffix("-fr") { return "fr" }
        if id.hasSuffix("-ar") { return "ar" }
        return "de"
    }
}

/// 每本书可读的全文（只收公有领域版本）
var fullTexts: [String: [FullText]] { coreFullTexts.merging(thinkerFullTexts) { a, _ in a } }

private let coreFullTexts: [String: [FullText]] = [
    "kant-cpr": [FullText(id: "kant-cpr-de", label: "Deutsch"), FullText(id: "kant-cpr-en", label: "English")],
    "hegel-phen": [FullText(id: "hegel-phen-de", label: "Deutsch")],
    "hegel-logic": [FullText(id: "hegel-logic-1-de", label: "第一卷"), FullText(id: "hegel-logic-2-de", label: "第二卷")],
]

/// 原文段落跳转到全文时，用哪个文本（默认该书第一个）
private let passageTextOverride: [String: String] = ["hegel-logic:3": "hegel-logic-2-de",
                                                      "zhuziyulei:1": "zhuziyulei-71-zh"]

func textId(forPassage key: String, book: String) -> String? {
    passageTextOverride[key] ?? fullTexts[book]?.first?.id
}

struct FullDoc: Codable {
    struct Section: Codable {
        let title: String
        let paragraphs: [String]
    }
    let id: String
    let title: String
    let lang: String
    let source: String
    let sections: [Section]
}

/// 下载与缓存
@Observable
final class TextStore {
    static let shared = TextStore()

    enum State {
        case missing, downloading, ready(FullDoc), failed(String)
    }
    private(set) var states: [String: State] = [:]

    private let dir: URL = {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("texts", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }()

    private func file(_ id: String) -> URL { dir.appendingPathComponent("\(id).json") }

    /// 离线版随 App 附带的全文
    static func bundled(_ folder: String, _ id: String) -> URL? {
        guard let base = Bundle.main.url(forResource: "Bundled", withExtension: nil) else { return nil }
        let u = base.appendingPathComponent(folder).appendingPathComponent("\(id).json")
        return FileManager.default.fileExists(atPath: u.path) ? u : nil
    }

    /// 读取已缓存的全文（在 .task 中调用，避免在绘制时修改状态）
    func loadCached(_ id: String) {
        if case .ready = states[id] { return }
        if case .downloading = states[id] { return }
        let src = FileManager.default.fileExists(atPath: file(id).path) ? file(id) : Self.bundled("texts", id)
        if let src, let data = try? Data(contentsOf: src), let doc = try? JSONDecoder().decode(FullDoc.self, from: data) {
            states[id] = .ready(doc)
        } else {
            states[id] = .missing
        }
    }

    func isDownloaded(_ id: String) -> Bool {
        FileManager.default.fileExists(atPath: file(id).path) || Self.bundled("texts", id) != nil
    }

    @MainActor
    func download(_ id: String) async {
        states[id] = .downloading
        let url = URL(string: "https://raw.githubusercontent.com/alicelikeeat/moon-myths/main/texts/\(id).json")!
        do {
            let (data, resp) = try await URLSession.shared.data(from: url)
            guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            let doc = try JSONDecoder().decode(FullDoc.self, from: data)
            try data.write(to: file(id), options: .atomic)
            states[id] = .ready(doc)
        } catch {
            states[id] = .failed("下载失败，请检查网络后重试。")
        }
    }

    func delete(_ id: String) {
        try? FileManager.default.removeItem(at: file(id))
        states[id] = .missing
    }
}

/// 书签与阅读位置（存在 UserDefaults）
enum ReaderPrefs {
    static func bookmarks(_ id: String) -> Set<Int> {
        Set((UserDefaults.standard.array(forKey: "bookmarks-\(id)") as? [Int]) ?? [])
    }
    static func setBookmarks(_ id: String, _ s: Set<Int>) {
        UserDefaults.standard.set(Array(s).sorted(), forKey: "bookmarks-\(id)")
    }
    static func lastPosition(_ id: String) -> Int? {
        UserDefaults.standard.object(forKey: "lastPos-\(id)") as? Int
    }
    static func setLastPosition(_ id: String, _ p: Int) {
        UserDefaults.standard.set(p, forKey: "lastPos-\(id)")
    }
}

private func normalize(_ s: String) -> String {
    s.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
}

/// 从原文节选生成用于在全文里定位的片段
func anchor(from original: String) -> String {
    var s = original.trimmingCharacters(in: .whitespaces)
    if s.hasPrefix("…") { s = String(s.dropFirst()).trimmingCharacters(in: .whitespaces) }
    if let r = s.range(of: "…") { s = String(s[..<r.lowerBound]) }
    if let r = s.range(of: "—") { s = String(s[..<r.lowerBound]) }
    s = s.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
    return String(normalize(s).prefix(40)).trimmingCharacters(in: .whitespaces)
}

// MARK: - 书的全文入口（多个版本时可切换）

struct BookReaderView: View {
    let book: Book
    var initialText: String? = nil
    var query: String? = nil
    @State private var volume: String = ""
    @AppStorage("readerLang") private var langRaw = PassageLang.original.rawValue

    var body: some View {
        let texts = fullTexts[book.id] ?? []
        let origLang = texts.first?.lang ?? "en"
        let originals = texts.filter { $0.lang == origLang }
        let lang = PassageLang(rawValue: langRaw) ?? .original
        ZStack {
            Backdrop()
            VStack(spacing: 0) {
                Picker("语言", selection: $langRaw) {
                    ForEach(PassageLang.allCases) { Text($0.title).tag($0.rawValue) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                if originals.count > 1 {
                    Picker("卷", selection: $volume) {
                        ForEach(originals) { Text($0.label).tag($0.id) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                if !volume.isEmpty {
                    let plan = readingPlan(lang: lang, origLang: origLang, texts: texts)
                    ReaderView(textId: plan.textId, query: plan.textId == volume ? query : nil,
                               targets: plan.targets, hideOriginal: plan.hideOriginal)
                        .id("\(plan.textId)|\(langRaw)")
                        .padding(.top, 8)
                }
            }
        }
        .navigationTitle("《\(book.title)》全文")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if volume.isEmpty {
                let start = initialText ?? texts.first?.id ?? ""
                volume = originals.contains { $0.id == start } ? start : (originals.first?.id ?? start)
                if initialText != nil, query != nil { langRaw = PassageLang.original.rawValue }
            }
        }
    }

    /// 选择要显示的文本与需要机器翻译的语言
    private func readingPlan(lang: PassageLang, origLang: String, texts: [FullText]) -> (textId: String, targets: [String], hideOriginal: Bool) {
        switch lang {
        case .original:
            return (volume, [], false)
        case .english:
            if origLang == "en" { return (volume, [], false) }
            if let en = texts.first(where: { $0.lang == "en" }) { return (en.id, [], false) }   // 优先用人工英译
            return (volume, ["en"], true)
        case .chinese:
            if origLang == "zh" { return (volume, [], false) }
            return (volume, ["zh"], true)
        case .all:
            return (volume, ["en", "zh"].filter { $0 != origLang }, false)
        }
    }
}

// MARK: - 阅读器

struct ReaderView: View {
    let textId: String
    var query: String? = nil
    var targets: [String] = []
    var hideOriginal = false
    private var store: TextStore { TextStore.shared }

    var body: some View {
        Group {
            switch store.states[textId] {
            case .none:
                ProgressView().frame(maxHeight: .infinity)
            case .some(let state):
                content(state)
            }
        }
        .task {
            store.loadCached(textId)
            if ProcessInfo.processInfo.arguments.contains("-autoDownload"), case .missing = store.states[textId] {
                await store.download(textId)
            }
        }
    }

    @ViewBuilder
    private func content(_ state: TextStore.State) -> some View {
        switch state {
        case .ready(let doc):
            ReaderContent(doc: doc, query: query, targets: targets, hideOriginal: hideOriginal)
        case .downloading:
            VStack(spacing: 14) {
                ProgressView()
                Text("正在下载全文……").font(.subheadline).foregroundStyle(Color.primary.opacity(0.7))
            }
            .padding(28)
            .glassEffect(.regular, in: .rect(cornerRadius: 24))
            .frame(maxHeight: .infinity)
        case .failed(let msg):
            downloadCard(message: msg)
        case .missing:
            downloadCard(message: "下载一次后可离线阅读。")
        }
    }

    private func downloadCard(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "text.book.closed").font(.system(size: 40)).foregroundStyle(Color.primary.opacity(0.8))
            Text(message).font(.subheadline).foregroundStyle(Color.primary.opacity(0.75)).multilineTextAlignment(.center)
            Button {
                Task { await TextStore.shared.download(textId) }
            } label: {
                Label("下载全文", systemImage: "arrow.down.circle").padding(.horizontal, 6).padding(.vertical, 4)
            }
            .buttonStyle(.glassProminent)
        }
        .padding(28)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .padding(24)
        .frame(maxHeight: .infinity)
    }
}

private struct Para: Identifiable {
    let id: Int
    let section: Int
    let text: String
}

private struct ReaderContent: View {
    let doc: FullDoc
    let query: String?
    let targets: [String]
    let hideOriginal: Bool

    @State private var zh = Translator(target: "zh")
    @State private var en = Translator(target: "en")
    private func translator(_ lang: String) -> Translator { lang == "zh" ? zh : en }

    @AppStorage("readerFont") private var fontSize = 18.0
    @State private var paras: [Para] = []
    @State private var sectionStart: [Int] = []
    @State private var bookmarks: Set<Int> = []
    @State private var highlight: Int?
    @State private var sheet: Sheet?
    @State private var pendingJump: Int?
    @State private var anims: [Int: AnimScene] = [:]
    @State private var animScores: [Int] = []
    @State private var basicAnims = false
    @State private var animStyle: String?
    @State private var playing: AnimPlay?

    struct AnimPlay: Identifiable { let scene: AnimScene; let text: String; var id: String { scene.anchor + "|" + text.prefix(40) } }

    enum Sheet: String, Identifiable { case toc, search, bookmarks; var id: String { rawValue } }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    Text(doc.title)
                        .font(.system(size: 26, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.primary)
                    Text(doc.source).font(.caption).foregroundStyle(Color.primary.opacity(0.5))
                    if !targets.isEmpty {
                        let broken = targets.map { translator($0) }.first { $0.failed != nil }
                        VStack(alignment: .leading, spacing: 10) {
                            Label(broken?.failed ?? "\(targets.map { $0 == "zh" ? "中文" : "English" }.joined(separator: "、")) 为 Apple 设备端机器翻译，读到哪里翻译到哪里，仅供参考。",
                                  systemImage: broken == nil ? "translate" : "exclamationmark.triangle")
                            if let t = broken, t.needsDownload {
                                Button {
                                    t.retry()
                                } label: {
                                    Label("下载语言包", systemImage: "arrow.down.circle").font(.callout.weight(.semibold))
                                }
                                .buttonStyle(.glassProminent)
                                Text("也可以在 设置 → App → 翻译 → 下载语言 中提前下载。")
                                    .font(.caption2)
                                    .foregroundStyle(Color.primary.opacity(0.5))
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(Color.primary.opacity(0.7))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassEffect(.regular, in: .rect(cornerRadius: 16))
                    }
                    ForEach(paras) { p in
                        if sectionStart.indices.contains(p.section), sectionStart[p.section] == p.id {
                            Text(doc.sections[p.section].title)
                                .font(.system(.title3, design: .serif).weight(.semibold))
                                .foregroundStyle(Moon.silver)
                                .padding(.top, 18)
                        }
                        paragraph(p)
                            .id(p.id)
                            .onAppear { ReaderPrefs.setLastPosition(doc.id, p.id) }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 40)
            }
            .onChange(of: pendingJump) { _, target in
                guard let target else { return }
                withAnimation(.easeInOut(duration: 0.35)) { proxy.scrollTo(target, anchor: .top) }
                highlight = target
                pendingJump = nil
                Task {
                    try? await Task.sleep(for: .seconds(2.5))
                    withAnimation { if highlight == target { highlight = nil } }
                }
            }
            .task {
                guard paras.isEmpty else { return }
                for lang in targets { translator(lang).setup(textId: doc.id, sourceLang: doc.lang) }
                build()
                bookmarks = ReaderPrefs.bookmarks(doc.id)
                try? await Task.sleep(for: .milliseconds(150))
                if let q = query, let hit = firstMatch(q) {
                    pendingJump = hit
                } else if let last = ReaderPrefs.lastPosition(doc.id), last > 0 {
                    proxy.scrollTo(last, anchor: .top)
                }
                if let ad = await AnimStore.shared.load(doc.id) {
                    var m: [Int: AnimScene] = [:]
                    for s in ad.scenes { if let i = firstMatch(s.anchor), m[i] == nil { m[i] = s } }
                    anims = m
                    animScores = ad.scores ?? []
                    basicAnims = ad.basic ?? false
                    animStyle = ad.style
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("目录", systemImage: "list.bullet") { sheet = .toc }
                Button("搜索", systemImage: "magnifyingglass") { sheet = .search }
                Button("书签", systemImage: "bookmark") { sheet = .bookmarks }
                Menu {
                    Button("放大字号", systemImage: "plus") { fontSize = min(28, fontSize + 1) }
                    Button("缩小字号", systemImage: "minus") { fontSize = max(13, fontSize - 1) }
                } label: {
                    Label("字号", systemImage: "textformat.size")
                }
            }
        }
        .translationTask(zh.config) { session in await zh.run(session) }
        .translationTask(en.config) { session in await en.run(session) }
        .sheet(item: $playing) { a in
            ParagraphAnimSheet(scene: a.scene, text: a.text)
        }
        .sheet(item: $sheet) { s in
            switch s {
            case .toc: TOCSheet(doc: doc, starts: sectionStart) { jump($0) }
            case .search: SearchSheet(paras: paras) { jump($0) }
            case .bookmarks: BookmarkSheet(paras: paras, marks: bookmarks) { jump($0) }
            }
        }
    }

    /// 普通动画按钮：点开时才生成
    private func basicButton(_ p: Para, score: Int?, make: @escaping () -> AnimScene?) -> some View {
        Button {
            if let s = make() { playing = AnimPlay(scene: s, text: p.text) }
        } label: {
            HStack(spacing: 6) {
                Label("动画", systemImage: "play.circle")
                if let sc = score { Text("\(sc)分").monospacedDigit() }
            }
            .font(.caption2)
            .foregroundStyle(Color.primary.opacity(0.6))
        }
        .buttonStyle(.glass)
    }

    private func paragraph(_ p: Para) -> some View {
        let marked = bookmarks.contains(p.id)
        return HStack(alignment: .top, spacing: 8) {
            if marked {
                Image(systemName: "bookmark.fill").font(.caption).foregroundStyle(Moon.gold).padding(.top, 4)
            }
            VStack(alignment: .leading, spacing: 8) {
                if !hideOriginal {
                    Text(p.text)
                        .font(.system(size: fontSize, design: .serif))
                        .foregroundStyle(Color.primary.opacity(0.9))
                        .lineSpacing(fontSize * 0.35)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                }
                ForEach(targets, id: \.self) { lang in
                    let t = translator(lang).text(for: p.id)
                    let off = translator(lang).failed != nil
                    if !(t == nil && off && !hideOriginal) {
                    Text(t ?? (hideOriginal ? p.text : "翻译中…"))
                        .font(.system(size: hideOriginal ? fontSize : fontSize - 2, design: lang == "zh" ? .default : .serif))
                        .foregroundStyle(Color.primary.opacity(t == nil ? 0.35 : (hideOriginal ? 0.9 : 0.65)))
                        .lineSpacing(fontSize * 0.3)
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                    }
                }
                if let s = anims[p.id] {
                    if s.isCore {
                        Button {
                            playing = AnimPlay(scene: s, text: p.text)
                        } label: {
                            Label("精讲 · \(s.title)", systemImage: "sparkles")
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Moon.gold.opacity(0.85))
                    } else if s.isPlus {
                        Button {
                            playing = AnimPlay(scene: s, text: p.text)
                        } label: {
                            HStack(spacing: 6) {
                                Label("进阶 · \(s.caption ?? "动画")", systemImage: "diamond.fill")
                                if let sc = s.score { Text("\(sc)分").monospacedDigit().opacity(0.6) }
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Moon.gold)
                        }
                        .buttonStyle(.glass)
                    } else {
                        basicButton(p, score: s.score) { s }
                    }
                } else if basicAnims, let style = animStyle {
                    Button {
                        if let s = scriptureScene(text: p.text, style: style, section: doc.sections[p.section].title) {
                            playing = AnimPlay(scene: s, text: p.text)
                        }
                    } label: {
                        Label("经文", systemImage: "sparkle")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Moon.gold.opacity(0.85))
                    }
                    .buttonStyle(.glass)
                } else if basicAnims {
                    basicButton(p, score: animScores.indices.contains(p.id) ? animScores[p.id] : nil) {
                        basicScene(text: p.text, lang: doc.lang, score: animScores.indices.contains(p.id) ? animScores[p.id] : nil)
                    }
                }
            }
            .onAppear { for lang in targets { translator(lang).request(p.id, p.text) } }
        }
        .padding(highlight == p.id ? 12 : 0)
        .background {
            if highlight == p.id {
                RoundedRectangle(cornerRadius: 16).fill(Color.clear)
                    .glassEffect(Glass.regular.tint(Moon.gold.opacity(0.25)), in: .rect(cornerRadius: 16))
            }
        }
        .contextMenu {
            Button(marked ? "移除书签" : "加入书签", systemImage: marked ? "bookmark.slash" : "bookmark") {
                if marked { bookmarks.remove(p.id) } else { bookmarks.insert(p.id) }
                ReaderPrefs.setBookmarks(doc.id, bookmarks)
            }
            Button("复制", systemImage: "doc.on.doc") { UIPasteboard.general.string = p.text }
        }
    }

    private func build() {
        var out: [Para] = []
        var starts: [Int] = []
        for (si, s) in doc.sections.enumerated() {
            starts.append(out.count)
            for t in s.paragraphs { out.append(Para(id: out.count, section: si, text: t)) }
        }
        paras = out
        sectionStart = starts
    }

    private func firstMatch(_ q: String) -> Int? {
        let needle = normalize(q)
        guard !needle.isEmpty else { return nil }
        if let hit = paras.first(where: { $0.text.contains(needle) }) { return hit.id }
        // 四库本等无标点文本：忽略标点再比较
        let bare = stripPunct(needle)
        guard bare.count >= 6 else { return nil }
        return paras.first { stripPunct($0.text).contains(bare) }?.id
    }

    private func stripPunct(_ s: String) -> String {
        String(String.UnicodeScalarView(s.unicodeScalars.filter {
            !CharacterSet.punctuationCharacters.contains($0) && !CharacterSet.symbols.contains($0)
                && !CharacterSet.whitespacesAndNewlines.contains($0)
        }))
    }

    private func jump(_ target: Int) {
        sheet = nil
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            pendingJump = target
        }
    }
}

// MARK: - 目录 / 搜索 / 书签

private struct TOCSheet: View {
    let doc: FullDoc
    let starts: [Int]
    let go: (Int) -> Void
    var body: some View {
        NavigationStack {
            List(Array(doc.sections.enumerated()), id: \.offset) { i, s in
                Button {
                    if starts.indices.contains(i) { go(starts[i]) }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.title).font(.body).foregroundStyle(Color.primary).lineLimit(2)
                        Text("\(s.paragraphs.count) 段").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("目录")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

private struct SearchSheet: View {
    let paras: [Para]
    let go: (Int) -> Void
    @State private var q = ""

    var body: some View {
        let needle = q.trimmingCharacters(in: .whitespaces)
        let hits = needle.count < 2 ? [] : Array(paras.filter { $0.text.localizedCaseInsensitiveContains(needle) }.prefix(200))
        NavigationStack {
            List {
                if needle.count >= 2 {
                    Section("\(hits.count >= 200 ? "200+" : "\(hits.count)") 处结果") {
                        ForEach(hits) { p in
                            Button { go(p.id) } label: {
                                Text(snippet(p.text, needle))
                                    .font(.callout).foregroundStyle(Color.primary).lineLimit(3)
                            }
                        }
                    }
                }
            }
            .searchable(text: $q, placement: .navigationBarDrawer(displayMode: .always), prompt: "搜索全文")
            .navigationTitle("搜索")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }

    private func snippet(_ text: String, _ needle: String) -> String {
        guard let r = text.range(of: needle, options: .caseInsensitive) else { return String(text.prefix(140)) }
        let start = text.index(r.lowerBound, offsetBy: -60, limitedBy: text.startIndex) ?? text.startIndex
        let end = text.index(r.upperBound, offsetBy: 80, limitedBy: text.endIndex) ?? text.endIndex
        let head = start == text.startIndex ? "" : "…"
        let tail = end == text.endIndex ? "" : "…"
        return head + String(text[start..<end]) + tail
    }
}

private struct BookmarkSheet: View {
    let paras: [Para]
    let marks: Set<Int>
    let go: (Int) -> Void
    var body: some View {
        NavigationStack {
            List {
                if marks.isEmpty {
                    Text("长按任意段落即可加入书签。").foregroundStyle(.secondary)
                }
                ForEach(marks.sorted(), id: \.self) { i in
                    if paras.indices.contains(i) {
                        Button { go(i) } label: {
                            Text(paras[i].text).font(.callout).foregroundStyle(Color.primary).lineLimit(3)
                        }
                    }
                }
            }
            .navigationTitle("书签")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}
