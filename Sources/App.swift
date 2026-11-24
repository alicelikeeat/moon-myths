import SwiftUI

@main
struct PureApp: App {
    var body: some Scene {
        WindowGroup {
            ChapterListView()
                .tint(.white)
                .preferredColorScheme(.dark)
        }
    }
}
