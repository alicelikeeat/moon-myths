import SwiftUI

/// 设置：评分模式、人名语言、3D、外观集中在一处（原来散在左上角菜单里）
struct AppSettings: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("blindMode") private var blindMode = false
    @AppStorage("nameLang") private var nameLang = "zh"
    @AppStorage("home3D") private var home3D = false
    @State private var showBackdrop = false
    @State private var confirmClear = false
    @State private var showMine = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $blindMode) { Label("未评分模式", systemImage: "eye.slash") }
                        .accessibilityIdentifier("settings.blind")
                } header: { Text("评分") } footer: {
                    Text("开启后隐藏官方分数、排名、等级配色与评分证据，所有人显示为“未评”。你可以在人物评分页按自己的判断打 1–100 分、给作品打 1–5 星；按分数排位的视图会改用你的分数。评分只存在本机。")
                }
                Section {
                    Button { showMine = true } label: { Label("我的评分", systemImage: "star.leadinghalf.filled") }
                    Button("清除我的全部评分", role: .destructive) { confirmClear = true }
                }
                Section {
                    Picker("人名语言", selection: $nameLang) {
                        ForEach(NameLang.allCases) { l in Text(l.title).tag(l.rawValue) }
                    }
                    .accessibilityIdentifier("settings.lang")
                } header: { Text("人名") } footer: {
                    Text("只切换人物名字的语言（如 Konfuzius、Lao-tseu、Thomas d'Aquin）；界面文字仍为中文。")
                }
                Section("首页") {
                    Toggle(isOn: $home3D) { Label("使用 3D 视图", systemImage: "cube") }
                }
                Section("外观") {
                    Button { showBackdrop = true } label: { Label("深浅色与背景…", systemImage: "paintpalette") }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } } }
            .sheet(isPresented: $showBackdrop) { BackdropSettings() }
            .sheet(isPresented: $showMine) { MyRatingsView() }
            .confirmationDialog("清除本机保存的全部人物评分与作品星级？", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("清除", role: .destructive) { UserRatings.clearAll() }
            }
        }
    }
}
