import SwiftUI

@main
struct MoonMythsApp: App {
    var body: some Scene {
        WindowGroup {
            ChapterListView()
                .tint(Moon.gold)
                .preferredColorScheme(.dark)
        }
    }
}
