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

    var body: some Scene {
        WindowGroup {
            Group {
                if let l = launch {
                    NavigationStack { ChapterView(book: l.book, index: l.index) }
                } else {
                    HomeView()
                }
            }
            .tint(Color(red: 0.56, green: 0.64, blue: 0.80))
            .preferredColorScheme(.dark)
        }
    }
}
