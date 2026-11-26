import SwiftUI

// MARK: - 评分详情（各个视图共用的弹出页）

struct FameSheet: View {
    let thinker: Thinker
    @Environment(\.dismiss) private var dismiss
    @State private var my: Double = 70
    @State private var rated = false
    @State private var stars: [String: Int] = [:]

    var body: some View {
        let blind = ScoreMode.blind
        let s = blind ? nil : fameOf(thinker)
        let tier = FameTier(fameTotal(thinker))
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 14) {
                        CartoonAvatar(thinker: thinker, size: 64)
                            .background(Circle().fill(tier.color.opacity(0.18)))
                            .overlay(Circle().strokeBorder(LinearGradient(colors: tier.sheen, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tier.name.map(String.init).joined(separator: " "))
                                .font(.system(size: 11, weight: .semibold, design: .serif)).tracking(4).foregroundStyle(tier.deep)
                            Text(fullName(thinker)).font(.system(size: tier == .pure ? 34 : 28, weight: .semibold, design: .serif))
                            Text("\(thinker.region.title) · \(thinker.approx ? "约" : "")\(yearText(thinker.born))–\(yearText(thinker.died))")
                                .font(.footnote).foregroundStyle(Color.primary.opacity(0.55))
                        }
                        Spacer()
                        if let s {
                            VStack(spacing: 4) {
                                FameRing(score: s.total, size: tier == .pure ? 70 : 60)
                                Text("第 \(s.rank) / \(thinkers.count)").font(.caption2.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.55))
                            }
                        } else if blind {
                            FameRing(score: rated ? Int(my) : 0, size: 60)
                        }
                    }
                    Text(thinker.thesis).font(.subheadline).foregroundStyle(Color.primary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                    if blind {
                        Text("未评分模式：官方分数、排名、等级与评分证据都已隐藏，请按你自己的判断打分。")
                            .font(.caption).foregroundStyle(Color.primary.opacity(0.6))
                            .padding(10).background(Color.primary.opacity(0.05), in: .rect(cornerRadius: 12))
                    }
                    myRating(blind)

                    if let s, let doc = fame {
                        // 五项得分
                        VStack(spacing: 9) {
                            ForEach(doc.rubric, id: \.key) { r in
                                let v = s.parts[r.key] ?? 0
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(r.name).font(.system(size: 13, weight: .semibold))
                                        // 标明哪一项是人工判定的，哪几项是数据算出来的
                                        Text(r.key == "hist" || r.key == "official" ? "人工判定" : "数据计算")
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundStyle(r.key == "hist" || r.key == "official" ? Color.orange : Color.secondary)
                                            .padding(.horizontal, 5).padding(.vertical, 1)
                                            .background(Capsule().strokeBorder(Color.primary.opacity(0.15)))
                                        Spacer()
                                        Text("\(v) / \(r.max)").font(.system(size: 12).monospacedDigit()).foregroundStyle(Color.primary.opacity(0.6))
                                    }
                                    GeometryReader { g in
                                        Capsule().fill(Color.primary.opacity(0.07))
                                            .overlay(alignment: .leading) {
                                                Capsule().fill(LinearGradient(colors: [tier.color, tier.deep], startPoint: .leading, endPoint: .trailing))
                                                    .frame(width: g.size.width * CGFloat(v) / CGFloat(max(1, r.max)))
                                            }
                                    }
                                    .frame(height: 5)
                                    Text(r.rule).font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
                                }
                            }
                        }
                        .padding(14)
                        .modifier(FameCardStyle(tier: tier, region: thinker.region, radius: 22))

