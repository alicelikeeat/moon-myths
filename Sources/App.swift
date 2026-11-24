import SwiftUI

@main
struct PureApp: App {
    var body: some Scene {
        WindowGroup {
            ChapterListView()
                .tint(Moon.gold)
                .preferredColorScheme(.dark)
        }
    }
}
