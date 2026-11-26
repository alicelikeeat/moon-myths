import SwiftUI

// MARK: - 首页：哲学世界树
//
// 根在下（最古老），冠在上（最近）：中国一枝向左、西方一枝向右、数学一根藤沿着树干向上。
// 每位思想家是一片原生 Liquid Glass 叶子；点叶子，叶子用原生玻璃形变展开成卡片，里面是他的书。

struct TreeNode: Identifiable {
    let thinker: Thinker
    let x: Double, y: Double, size: Double
    let order: Int
    var id: String { thinker.id }
}

struct TreeLayout {
    var nodes: [TreeNode] = []
    var height = 0.0
    var marks: [(String, Double)] = []          // 树干旁的年代刻度
    var trunkTop = 0.0, trunkBottom = 0.0
}

private let leafGap = 62.0
private let rootSpace = 190.0
private let crownSpace = 150.0

private func column(_ r: Region, _ W: Double, _ k: Int) -> Double {
    // 同一枝里前后相邻的叶子左右错开，像真正的枝叶
    let wob = (k % 2 == 0 ? -1.0 : 1.0)
    switch r {
    case .china: return W * 0.24 + wob * W * 0.085
    case .west: return W * 0.76 - wob * W * 0.085
    case .math: return W * 0.5 + wob * W * 0.06
    }
}

func treeLayout(width W: Double) -> TreeLayout {
    var L = TreeLayout()
    let all = thinkers.sorted { $0.born < $1.born }
    // 纵向位置：先按年代排名给出“时间高度”，再在每一枝里保证叶子间距
    var fromBottom: [String: Double] = [:]
    var lastInColumn: [Region: Double] = [:]
    var countInColumn: [Region: Int] = [:]
    var xs: [String: Double] = [:]
    for (i, t) in all.enumerated() {
        let timeH = Double(i) * 30
        let h = max(timeH, (lastInColumn[t.region] ?? -leafGap) + leafGap)
        lastInColumn[t.region] = h
        fromBottom[t.id] = h
        let k = countInColumn[t.region, default: 0]
        countInColumn[t.region] = k + 1
        xs[t.id] = column(t.region, W, k)
    }
    let top = (fromBottom.values.max() ?? 0)
    L.height = top + rootSpace + crownSpace
    func y(_ h: Double) -> Double { L.height - rootSpace - h }
    for (i, t) in all.enumerated() {
        let deep = t.libraryId != nil
        L.nodes.append(TreeNode(thinker: t, x: xs[t.id]!, y: y(fromBottom[t.id]!), size: deep ? 60 : 50, order: i))
    }
    L.trunkBottom = L.height - 70
    L.trunkTop = crownSpace * 0.45
    // 年代刻度：取每个时代第一位人物的高度
    let marks: [(String, Int)] = [("先秦 · 古希腊", -1100), ("秦汉 · 希腊化", -221), ("魏晋 · 罗马", 200), ("隋唐 · 中世纪", 581),
                                  ("宋明 · 经院", 960), ("近代", 1500), ("启蒙", 1680), ("19 世纪", 1800), ("20 世纪", 1880)]
    for (name, year) in marks {
        if let t = all.first(where: { $0.born >= year }), let h = fromBottom[t.id] {
            L.marks.append((name, y(h)))
        }
    }
    return L
}

private func regionColor(_ r: Region) -> Color {
    switch r {
    case .china: return Moon.violet
    case .west: return Moon.gold
    case .math: return Color(red: 0.35, green: 0.72, blue: 0.62)
    }
}

// MARK: - 枝干（Canvas，随时间“长”出来）

private struct TreeBranches: View {
    let L: TreeLayout
    let W: Double
    let filter: Region?
    let start: Date

