import SwiftUI

// MARK: - 公式动画：逐个符号登场，讲读法、讲含义，最后整式点亮

/// 把公式切成“记号”：多字符符号（argmax、Im(、dQ/dt、⟹̸、{ x |…）整体保留，空格分隔其余部分
func formulaTokens(_ f: String) -> [String] {
    let multi = symbolGlossary.map(\.0).filter { $0.count > 1 }.sorted { $0.count > $1.count }
    var out: [String] = []
    var buf = ""
    var i = f.startIndex
    func flush() { if !buf.isEmpty { out.append(buf); buf = "" } }
    while i < f.endIndex {
        if let m = multi.first(where: { f[i...].hasPrefix($0) }) {
            flush(); out.append(m); i = f.index(i, offsetBy: m.count); continue
        }
        let c = f[i]
        if c == " " || c == "　" { flush() }
        else if symbolGlossary.contains(where: { $0.0 == String(c) }) || "=()[]{},;:，；：".contains(c) {
            flush(); out.append(String(c))
        } else { buf.append(c) }
        i = f.index(after: i)
    }
    flush()
    return out
}

private func glossaryEntry(_ token: String) -> (String, String, String)? {
    symbolGlossary.first { $0.0 == token } ?? symbolGlossary.first { $0.0.count > 1 && token.hasPrefix($0.0) }
}

