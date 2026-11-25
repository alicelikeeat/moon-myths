import SwiftUI

// MARK: - 真实性评分：底本、原文、完整、实物、成书五项，满分 100
// 数据由 tools/authenticity/score.py 生成。

struct AuthRule: Codable { let name: String; let max: Int; let rule: String }
struct AuthScore: Codable { let total: Int; let parts: [String: Int]; let notes: [String: String] }
struct AuthDoc: Codable { let rubric: [AuthRule]; let books: [String: AuthScore] }

let authenticity: AuthDoc? = {
    guard let url = Bundle.main.url(forResource: "authenticity", withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return nil }
    return try? JSONDecoder().decode(AuthDoc.self, from: data)
}()

func authGrade(_ s: Int) -> (String, Color) {
    switch s {
    case 90...: return ("极可靠", Color(red: 0.25, green: 0.62, blue: 0.45))
    case 80..<90: return ("可靠", Color(red: 0.30, green: 0.52, blue: 0.75))
    case 70..<80: return ("较可靠", Color(red: 0.78, green: 0.60, blue: 0.25))
    default: return ("需留意", Color(red: 0.80, green: 0.42, blue: 0.32))
    }
}

/// 书目列表里的小徽章
struct AuthBadge: View {
    let score: Int
    var body: some View {
        let g = authGrade(score)
        HStack(spacing: 3) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 9))
            Text("\(score)").font(.caption2.weight(.semibold).monospacedDigit())
        }
        .foregroundStyle(g.1)
        .padding(.horizontal, 6).padding(.vertical, 2)
        .glassEffect(.regular, in: .capsule)
        .accessibilityLabel("真实性 \(score) 分，\(g.0)")
    }
}

/// 书籍页里的评分卡片，点开看明细
struct AuthCard: View {
    let score: AuthScore
    let rubric: [AuthRule]
    @State private var open = false
    @State private var shown = false

    var body: some View {
        let g = authGrade(score.total)
        Button { open = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().stroke(Color.primary.opacity(0.1), lineWidth: 5)
                    Circle().trim(from: 0, to: shown ? CGFloat(score.total) / 100 : 0)
                        .stroke(g.1, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(score.total)").font(.system(size: 17, weight: .semibold, design: .rounded).monospacedDigit())
                }
                .frame(width: 50, height: 50)
                VStack(alignment: .leading, spacing: 4) {
                    Text("真实性 · \(g.0)").font(.subheadline.weight(.semibold))
                    HStack(spacing: 4) {
                        ForEach(rubric, id: \.name) { r in
                            let v = score.parts[r.name] ?? 0
                            Capsule().fill(g.1.opacity(0.25 + 0.75 * Double(v) / Double(r.max)))
                                .frame(width: 26, height: 5)
                        }
                    }
                    Text(rubric.map(\.name).joined(separator: " · ")).font(.caption2).foregroundStyle(Color.primary.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Color.primary.opacity(0.35))
            }
            .padding(12)
            .glassEffect(.regular, in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .onAppear { withAnimation(.easeOut(duration: 0.9).delay(0.2)) { shown = true } }
        .sheet(isPresented: $open) { AuthDetail(score: score, rubric: rubric) }
    }
}

private struct AuthDetail: View {
    let score: AuthScore
    let rubric: [AuthRule]
    @Environment(\.dismiss) private var dismiss
    @State private var shown = false

    var body: some View {
        let g = authGrade(score.total)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(score.total)").font(.system(size: 52, weight: .semibold, design: .rounded))
                        Text("/ 100 · \(g.0)").font(.headline).foregroundStyle(g.1)
                    }
                    ForEach(rubric, id: \.name) { r in
                        let v = score.parts[r.name] ?? 0
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(r.name).font(.subheadline.weight(.semibold))
                                Spacer()
                                Text("\(v) / \(r.max)").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.primary.opacity(0.08))
                                    Capsule().fill(g.1).frame(width: shown ? geo.size.width * CGFloat(v) / CGFloat(r.max) : 0)
                                }
                            }
                            .frame(height: 6)
                            if let n = score.notes[r.name] {
                                Text(n).font(.footnote).foregroundStyle(Color.primary.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Text(r.rule).font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .glassEffect(.regular, in: .rect(cornerRadius: 14))
                    }
                    Text("评分只衡量本应用所收文本的来源是否可查、可核对，不评价书的思想价值。“成书”一项依据学界通行看法，有争议的地方如实标出。")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .navigationTitle("真实性评分").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成", systemImage: "checkmark") { dismiss() } } }
            .onAppear { withAnimation(.easeOut(duration: 0.8).delay(0.15)) { shown = true } }
        }
        .presentationDetents([.large])
    }
}