    var body: some View {
        TimelineView(.animation) { tl in
            let now = tl.date.timeIntervalSince(start)
            let grow = min(1, now / 2.2)
            Canvas { ctx, size in
                let ease = 1 - pow(1 - grow, 3)
                let cx = W / 2
                // 根：从树干底部向下、向两侧散开
                for i in 0..<7 {
                    let a = (Double(i) - 3) / 3
                    var p = Path()
                    p.move(to: CGPoint(x: cx, y: L.trunkBottom - 20))
                    p.addCurve(to: CGPoint(x: cx + a * W * 0.42, y: L.height - 8 - abs(a) * 26),
                               control1: CGPoint(x: cx + a * 18, y: L.trunkBottom + 20),
                               control2: CGPoint(x: cx + a * W * 0.3, y: L.height - 30))
                    ctx.stroke(p.trimmedPath(from: 0, to: ease), with: .color(Color.primary.opacity(0.10)),
                               style: StrokeStyle(lineWidth: 5 - abs(a) * 3, lineCap: .round))
                }
                // 树干：自下而上逐渐变细，带一点弯
                let n = 40
                for i in 0..<n {
                    let u0 = Double(i) / Double(n), u1 = Double(i + 1) / Double(n)
                    guard u0 < ease else { break }
                    let y0 = L.trunkBottom + (L.trunkTop - L.trunkBottom) * u0
                    let y1 = L.trunkBottom + (L.trunkTop - L.trunkBottom) * min(u1, ease)
                    let x0 = cx + sin(u0 * 7) * 6, x1 = cx + sin(min(u1, ease) * 7) * 6
                    var p = Path(); p.move(to: CGPoint(x: x0, y: y0)); p.addLine(to: CGPoint(x: x1, y: y1))
                    ctx.stroke(p, with: .linearGradient(Gradient(colors: [Color.primary.opacity(0.22), Color.primary.opacity(0.12)]),
                                                        startPoint: CGPoint(x: x0 - 8, y: y0), endPoint: CGPoint(x: x0 + 8, y: y0)),
                               style: StrokeStyle(lineWidth: 18 - 13 * u0, lineCap: .round))
                }
                // 三根主枝：从树干出发，穿过每一片叶子
                for r in Region.allCases {
                    let leaves = L.nodes.filter { $0.thinker.region == r }.sorted { $0.y > $1.y }
                    guard let first = leaves.first else { continue }
                    var pts = [CGPoint(x: cx, y: min(L.trunkBottom - 30, first.y + 70))]
                    pts += leaves.map { CGPoint(x: $0.x, y: $0.y) }
                    let dim = filter != nil && filter != r
                    let col = regionColor(r).opacity(dim ? 0.08 : 0.38)
                    let total = Double(pts.count - 1)
                    for i in 0..<(pts.count - 1) {
                        let u = Double(i) / total
                        guard u < ease else { break }
                        let p0 = pts[max(0, i - 1)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[min(pts.count - 1, i + 2)]
                        let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
                        let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
                        var seg = Path(); seg.move(to: p1); seg.addCurve(to: p2, control1: c1, control2: c2)
                        let local = min(1, (ease - u) * total)
                        ctx.stroke(seg.trimmedPath(from: 0, to: local), with: .color(col),
                                   style: StrokeStyle(lineWidth: max(2, 9 - 7 * u), lineCap: .round))
                    }
                }
                // 萤火：沿树缓缓上升的光点
                for i in 0..<26 {
                    let q = Double(i)
                    let fx = fract(sin(q * 12.9898) * 43758.5453)
                    let speed = 14 + 10 * fract(q * 0.37)
                    let yy = L.height - fract(now * speed / L.height + fx) * L.height
                    let xx = W * (0.08 + 0.84 * fract(fx * 7.1)) + sin(now * 0.7 + q) * 10
                    let a = 0.25 + 0.25 * sin(now * 1.3 + q)
                    ctx.fill(Path(ellipseIn: CGRect(x: xx - 1.6, y: yy - 1.6, width: 3.2, height: 3.2)),
                             with: .color(Moon.gold.opacity(a * grow)))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 世界树

struct WorldTreeView: View {
    @Namespace private var glassNS
    @State private var selected: String?
    @State private var filter: Region?
    @State private var grown = false
    @State private var start = Date()
    @State private var width: Double = 390

    var body: some View {
        let L = treeLayout(width: width)
        ScrollView {
            ZStack(alignment: .topLeading) {
                TreeBranches(L: L, W: width, filter: filter, start: start)
                    .frame(width: width, height: L.height)
                // 年代刻度（树干左侧）
                ForEach(L.marks, id: \.0) { m in
                    Text(m.0)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.primary.opacity(0.4))
                        .fixedSize()
                        .rotationEffect(.degrees(-90))
                        .position(x: width / 2 - 22, y: m.1)
                        .opacity(grown ? 1 : 0)
                }
                // 根部与冠部的说明
                Text("根 · 最古老的思想")
                    .font(.system(size: 12, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.primary.opacity(0.45))
                    .position(x: width / 2, y: L.height - 28)
                GlassEffectContainer(spacing: 14) {
                    ZStack(alignment: .topLeading) {
                        ForEach(L.nodes) { node in
                            leaf(node, L)
                        }
                        if let id = selected, let node = L.nodes.first(where: { $0.id == id }) {
                            card(node, L)
                        }
                    }
                    .frame(width: width, height: L.height, alignment: .topLeading)
                }
            }
            .frame(width: width, height: L.height)
        }
        .defaultScrollAnchor(.bottom)
        .scrollIndicators(.hidden)
        .onGeometryChange(for: Double.self) { Double($0.size.width) } action: { width = $0 }
        .safeAreaInset(edge: .top, spacing: 0) { header }
        .onAppear {
            guard !grown else { return }
            start = Date()
            withAnimation(.spring(duration: 0.9, bounce: 0.3).delay(0.6)) { grown = true }
        }
    }

    // MARK: 顶部：标题与筛选

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Pure").font(.system(size: 34, weight: .semibold, design: .serif))
                Text("哲学之树").font(.system(size: 15, weight: .medium, design: .serif)).foregroundStyle(Color.primary.opacity(0.55))
                Spacer()
            }
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    chip(nil, "全部")
                    ForEach(Region.allCases, id: \.self) { r in chip(r, r.title) }
                    Spacer(minLength: 0)
                    NavigationLink { HistoryTimelineView() } label: {
                        Image(systemName: "timeline.selection").font(.system(size: 14, weight: .semibold)).frame(width: 34, height: 34)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: .circle)
                    .accessibilityLabel("哲学时间轴")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 10)
    }

    private func chip(_ r: Region?, _ title: String) -> some View {
        let on = filter == r
        return Button {
            withAnimation(.spring(duration: 0.45, bounce: 0.3)) { filter = r; selected = nil }
        } label: {
            Text(title)
                .font(.system(size: 13, weight: on ? .bold : .medium))
                .foregroundStyle(on ? Color.primary : Color.primary.opacity(0.65))
                .padding(.horizontal, 12).padding(.vertical, 7)
        }
        .buttonStyle(.plain)
        .glassEffect(on ? Glass.regular.tint((r.map(regionColor) ?? Color.primary).opacity(0.3)).interactive() : Glass.regular.interactive(),
                     in: .capsule)
        .glassEffectID("chip-\(title)", in: glassNS)
    }

    // MARK: 叶子与卡片

    @ViewBuilder
    private func leaf(_ node: TreeNode, _ L: TreeLayout) -> some View {
        let t = node.thinker
        let dim = filter != nil && filter != t.region
        if selected != t.id && grown {
            Button {
                withAnimation(.spring(duration: 0.5, bounce: 0.25)) { selected = t.id }
            } label: {
                Text(t.name)
                    .font(.system(size: t.name.count > 3 ? 11 : 13, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
                    .frame(width: node.size, height: node.size)
            }
            .buttonStyle(.plain)
            .glassEffect(Glass.regular.tint(regionColor(t.region).opacity(t.libraryId != nil ? 0.38 : 0.2)).interactive(), in: .circle)
            .glassEffectID(t.id, in: glassNS)
            .glassEffectTransition(.matchedGeometry)
            .opacity(dim ? 0.22 : 1)
            .position(x: node.x, y: node.y)
            .accessibilityLabel("\(t.name)，\(yearText(t.born)) 至 \(yearText(t.died))")
        }
    }

    private func card(_ node: TreeNode, _ L: TreeLayout) -> some View {
        let t = node.thinker
        let books = booksFor(t)
        let w = min(width - 32, 420)
        let below = node.y < L.height * 0.5
        let estH = 150.0 + Double(books.count) * 58
        let cy = below ? node.y - 30 + estH / 2 : node.y + 30 - estH / 2
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(t.name).font(.system(size: 24, weight: .semibold, design: .serif))
                Text("\(t.approx ? "约" : "")\(yearText(t.born))–\(yearText(t.died))")
                    .font(.footnote.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.55))
                Spacer()
                Button {
                    withAnimation(.spring(duration: 0.45, bounce: 0.2)) { selected = nil }
                } label: { Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).frame(width: 28, height: 28) }
                .buttonStyle(.glass).buttonBorderShape(.circle)
            }
            Text(t.thesis).font(.subheadline).foregroundStyle(Color.primary.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
            ForEach(books) { b in
                NavigationLink { BookView(book: b) } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "book.closed").font(.system(size: 14))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("《\(b.title)》").font(.system(size: 15, weight: .semibold))
                            Text(b.chapters.isEmpty ? "\(b.year) · 全文" : "\(b.year) · \(b.chapters.count) 章")
                                .font(.caption2).foregroundStyle(Color.primary.opacity(0.55))
                        }
                        Spacer(minLength: 0)
                        if let a = authenticity?.books[b.id] { AuthBadge(score: a.total) }
                        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(Moon.dim)
                    }
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 12).padding(.vertical, 9)
                    .contentShape(.rect(cornerRadius: 16))
                    .background(Color.primary.opacity(0.05), in: .rect(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(width: w)
        .glassEffect(Glass.regular.tint(regionColor(t.region).opacity(0.14)), in: .rect(cornerRadius: 28))
        .glassEffectID(t.id, in: glassNS)
        .glassEffectTransition(.matchedGeometry)
        .position(x: width / 2, y: min(max(cy, estH / 2 + 10), L.height - estH / 2 - 10))
        .zIndex(10)
    }
}
