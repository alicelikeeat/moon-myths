import SwiftUI

@main
struct MoonMythsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            Page { PipelineView() }
                .tabItem { Label("认识", systemImage: "sparkles") }
            Page { CategoriesView() }
                .tabItem { Label("范畴", systemImage: "square.grid.3x3") }
            Page { AntinomyView() }
                .tabItem { Label("背反", systemImage: "infinity") }
            Page { RegulativeView() }
                .tabItem { Label("理念", systemImage: "chart.line.uptrend.xyaxis") }
            Page { BoundaryView() }
                .tabItem { Label("边界", systemImage: "circle.circle") }
        }
        .tint(Moon.gold)
    }
}
