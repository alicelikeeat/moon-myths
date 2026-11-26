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
    // 三枝之间留足间距：相邻两列叶子中心至少相隔一片叶子的直径，不会互相压住
    case .china: return W * 0.20 + wob * W * 0.07
    case .west: return W * 0.80 - wob * W * 0.07
    case .math: return W * 0.5 + wob * W * 0.05
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
        // 有评分时叶子大小随分数：46（低分）到 64（高分）
        let sc = fameOf(t).map { 46 + min(18, max(0, Double($0.total - 45) / 50 * 18)) }
        L.nodes.append(TreeNode(thinker: t, x: xs[t.id]!, y: y(fromBottom[t.id]!), size: sc ?? (deep ? 60 : 50), order: i))
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
                // 树干：一整块自下而上逐渐变细的形状（不用分段描边，避免接缝处出现一颗颗的珠子）
                let n = 48
                let topU = ease
                var left: [CGPoint] = [], right: [CGPoint] = []
                for i in 0...n {
                    let u = Double(i) / Double(n) * topU
                    let y = L.trunkBottom + (L.trunkTop - L.trunkBottom) * u
                    let x = cx + sin(u * 7) * 6
                    let half = (18 - 13 * u) / 2
                    left.append(CGPoint(x: x - half, y: y)); right.append(CGPoint(x: x + half, y: y))
                }
                var trunk = Path()
                trunk.move(to: left[0])
                for q in left.dropFirst() { trunk.addLine(to: q) }
                for q in right.reversed() { trunk.addLine(to: q) }
                trunk.closeSubpath()
                ctx.fill(trunk, with: .linearGradient(Gradient(colors: [Color.primary.opacity(0.10), Color.primary.opacity(0.24), Color.primary.opacity(0.10)]),
                                                      startPoint: CGPoint(x: cx - 10, y: 0), endPoint: CGPoint(x: cx + 10, y: 0)))
                // 三根主枝：从树干出发，穿过每一片叶子
                for r in Region.allCases {
                    let leaves = L.nodes.filter { $0.thinker.region == r }.sorted { $0.y > $1.y }
                    guard let first = leaves.first else { continue }
                    var pts = [CGPoint(x: cx, y: min(L.trunkBottom - 30, first.y + 70))]
                    pts += leaves.map { CGPoint(x: $0.x, y: $0.y) }
                    let dim = filter != nil && filter != r
                    let col = regionColor(r).opacity(dim ? 0.08 : 0.38)
                    let total = Double(pts.count - 1)
                    var path = Path()
                    path.move(to: pts[0])
                    for i in 0..<(pts.count - 1) {
                        let p0 = pts[max(0, i - 1)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[min(pts.count - 1, i + 2)]
                        let c1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
                        let c2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
                        path.addCurve(to: p2, control1: c1, control2: c2)
                    }
                    _ = total
                    // 一整条路径描边：粗的底层只画到靠近树干的一段，细的上层画全长，看起来由粗到细
                    let grown = path.trimmedPath(from: 0, to: ease)
                    ctx.stroke(grown, with: .color(col), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    ctx.stroke(path.trimmedPath(from: 0, to: min(ease, 0.45)), with: .color(col.opacity(0.7)),
                               style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round))
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
    /// 卡片底衬的不透明度（可在卡片里调节）：越高越不透出后面的叶子
    @AppStorage("treeCardOpacity") private var cardOpacity = 0.75
    @State private var detail: Thinker?

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
        .sheet(item: $detail) { FameSheet(thinker: $0) }
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
        .padding(.bottom, 14)
        .background {
            // 顶部一层渐隐的磨砂，树枝滚到标题下面时不会和文字搅在一起
            Rectangle().fill(.ultraThinMaterial)
                .mask(LinearGradient(stops: [.init(color: .black, location: 0), .init(color: .black, location: 0.7), .init(color: .clear, location: 1)],
                                     startPoint: .top, endPoint: .bottom))
                .ignoresSafeArea(edges: .top)
        }
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
        let covered = selected.flatMap { id in L.nodes.first { $0.id == id } }
            .map { cardFrame($0, L).insetBy(dx: -node.size / 2 - 6, dy: -node.size / 2 - 6).contains(CGPoint(x: node.x, y: node.y)) } ?? false
        if selected != t.id && grown {
            Button {
                withAnimation(.spring(duration: 0.5, bounce: 0.25)) { selected = t.id }
            } label: {
                let short = shortName(t)
                // 叶子里：卡通头像 + 名字
                VStack(spacing: 0) {
                    CartoonAvatar(thinker: t, size: node.size * 0.52)
                    Text(short)
                        .font(.system(size: short.count > 4 ? 8.5 : 10, weight: .semibold, design: .serif))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.horizontal, 3)
                }
                .frame(width: node.size, height: node.size)
            }
            .buttonStyle(.plain)
            .glassEffect(Glass.regular.tint(regionColor(t.region).opacity(t.libraryId != nil ? 0.38 : 0.2)).interactive(), in: .circle)
            .glassEffectID(t.id, in: glassNS)
            .glassEffectTransition(.matchedGeometry)
            .opacity(covered ? 0 : (dim ? 0.22 : 1))
            .allowsHitTesting(!covered)
            .position(x: node.x, y: node.y)
            .accessibilityLabel("\(fullName(t))，\(yearText(t.born)) 至 \(yearText(t.died))")
        }
    }

    /// 卡片大致占据的区域：被它盖住的叶子会暂时隐去，文字不再互相叠压
    private func cardFrame(_ node: TreeNode, _ L: TreeLayout) -> CGRect {
        let w = min(width - 32, 420)
        let below = node.y < L.height * 0.5
        let estH = 190.0 + Double(booksFor(node.thinker).count) * 58
        let cy0 = below ? node.y - 30 + estH / 2 : node.y + 30 - estH / 2
        let cy = min(max(cy0, estH / 2 + 10), L.height - estH / 2 - 10)
        return CGRect(x: width / 2 - w / 2, y: cy - estH / 2, width: w, height: estH)
    }

    private func card(_ node: TreeNode, _ L: TreeLayout) -> some View {
        let t = node.thinker
        let books = booksFor(t)
        let f = cardFrame(node, L)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                CartoonAvatar(thinker: t, size: 36)
                Text(fullName(t)).font(.system(size: 24, weight: .semibold, design: .serif)).lineLimit(1).minimumScaleFactor(0.7)
                Text("\(t.approx ? "约" : "")\(yearText(t.born))–\(yearText(t.died))")
                    .font(.footnote.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.55))
                Spacer()
                if let s = fameOf(t) {
                    Button { detail = t } label: { FameRing(score: s.total, size: 34) }
                        .buttonStyle(.plain)
                        .accessibilityLabel("评分 \(s.total)，查看证据")
                }
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
            // 透明度：拖动调节卡片底衬，从通透的玻璃到几乎不透明
            HStack(spacing: 8) {
                Image(systemName: "circle.dotted").font(.system(size: 12)).foregroundStyle(Color.primary.opacity(0.5))
                Slider(value: $cardOpacity, in: 0...1)
                    .tint(regionColor(t.region))
                    .accessibilityLabel("卡片不透明度")
                Image(systemName: "circle.fill").font(.system(size: 12)).foregroundStyle(Color.primary.opacity(0.5))
            }
            .padding(.top, 2)
        }
        .padding(16)
        .frame(width: f.width)
        .background(Color(uiColor: .systemBackground).opacity(cardOpacity * 0.92), in: .rect(cornerRadius: 28))
        .glassEffect(Glass.regular.tint(regionColor(t.region).opacity(FameTier(fameTotal(t)) == .pure ? 0.04 : 0.14)), in: .rect(cornerRadius: 28))
        .glassEffectID(t.id, in: glassNS)
        .glassEffectTransition(.matchedGeometry)
        .overlay {
            // 分级边框：至纯香槟金双线、精致纯金、专业钻石
            let tier = FameTier(fameTotal(t))
            RoundedRectangle(cornerRadius: 28).strokeBorder(LinearGradient(colors: tier.sheen, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.9)
            if tier == .pure {
                RoundedRectangle(cornerRadius: 23).strokeBorder(champagne.opacity(0.4), lineWidth: 0.5).padding(5)
            }
        }
        .position(x: f.midX, y: f.midY)
        .zIndex(10)
    }
}