/// 简单的流式排版：放不下就换行，每行居中
struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal.width ?? 320, subviews)
        let h = rows.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(0, rows.count - 1))
        return CGSize(width: proposal.width ?? rows.map(\.width).max() ?? 0, height: h)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(bounds.width, subviews) {
            var x = bounds.minX + (bounds.width - row.width) / 2
            for idx in row.items {
                let s = subviews[idx].sizeThatFits(.unspecified)
                subviews[idx].place(at: CGPoint(x: x, y: y + (row.height - s.height) / 2), proposal: .unspecified)
                x += s.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct Row { var items: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(_ maxW: CGFloat, _ subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for (i, v) in subviews.enumerated() {
            let s = v.sizeThatFits(.unspecified)
            let add = rows[rows.count - 1].items.isEmpty ? s.width : s.width + spacing
            if rows[rows.count - 1].width + add > maxW && !rows[rows.count - 1].items.isEmpty {
                rows.append(Row())
            }
            let r = rows.count - 1
            rows[r].width += rows[r].items.isEmpty ? s.width : s.width + spacing
            rows[r].height = max(rows[r].height, s.height)
            rows[r].items.append(i)
        }
        return rows
    }
}

struct FormulaAnimationView: View {
    let formula: String
    let note: String?

    @State private var shown = 0            // 已登场的记号数
    @State private var focus: Int?          // 正在讲解的记号
    @State private var finished = false
    @State private var step: Int?           // 分步讲解进行到第几段
    @State private var playing = true
    @State private var run = 0              // 重播计数（重启任务）
    @Namespace private var ns

    private var tokens: [String] { formulaTokens(formula) }
    private var steps: [(String, String)] { formulaSteps[formula] ?? [] }
    private var stepIndices: [[Int]] { steps.map { stepTokenRanges(tokens, $0.0) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 1. 公式本身
            FlowLayout(spacing: 2, lineSpacing: 10) {
                ForEach(Array(tokens.enumerated()), id: \.offset) { i, tok in
                    tokenView(i, tok)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 10)
            .background {
                // 整式完成时的光
                RoundedRectangle(cornerRadius: 22)
                    .fill(RadialGradient(colors: [Moon.gold.opacity(finished ? 0.22 : 0), .clear],
                                         center: .center, startRadius: 0, endRadius: 220))
                    .animation(.easeInOut(duration: 1.2), value: finished)
            }
            .glassEffect(.regular, in: .rect(cornerRadius: 22))

            // 2. 当前符号的读法
            ZStack {
                if let f = focus, tokens.indices.contains(f), let g = glossaryEntry(tokens[f]) {
                    HStack(alignment: .center, spacing: 14) {
                        Text(g.0)
                            .font(.system(size: 34, weight: .regular, design: .serif))
                            .foregroundStyle(Moon.gold)
                            .frame(minWidth: 54)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("读作：\(g.1)").font(.subheadline.weight(.semibold))
                            Text(g.2).font(.callout).foregroundStyle(Color.primary.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .glassEffect(.regular.tint(Moon.gold.opacity(0.12)), in: .rect(cornerRadius: 18))
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity.animation(.easeOut(duration: 0.12))))
                    .id(f)
                } else if let k = step, steps.indices.contains(k) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            ForEach(steps.indices, id: \.self) { j in
                                Capsule().fill(j == k ? Moon.gold : Color.primary.opacity(0.18))
                                    .frame(width: j == k ? 18 : 6, height: 6)
                            }
                            Spacer()
                            Text("第 \(k + 1) / \(steps.count) 步").font(.caption2.monospacedDigit())
                                .foregroundStyle(Color.primary.opacity(0.5))
                        }
                        Text(steps[k].0)
                            .font(.system(size: 20, design: .serif))
                            .foregroundStyle(Moon.gold)
                        Text(steps[k].1)
                            .font(.callout)
                            .foregroundStyle(Color.primary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular.tint(Moon.gold.opacity(0.10)), in: .rect(cornerRadius: 18))
                    .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity.animation(.easeOut(duration: 0.12))))
                    .id("step\(k)")
                } else if finished, let note {
                    Text(note)
                        .font(.callout)
                        .foregroundStyle(Color.primary.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassEffect(.regular, in: .rect(cornerRadius: 18))
                        .transition(.opacity.combined(with: .scale(scale: 0.97)))
                }
            }
            .frame(minHeight: 70, alignment: .top)

            // 3. 控制
            HStack(spacing: 10) {
                Button {
                    withAnimation(.snappy) { playing.toggle() }
                } label: { Image(systemName: playing ? "pause.fill" : "play.fill").frame(width: 22, height: 22) }
                .buttonStyle(.glass).buttonBorderShape(.circle)
                Button {
                    restart()
                } label: { Label("重播", systemImage: "arrow.counterclockwise").font(.caption.weight(.semibold)) }
                .buttonStyle(.glass)
                Spacer()
                Text("点任意符号可单独查看").font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
            }
        }
        .task(id: run) { await play() }
    }

    @ViewBuilder
    private func tokenView(_ i: Int, _ tok: String) -> some View {
        let isSym = glossaryEntry(tok) != nil
        let visible = i < shown
        let inStep = step.map { stepIndices.indices.contains($0) && stepIndices[$0].contains(i) } ?? false
        let dimmed = step != nil && !inStep
        let focused = focus == i || inStep
        Text(tok)
            .font(.system(size: tok == "∘" ? 30 : (isSym ? 24 : 19), weight: isSym ? .regular : .medium, design: .serif))
            .foregroundStyle(focused ? Moon.gold : (finished ? Color.primary : Color.primary.opacity(isSym ? 0.95 : 0.75)))
            .padding(.horizontal, isSym ? 6 : ("()[]{},;:".contains(tok) ? 0 : 3))
            .padding(.vertical, 3)
            .background {
                if focus == i {
                    Capsule().fill(Moon.gold.opacity(0.14))
                        .matchedGeometryEffect(id: "hl", in: ns)
                }
            }
            .overlay(alignment: .bottom) {
                if inStep {
                    Capsule().fill(Moon.gold.opacity(0.8)).frame(height: 2).padding(.horizontal, -2).offset(y: 4)
                        .transition(.scale(scale: 0.2, anchor: .leading).combined(with: .opacity))
                }
            }
            .scaleEffect(visible ? (focus == i ? 1.18 : (inStep ? 1.06 : 1)) : 0.4)
            .opacity(visible ? (dimmed ? 0.28 : 1) : 0)
            .blur(radius: visible ? 0 : 6)
            .offset(y: visible ? 0 : 10)
            .onTapGesture {
                guard isSym else { return }
                playing = false
                withAnimation(.spring(duration: 0.45, bounce: 0.25)) {
                    step = nil
                    shown = max(shown, i + 1)
                    focus = focus == i ? nil : i
                }
            }
    }

    private func restart() {
        withAnimation(.easeOut(duration: 0.3)) { shown = 0; focus = nil; finished = false; step = nil }
        playing = true
        run += 1
    }

    private func wait(_ s: Double) async -> Bool {
        var left = s
        while left > 0 {
            if Task.isCancelled { return false }
            try? await Task.sleep(for: .milliseconds(100))
            if playing { left -= 0.1 }
        }
        return !Task.isCancelled
    }

    /// 节奏：普通记号依次浮现（0.35 秒一个）；遇到符号停下讲解（2.6 秒）；最后整式点亮并给出通俗解释
    private func play() async {
        guard await wait(0.4) else { return }
        for i in tokens.indices {
            let isSym = glossaryEntry(tokens[i]) != nil
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                shown = i + 1
                if isSym { focus = i }
            }
            guard await wait(isSym ? 2.2 : 0.3) else { return }
            if isSym { withAnimation(.easeInOut(duration: 0.35)) { focus = nil } }
        }
        // 分步讲解：一段一段点亮
        for k in steps.indices where !stepIndices[k].isEmpty {
            guard await wait(0.4) else { return }
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) { step = k }
            guard await wait(3.4) else { return }
        }
        withAnimation(.easeInOut(duration: 0.6)) { step = nil }
        withAnimation(.easeInOut(duration: 0.9)) { finished = true }
    }
}

// MARK: - 截图用：`-formulaDemo`

struct FormulaDemoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                FormulaAnimationView(formula: "∃x( Kx ∧ ∀y(Ky → y = x) ∧ Bx )", note: formulaNotes["∃x( Kx ∧ ∀y(Ky → y = x) ∧ Bx )"])
                FormulaAnimationView(formula: "K = κ ∘ σ", note: formulaNotes["K = κ ∘ σ"])
            }
            .padding(20)
            .padding(.top, 50)
        }
        .background(Backdrop())
    }
}