                        evidence("历史推动", s.hist)
                        evidence("官方认可", s.off)
                        metrics(s.metrics)
                    } else {
                        Text("评分数据尚未生成").font(.footnote).foregroundStyle(Color.primary.opacity(0.5))
                    }

                    let books = booksFor(thinker)
                    if !books.isEmpty {
                        Text("著作").font(.headline)
                        ForEach(books) { b in
                            NavigationLink { BookView(book: b) } label: {
                                HStack {
                                    Image(systemName: "book.closed")
                                    Text("《\(b.title)》").font(.system(size: 15, weight: .semibold))
                                    Spacer()
                                    starRow(b.id)
                                    Image(systemName: "chevron.right").font(.caption2).foregroundStyle(Moon.dim)
                                }
                                .foregroundStyle(Color.primary)
                                .padding(12)
                                .background(Color.primary.opacity(0.05), in: .rect(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if !blind, let note = fame?.note {
                        Text(note).font(.caption2).foregroundStyle(Color.primary.opacity(0.4)).padding(.top, 6)
                    }
                }
                .padding(20)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭", systemImage: "xmark") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    /// 我的评分：人物 1–100 分（存在本机，不影响官方评分）
    private func myRating(_ blind: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("我的评分").font(.headline)
                if !blind { Text("只存在本机，不影响官方评分").font(.caption2).foregroundStyle(Color.primary.opacity(0.45)) }
                Spacer()
                Text(rated ? "\(Int(my))" : "未评").font(.system(size: 20, weight: .semibold, design: .serif).monospacedDigit())
                if rated {
                    Button("清除") { rated = false; UserRatings.setScore(thinker.id, nil) }.font(.caption)
                }
            }
            Slider(value: $my, in: 1...100, step: 1) { editing in
                if !editing { rated = true; UserRatings.setScore(thinker.id, Int(my)) }
            }
            .tint(FameTier(rated ? Int(my) : 0).deep)
            Text("作品可以在下方逐部打 1–5 星").font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
        }
        .padding(14)
        .background(Color.primary.opacity(0.04), in: .rect(cornerRadius: 18))
        .onAppear {
            if let v = UserRatings.score(thinker.id) { my = Double(v); rated = true }
            for b in booksFor(thinker) { stars[b.id] = UserRatings.stars(b.id) }
        }
    }

    /// 作品的 1–5 星
    private func starRow(_ id: String) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { k in
                Image(systemName: k <= (stars[id] ?? 0) ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(k <= (stars[id] ?? 0) ? pureGold : Color.primary.opacity(0.3))
                    .onTapGesture {
                        let v = (stars[id] ?? 0) == k ? 0 : k
                        stars[id] = v
                        UserRatings.setStars(id, v)
                    }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("我的星级")
        .accessibilityValue("\(stars[id] ?? 0) 星")
        .accessibilityAdjustableAction { dir in
            let v = max(0, min(5, (stars[id] ?? 0) + (dir == .increment ? 1 : -1)))
            stars[id] = v; UserRatings.setStars(id, v)
        }
    }

    @ViewBuilder
    private func evidence(_ title: String, _ items: [FameItem]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.headline)
                ForEach(items, id: \.self) { it in
                    Link(destination: URL(string: it.u) ?? URL(string: "https://wikipedia.org")!) {
                        HStack(alignment: .top, spacing: 8) {
                            if let p = it.p {
                                Text(p > 0 ? "+\(p)" : "\(p)")
                                    .font(.system(size: 11, weight: .bold).monospacedDigit())
                                    .foregroundStyle(p > 0 ? Color(red: 0.25, green: 0.6, blue: 0.45) : Color(red: 0.8, green: 0.4, blue: 0.3))
                                    .frame(width: 26, alignment: .leading)
                            } else {
                                Circle().fill(fameGold).frame(width: 5, height: 5).padding(.top, 6).padding(.horizontal, 4)
                            }
                            Text(it.t).font(.subheadline).foregroundStyle(Color.primary.opacity(0.85))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            Image(systemName: "arrow.up.right").font(.caption2).foregroundStyle(Moon.dim)
                        }
                    }
                }
            }
        }
    }

    private func metrics(_ m: FameMetrics) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("指标").font(.headline)
            if let v = m.sep { row("斯坦福哲学百科专条", "\(v) 词") }
            if let v = m.influenced { row("Wikidata 记载的影响关系", "\(v) 条") }
            if let v = m.len { row("维基百科条目篇幅（中英较长者）", "\(v / 1000) KB") }
            if let v = m.views { row("维基百科中英文近 12 个月浏览", v >= 10000 ? "\(v / 10000) 万次" : "\(v) 次") }
            if let v = m.langs { row("维基百科语种", "\(v) 种") }
        }
    }

    private func row(_ a: String, _ b: String) -> some View {
        HStack {
            Text(a).font(.footnote).foregroundStyle(Color.primary.opacity(0.65))
            Spacer()
            Text(b).font(.footnote.monospacedDigit().weight(.semibold))
        }
    }
}
