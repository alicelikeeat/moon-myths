import SwiftUI

/// 我的评分：所有人物按我打的分排列（已评在前、未评在后），作品星级一览；点人物打开评分页继续打分
struct MyRatingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("blindMode") private var blindMode = false
    @AppStorage("ratingsRev") private var ratingsRev = 0
    @State private var detail: Thinker?
    @State private var confirmClear = false

    var body: some View {
        let _ = ratingsRev
        let rated = thinkers.compactMap { t in UserRatings.score(t.id).map { (t, $0) } }.sorted { $0.1 > $1.1 }
        let unrated = thinkers.filter { UserRatings.score($0.id) == nil }.sorted { $0.born < $1.born }
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $blindMode) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("未评分模式").font(.body.weight(.semibold))
                            Text("隐藏官方分数、排名、等级与评分证据，只看我的评分").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityIdentifier("myratings.blind")
                    HStack {
                        Text("已评 \(rated.count) / \(thinkers.count) 位")
                        Spacer()
                        if !rated.isEmpty {
                            Text("平均 \(rated.map(\.1).reduce(0, +) / rated.count) 分").foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)
                }
                if !rated.isEmpty {
                    Section("我的排名") {
                        ForEach(Array(rated.enumerated()), id: \.element.0.id) { i, pair in
                            row(pair.0, rank: i + 1, score: pair.1)
                        }
                    }
                }
                Section("未评（\(unrated.count)）") {
                    ForEach(unrated) { t in row(t, rank: nil, score: nil) }
                }
                let starred = allBooks().filter { UserRatings.stars($0.0.id) > 0 }
                if !starred.isEmpty {
                    Section("我的作品星级") {
                        ForEach(starred, id: \.0.id) { b, t in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("《\(b.title)》").font(.subheadline.weight(.semibold))
                                    Text(fullName(t)).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(String(repeating: "★", count: UserRatings.stars(b.id))).foregroundStyle(pureGold)
                            }
                        }
                    }
                }
                Section {
                    Button("清除我的全部评分", role: .destructive) { confirmClear = true }
                }
            }
            .navigationTitle("我的评分")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } } }
            .sheet(item: $detail) { FameSheet(thinker: $0) }
            .confirmationDialog("清除本机保存的全部人物评分与作品星级？", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("清除", role: .destructive) { UserRatings.clearAll(); ratingsRev += 1 }
            }
        }
    }

    private func row(_ t: Thinker, rank: Int?, score: Int?) -> some View {
        Button { detail = t } label: {
            HStack(spacing: 10) {
                Text(rank.map { "\($0)" } ?? "—").font(.caption.monospacedDigit()).foregroundStyle(.secondary).frame(width: 24)
                CartoonAvatar(thinker: t, size: 30)
                Text(fullName(t)).foregroundStyle(Color.primary)
                Spacer()
                FameRing(score: score ?? 0, size: 32)
            }
        }
        .accessibilityLabel("\(fullName(t))，\(score.map { "我的评分 \($0)" } ?? "未评")")
    }

    private func allBooks() -> [(Book, Thinker)] {
        thinkers.flatMap { t in booksFor(t).map { ($0, t) } }
    }
}
