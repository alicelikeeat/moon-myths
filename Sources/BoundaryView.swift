import SwiftUI

struct Thought: Identifiable, Hashable {
    let name: String
    let knowable: Bool
    let note: String
    var id: String { name }
}

let thoughts: [Thought] = [
    Thought(name: "7 + 5 = 12", knowable: true, note: "在纯直观中构造，先天综合"),
    Thought(name: "凡事皆有因", knowable: true, note: "第二类比：对一切现象有效"),
    Thought(name: "物体是重的", knowable: true, note: "后天综合，经验可证"),
    Thought(name: "灵魂是实体", knowable: false, note: "谬误推理：中项歧义"),
    Thought(name: "世界有开端", knowable: false, note: "数学性二律背反"),
    Thought(name: "意志是自由的", knowable: false, note: "可思，实践上必需"),
    Thought(name: "上帝存在", knowable: false, note: "存在不是实在谓词"),
]

struct BoundaryView: View {
    @State private var picked: Thought = thoughts[0]

    var body: some View {
        Header(title: "现象与物自体",
               formula: "可知 = Im(κ∘σ)  ⊊  可思 = { x : x 不自相矛盾 }",
               subtitle: "形而上学的错误，就是把外环里的东西当作内圈里的东西。点下面的命题，看它落在哪里。")

        Stage(height: 340) {
            TimelineView(.animation) { tl in
                Canvas { ctx, size in
                    drawRings(&ctx, size, tl.date.timeIntervalSinceReferenceDate, picked)
                }
            }
        }

        FlowButtons(picked: $picked)

        HStack {
            Image(systemName: picked.knowable ? "checkmark.seal.fill" : "questionmark.circle.fill")
            Text(picked.knowable ? "可知" : "可思而不可知")
                .font(.headline)
            Spacer()
            Text(picked.note).font(.footnote).foregroundStyle(.white.opacity(0.75))
        }
        .padding(16)
        .foregroundStyle(.white)
        .glassEffect(Glass.regular.tint((picked.knowable ? Moon.gold : Moon.violet).opacity(0.2)),
                     in: .rect(cornerRadius: 22))
    }
}

private struct FlowButtons: View {
    @Binding var picked: Thought
    var body: some View {
        GlassEffectContainer(spacing: 8) {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], spacing: 8) {
            ForEach(thoughts) { th in
                Button {
                    withAnimation(.spring(duration: 0.4)) { picked = th }
                } label: {
                    Text(th.name)
                        .font(.footnote.weight(.semibold))
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white)
                        .glassEffect(picked == th
                                     ? Glass.regular.tint(.white.opacity(0.35)).interactive()
                                     : Glass.regular.interactive(),
                                     in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
        }
    }
}

private func drawRings(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double, _ picked: Thought) {
    let w = Double(size.width), h = Double(size.height)
    let cx = w / 2, cy = h / 2
    let outer = min(w, h) * 0.46, inner = outer * 0.52

    ctx.fill(Path(ellipseIn: CGRect(x: cx - outer, y: cy - outer, width: outer * 2, height: outer * 2)),
             with: .color(Moon.violet.opacity(0.10)))
    ctx.stroke(Path(ellipseIn: CGRect(x: cx - outer, y: cy - outer, width: outer * 2, height: outer * 2)),
               with: .color(Moon.violet.opacity(0.6)), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
    let breathe = inner + 2 * sin(t * 1.6)
    ctx.fill(Path(ellipseIn: CGRect(x: cx - breathe, y: cy - breathe, width: breathe * 2, height: breathe * 2)),
             with: .color(Moon.gold.opacity(0.14)))
    ctx.stroke(Path(ellipseIn: CGRect(x: cx - breathe, y: cy - breathe, width: breathe * 2, height: breathe * 2)),
               with: .color(Moon.gold.opacity(0.8)), lineWidth: 1.5)

    label(&ctx, "可知 E", cx, cy - inner + 18, Moon.gold)
    label(&ctx, "可思", cx, cy - outer + 16, Moon.violet)
    label(&ctx, "物自体：在可思之外不可再说", cx, h - 10)

    // 漂浮的命题粒子
    for (i, th) in thoughts.enumerated() {
        let s = Double(i)
        let angle = s * 0.9 + t * (th.knowable ? 0.25 : 0.12)
        let r = th.knowable ? inner * (0.25 + 0.4 * hash01(s)) : inner + (outer - inner) * (0.35 + 0.3 * hash01(s))
        let x = cx + cos(angle) * r, y = cy + sin(angle) * r
        let isPicked = th == picked
        let color = th.knowable ? Moon.gold : Moon.violet
        if isPicked { dot(&ctx, x, y, 16 + 3 * sin(t * 4), color.opacity(0.25)) }
        dot(&ctx, x, y, isPicked ? 7 : 4, isPicked ? .white : color)
        if isPicked { label(&ctx, th.name, x, y - 20, .white, size: 13) }
    }
}
