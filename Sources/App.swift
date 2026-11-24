import SwiftUI

@main
struct PureApp: App {
    /// 调试用启动参数：`-book <id>` 选书（默认康德），`-startChapter N` 直接打开第 N 章（从 0 开始）
    private let launch: (book: Book, index: Int)? = {
        let args = ProcessInfo.processInfo.arguments
        func value(_ key: String) -> String? {
            guard let i = args.firstIndex(of: key), i + 1 < args.count else { return nil }
            return args[i + 1]
        }
        guard let n = value("-startChapter").flatMap({ Int($0) }),
              let book = findBook(value("-book") ?? "kant-cpr"),
              book.chapters.indices.contains(n) else { return nil }
        return (book, n)
    }()

    @AppStorage("appearance") private var appearance = "dark"

    /// 截图用：`-openBook <bookId>` 直接打开书籍页
    private let bookLaunch: Book? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-openBook"), i + 1 < args.count else { return nil }
        return findBook(args[i + 1])
    }()

    /// 截图用：`-openReader <bookId>`（可加 `-readerQuery <文本>`）直接打开全文
    private let readerLaunch: (book: Book, query: String?)? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-openReader"), i + 1 < args.count, let b = findBook(args[i + 1]) else { return nil }
        var q: String? = nil
        if let j = args.firstIndex(of: "-readerQuery"), j + 1 < args.count { q = args[j + 1] }
        return (b, q)
    }()

    init() {
        // 截图用：`-openPassages` 直接显示原文页
        if ProcessInfo.processInfo.arguments.contains("-openPassages") {
            UserDefaults.standard.set(1, forKey: "chapterMode")
        } else if ProcessInfo.processInfo.arguments.contains("-startChapter") {
            UserDefaults.standard.set(0, forKey: "chapterMode")
        }
    }

    private var scheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "system": return nil
        default: return .dark
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let b = bookLaunch {
                    NavigationStack { BookView(book: b) }
                } else if let r = readerLaunch {
                    NavigationStack { BookReaderView(book: r.book, query: r.query) }
                } else if let l = launch {
                    NavigationStack { ChapterView(book: l.book, index: l.index) }
                } else {
                    HomeView()
                }
            }
            .tint(Color(red: 0.56, green: 0.64, blue: 0.80))
            .preferredColorScheme(scheme)
        }
    }
}
