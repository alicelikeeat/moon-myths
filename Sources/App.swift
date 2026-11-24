import SwiftUI

@main
struct PureApp: App {
    /// 调试用：启动参数 `-startChapter N` 直接打开第 N 章（从 0 开始），用于自动截图
    private let startChapter: Int? = UserDefaults.standard.object(forKey: "startChapter") as? Int

    var body: some Scene {
        WindowGroup {
            Group {
                if let start = startChapter, chapters.indices.contains(start) {
                    NavigationStack { ChapterView(index: start) }
                } else {
                    ChapterListView()
                }
            }
            .tint(.white)
            .preferredColorScheme(.dark)
        }
    }
}
