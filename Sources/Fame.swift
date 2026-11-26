import SwiftUI

// MARK: - 人物评分：历史推动、学者评价、民间热度、官方认可、历时检验五项，满分 100
// 数据由 tools/fame/score.py 生成：客观指标联网抓取，历史事件与官方行为逐条附出处。

struct FameRule: Codable { let key: String; let name: String; let max: Int; let rule: String }
struct FameItem: Codable, Hashable { let t: String; let u: String; var p: Int? = nil }
struct FameMetrics: Codable {
    var langs: Int? = nil
    var views: Int? = nil
    var influenced: Int? = nil
    var len: Int? = nil
    var sep: Int? = nil
}
struct FameScore: Codable {
    let total: Int
    let rank: Int
    let parts: [String: Int]
    let hist: [FameItem]
    let off: [FameItem]
    let metrics: FameMetrics
}
struct FameDoc: Codable { let rubric: [FameRule]; let scores: [String: FameScore]; let note: String }

let fame: FameDoc? = {
    guard let url = Bundle.main.url(forResource: "fame", withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return nil }
    return try? JSONDecoder().decode(FameDoc.self, from: data)
}()

func fameOf(_ t: Thinker) -> FameScore? { fame?.scores[t.id] }
func fameTotal(_ t: Thinker) -> Int { fameOf(t)?.total ?? 0 }

/// 按总分从高到低
let rankedThinkers: [Thinker] = thinkers.sorted { (fameTotal($0), -$0.born) > (fameTotal($1), -$1.born) }

let fameGold = Color(red: 0.80, green: 0.63, blue: 0.30)

enum FameTier {
    case pure, fine, plain
    init(_ s: Int) { self = s >= 85 ? .pure : (s >= 75 ? .fine : .plain) }
    var name: String { switch self { case .pure: "至纯"; case .fine: "精致"; case .plain: "常规" } }
}

func fameRegionTint(_ r: Region) -> Color {
    switch r {
    case .china: return Moon.violet
    case .west: return Moon.gold
    case .math: return Color(red: 0.35, green: 0.72, blue: 0.62)
    }
}

/// 名字去掉括号注释
func shortName(_ t: Thinker) -> String { String(t.name.split(separator: "（").first ?? Substring(t.name)) }

// MARK: - 分数圈

struct FameRing: View {
    let score: Int
    var size: CGFloat = 54
    var body: some View {
        let tier = FameTier(score)
        ZStack {
            Circle().stroke(Color.primary.opacity(0.08), lineWidth: size * 0.08)
            Circle().trim(from: 0, to: CGFloat(score) / 100)
                .stroke(tier == .pure ? AnyShapeStyle(AngularGradient(colors: [fameGold, Color(red: 1, green: 0.9, blue: 0.65), fameGold], center: .center))
                                      : AnyShapeStyle(Color.primary.opacity(tier == .fine ? 0.7 : 0.45)),
                        style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(score)").font(.system(size: size * 0.36, weight: .semibold, design: .serif)).monospacedDigit()
        }
        .frame(width: size, height: size)
    }
}

/// 卡片的分级外观：至纯 = 素白（夜间素黑）+ 金色细线；精致 = 染色玻璃 + 细白线；常规 = 普通玻璃
struct FameCardStyle: ViewModifier {
    let tier: FameTier
    let region: Region
    var radius: CGFloat = 28
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        switch tier {
        case .pure:
            content
                .background((scheme == .dark ? Color.black : Color.white).opacity(0.86), in: .rect(cornerRadius: radius))
                .glassEffect(.regular, in: .rect(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(
                    LinearGradient(colors: [fameGold, fameGold.opacity(0.25), fameGold], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.8))
                .overlay(RoundedRectangle(cornerRadius: radius - 5).strokeBorder(fameGold.opacity(0.25), lineWidth: 0.5).padding(5))
        case .fine:
            content
                .glassEffect(Glass.regular.tint(fameRegionTint(region).opacity(0.16)), in: .rect(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(Color.white.opacity(0.45), lineWidth: 0.6))
        case .plain:
            content.glassEffect(.regular, in: .rect(cornerRadius: radius))
        }
    }
}

// MARK: - 评分详情（各个视图共用的弹出页）

struct FameSheet: View {
    let thinker: Thinker
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let s = fameOf(thinker)
        let tier = FameTier(s?.total ?? 0)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            if tier == .pure {
                                Text("至 纯").font(.system(size: 11, weight: .semibold, design: .serif)).tracking(4).foregroundStyle(fameGold)
                            }
                            Text(thinker.name).font(.system(size: tier == .pure ? 34 : 28, weight: .semibold, design: .serif))
                            Text("\(thinker.region.title) · \(thinker.approx ? "约" : "")\(yearText(thinker.born))–\(yearText(thinker.died))")
                                .font(.footnote).foregroundStyle(Color.primary.opacity(0.55))
                        }
                        Spacer()
                        if let s {
                            VStack(spacing: 4) {
                                FameRing(score: s.total, size: tier == .pure ? 70 : 60)
                                Text("第 \(s.rank) / \(thinkers.count)").font(.caption2.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.55))
                            }
                        }
                    }
                    Text(thinker.thesis).font(.subheadline).foregroundStyle(Color.primary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)

                    if let s, let doc = fame {
                        // 五项得分
                        VStack(spacing: 9) {
                            ForEach(doc.rubric, id: \.key) { r in
                                let v = s.parts[r.key] ?? 0
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(r.name).font(.system(size: 13, weight: .semibold))
                                        Spacer()
                                        Text("\(v) / \(r.max)").font(.system(size: 12).monospacedDigit()).foregroundStyle(Color.primary.opacity(0.6))
                                    }
                                    GeometryReader { g in
                                        Capsule().fill(Color.primary.opacity(0.07))
                                            .overlay(alignment: .leading) {
                                                Capsule().fill(tier == .pure ? fameGold : fameRegionTint(thinker.region).opacity(0.8))
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
                                    Image(systemName: "chevron.right").font(.caption2).foregroundStyle(Moon.dim)
                                }
                                .foregroundStyle(Color.primary)
                                .padding(12)
                                .background(Color.primary.opacity(0.05), in: .rect(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if let note = fame?.note {
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

// MARK: - 首页视图的标题

struct HomeTitle: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("Pure").font(.system(size: 34, weight: .semibold, design: .serif))
                Text(title).font(.system(size: 15, weight: .medium, design: .serif)).foregroundStyle(Color.primary.opacity(0.55))
                Spacer()
            }
            Text(subtitle).font(.caption).foregroundStyle(Color.primary.opacity(0.5))
        }
        .padding(.horizontal, 20)
    }
}

/// 一块“名牌”：所有视图共用，按分级换外观
struct FamePlate: View {
    let thinker: Thinker
    var compact = false
    var body: some View {
        let s = fameTotal(thinker)
        let tier = FameTier(s)
        VStack(spacing: 1) {
            Text(shortName(thinker))
                .font(.system(size: compact ? 11 : (tier == .pure ? 15 : 13), weight: .semibold, design: .serif))
                .lineLimit(2).minimumScaleFactor(0.7).multilineTextAlignment(.center)
            Text("\(s)").font(.system(size: compact ? 9 : 10, weight: .medium).monospacedDigit())
                .foregroundStyle(tier == .pure ? fameGold : Color.primary.opacity(0.55))
        }
        .foregroundStyle(Color.primary)
        .padding(.horizontal, 4)
    }
}

// MARK: - 金字塔

struct PyramidView: View {
    @State private var detail: Thinker?
    @State private var shown = false
    private let rowSizes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 7]

    var body: some View {
        let rows = makeRows()
        ScrollView {
            VStack(spacing: 0) {
                HomeTitle(title: "金字塔", subtitle: "按总分分层：塔尖是得分最高者，越往下越宽").padding(.bottom, 18)
                GeometryReader { g in
                    let W = g.size.width
                    ZStack(alignment: .top) {
                        PyramidBackdrop().frame(width: W, height: pyramidHeight(rows))
                        VStack(spacing: 6) {
                            ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                                let rowW = min(W - 16, 80 + Double(i) * (W - 96) / Double(rowSizes.count - 1))
                                HStack(spacing: 4) {
                                    ForEach(row) { t in stone(t, width: (rowW - Double(row.count - 1) * 4) / Double(row.count), level: i) }
                                }
                                .frame(width: rowW)
                                .opacity(shown ? 1 : 0)
                                .offset(y: shown ? 0 : 30)
                                .animation(.spring(duration: 0.6, bounce: 0.25).delay(Double(rows.count - i) * 0.06), value: shown)
                            }
                        }
                        .padding(.top, 34)
                    }
                    .frame(width: W)
                }
                .frame(height: pyramidHeight(rows))
                legend.padding(.top, 14).padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
        .onAppear { shown = true }
        .sheet(item: $detail) { FameSheet(thinker: $0) }
    }

    private func pyramidHeight(_ rows: [[Thinker]]) -> Double { 34 + Double(rows.count) * 58 + 70 }

    private func makeRows() -> [[Thinker]] {
        var out: [[Thinker]] = []
        var i = 0
        for n in rowSizes where i < rankedThinkers.count {
            out.append(Array(rankedThinkers[i..<min(rankedThinkers.count, i + n)]))
            i += n
        }
        if i < rankedThinkers.count { out.append(Array(rankedThinkers[i...])) }
        return out
    }

    private func stone(_ t: Thinker, width: Double, level: Int) -> some View {
        let tier = FameTier(fameTotal(t))
        return Button { detail = t } label: {
            FamePlate(thinker: t, compact: width < 46)
                .frame(width: width, height: 52)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .modifier(FameCardStyle(tier: tier, region: t.region, radius: level == 0 ? 14 : 8))
    }

    private var legend: some View {
        HStack(spacing: 14) {
            ForEach([("至纯", "≥ 85"), ("精致", "75–84"), ("常规", "< 75")], id: \.0) { a, b in
                HStack(spacing: 4) {
                    Text(a).font(.caption.weight(.semibold))
                    Text(b).font(.caption2.monospacedDigit()).foregroundStyle(Color.primary.opacity(0.5))
                }
            }
        }
    }
}

/// 金字塔背后的沙漠：太阳、塔身、沙丘
private struct PyramidBackdrop: View {
    var body: some View {
        Canvas { ctx, size in
            let W = size.width, H = size.height
            let sun = CGPoint(x: W * 0.82, y: 60)
            ctx.fill(Path(ellipseIn: CGRect(x: sun.x - 90, y: sun.y - 90, width: 180, height: 180)),
                     with: .radialGradient(Gradient(colors: [fameGold.opacity(0.35), fameGold.opacity(0.08), .clear]), center: sun, startRadius: 0, endRadius: 90))
            ctx.fill(Path(ellipseIn: CGRect(x: sun.x - 22, y: sun.y - 22, width: 44, height: 44)), with: .color(fameGold.opacity(0.35)))
            var body = Path()
            body.move(to: CGPoint(x: W / 2, y: 4))
            body.addLine(to: CGPoint(x: W + 10, y: H - 50))
            body.addLine(to: CGPoint(x: -10, y: H - 50))
            body.closeSubpath()
            ctx.fill(body, with: .linearGradient(Gradient(colors: [fameGold.opacity(0.22), fameGold.opacity(0.08)]),
                                                 startPoint: CGPoint(x: W / 2, y: 0), endPoint: CGPoint(x: W / 2, y: H)))
            // 受光面与背光面
            var shade = Path()
            shade.move(to: CGPoint(x: W / 2, y: 4))
            shade.addLine(to: CGPoint(x: W + 10, y: H - 50))
            shade.addLine(to: CGPoint(x: W * 0.62, y: H - 50))
            shade.closeSubpath()
            ctx.fill(shade, with: .color(Color.black.opacity(0.05)))
            var dune = Path()
            dune.move(to: CGPoint(x: 0, y: H - 40))
            dune.addCurve(to: CGPoint(x: W, y: H - 46), control1: CGPoint(x: W * 0.3, y: H - 70), control2: CGPoint(x: W * 0.7, y: H - 20))
            dune.addLine(to: CGPoint(x: W, y: H)); dune.addLine(to: CGPoint(x: 0, y: H)); dune.closeSubpath()
            ctx.fill(dune, with: .color(fameGold.opacity(0.12)))
        }
    }
}

// MARK: - 圆桌

struct RoundTableView: View {
    @State private var focus: String?
    @State private var detail: Thinker?
    private let S = 900.0
    private var R: Double { S / 2 - 50 }

    var body: some View {
        let order = thinkers.sorted { $0.born < $1.born }
        ScrollView([.horizontal, .vertical]) {
            ZStack {
                // 桌面：一整块大玻璃圆盘
                Circle().fill(.clear)
                    .frame(width: R * 2 - 70, height: R * 2 - 70)
                    .glassEffect(Glass.regular.tint(fameGold.opacity(0.08)), in: .circle)
                Circle().strokeBorder(fameGold.opacity(0.3), lineWidth: 0.8).frame(width: R * 2 - 90, height: R * 2 - 90)
                Canvas { ctx, size in drawArcs(&ctx, order) }
                    .frame(width: S, height: S)
                    .allowsHitTesting(false)
                center
                ForEach(Array(order.enumerated()), id: \.element.id) { i, t in seat(t, i, order.count) }
            }
            .frame(width: S, height: S)
        }
        .defaultScrollAnchor(.top)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTitle(title: "圆桌", subtitle: "按年代围坐一圈，人人平等；光晕表示分数，点人物看影响关系")
                .padding(.bottom, 10)
                .background(.ultraThinMaterial.opacity(0.9))
        }
        .sheet(item: $detail) { FameSheet(thinker: $0) }
    }

    private func pos(_ i: Int, _ n: Int) -> CGPoint {
        let a = Double(i) / Double(n) * 2 * .pi - .pi / 2
        return CGPoint(x: S / 2 + cos(a) * R, y: S / 2 + sin(a) * R)
    }

    private func drawArcs(_ ctx: inout GraphicsContext, _ order: [Thinker]) {
        let idx = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1.id, $0) })
        for inf in influences {
            guard let a = idx[inf.from], let b = idx[inf.to] else { continue }
            let on = focus == nil || focus == inf.from || focus == inf.to
            let p = pos(a, order.count), q = pos(b, order.count)
            var path = Path()
            path.move(to: p)
            // 弧线弯向圆心：越远的两人，弧线越深入桌心
            path.addQuadCurve(to: q, control: CGPoint(x: S / 2 + (p.x + q.x - S) * 0.15, y: S / 2 + (p.y + q.y - S) * 0.15))
            let col = inf.critical ? Color(red: 0.8, green: 0.4, blue: 0.3) : fameGold
            ctx.stroke(path, with: .color(col.opacity(focus == nil ? 0.12 : (on ? 0.75 : 0.03))),
                       style: StrokeStyle(lineWidth: on && focus != nil ? 1.6 : 0.8, dash: inf.critical ? [4, 3] : []))
        }
    }

    private var center: some View {
        VStack(spacing: 10) {
            if let id = focus, let t = thinkers.first(where: { $0.id == id }) {
                Text(t.name).font(.system(size: 30, weight: .semibold, design: .serif))
                if let s = fameOf(t) { FameRing(score: s.total, size: 64) }
                Text(t.thesis).font(.footnote).foregroundStyle(Color.primary.opacity(0.7))
                    .multilineTextAlignment(.center).frame(width: 300)
                Button("评分与证据") { detail = t }.buttonStyle(.glassProminent)
            } else {
                Text("圆 桌").font(.system(size: 40, weight: .semibold, design: .serif)).tracking(8)
                Text("\(thinkers.count) 位思想家 · \(influences.count) 条影响关系").font(.footnote).foregroundStyle(Color.primary.opacity(0.55))
                Text("金线为继承，红色虚线为批判").font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
            }
        }
        .animation(.smooth, value: focus)
    }

    private func seat(_ t: Thinker, _ i: Int, _ n: Int) -> some View {
        let p = pos(i, n)
        let s = fameTotal(t)
        let tier = FameTier(s)
        let on = focus == t.id
        let glow = 0.15 + Double(max(0, s - 40)) / 60 * 0.6
        return Button {
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) { focus = on ? nil : t.id }
        } label: {
            Text(shortName(t))
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .lineLimit(2).minimumScaleFactor(0.7).multilineTextAlignment(.center)
                .foregroundStyle(Color.primary)
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .glassEffect(tier == .pure ? Glass.regular.tint(fameGold.opacity(0.35)).interactive()
                                   : Glass.regular.tint(fameRegionTint(t.region).opacity(0.25)).interactive(), in: .circle)
        .background(Circle().fill(RadialGradient(colors: [fameGold.opacity(glow), .clear], center: .center, startRadius: 10, endRadius: 34)).frame(width: 68, height: 68))
        .scaleEffect(on ? 1.25 : 1)
        .position(p)
    }
}

// MARK: - 天堂（但丁《天堂篇》的九重天）

struct HeavenView: View {
    @State private var detail: Thinker?
    private let S = 920.0
    private let ringSizes = [2, 3, 4, 5, 6, 8, 9, 11, 13]
    private let ringNames = ["原动天", "恒星天", "土星天", "木星天", "火星天", "太阳天", "金星天", "水星天", "月亮天"]

    var body: some View {
        let rings = makeRings()
        ScrollView([.horizontal, .vertical]) {
            TimelineView(.animation(paused: detail != nil)) { tl in
                let now = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    HeavenBackdrop(S: S, now: now, rings: rings.count)
                    ForEach(Array(rings.enumerated()), id: \.offset) { r, ring in
                        let rad = radius(r)
                        Text(ringNames[r] + (ring.last.map { " · ≥\(fameTotal($0))" } ?? ""))
                            .font(.system(size: 10, weight: .medium, design: .serif))
                            .foregroundStyle(Color.primary.opacity(0.45))
                            .position(x: S / 2, y: S / 2 - rad - 14)
                        ForEach(Array(ring.enumerated()), id: \.element.id) { k, t in
                            // 每一重天以不同速度、交替方向缓缓转动
                            let dir = r % 2 == 0 ? 1.0 : -1.0
                            let a = Double(k) / Double(ring.count) * 2 * .pi + dir * now * 0.6 / (rad / 60) + Double(r) * 0.7
                            soul(t, size: 56 - Double(r) * 2)
                                .position(x: S / 2 + cos(a) * rad, y: S / 2 + sin(a) * rad)
                        }
                    }
                    VStack(spacing: 2) {
                        Text("至高天").font(.system(size: 13, weight: .semibold, design: .serif)).tracking(3)
                        Text("Empyrean").font(.system(size: 9, design: .serif)).foregroundStyle(Color.primary.opacity(0.5))
                    }
                    .position(x: S / 2, y: S / 2)
                }
                .frame(width: S, height: S)
            }
        }
        .defaultScrollAnchor(.center)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: 0) {
            HomeTitle(title: "天堂", subtitle: "仿但丁《天堂篇》：分数越高，越靠近中心的光")
                .padding(.bottom, 10)
                .background(.ultraThinMaterial.opacity(0.9))
        }
        .sheet(item: $detail) { FameSheet(thinker: $0) }
    }

    private func radius(_ r: Int) -> Double { 78 + Double(r) * 43 }

    private func makeRings() -> [[Thinker]] {
        var out: [[Thinker]] = []
        var i = 0
        for n in ringSizes where i < rankedThinkers.count {
            out.append(Array(rankedThinkers[i..<min(rankedThinkers.count, i + n)]))
            i += n
        }
        if i < rankedThinkers.count { out[out.count - 1] += rankedThinkers[i...] }
        return out
    }

    private func soul(_ t: Thinker, size: Double) -> some View {
        let tier = FameTier(fameTotal(t))
        return Button { detail = t } label: {
            FamePlate(thinker: t, compact: size < 50)
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .glassEffect(tier == .pure ? Glass.regular.tint(fameGold.opacity(0.4)).interactive()
                                   : Glass.regular.tint(fameRegionTint(t.region).opacity(tier == .fine ? 0.25 : 0.12)).interactive(), in: .circle)
        .overlay(Circle().strokeBorder(tier == .pure ? fameGold.opacity(0.8) : .clear, lineWidth: 0.8))
    }
}

private struct HeavenBackdrop: View {
    let S: Double
    let now: Double
    let rings: Int
    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: S / 2, y: S / 2)
            // 中心的光：一层层向外淡去
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 260, y: c.y - 260, width: 520, height: 520)),
                     with: .radialGradient(Gradient(colors: [Color.white.opacity(0.95), fameGold.opacity(0.45), fameGold.opacity(0.08), .clear]),
                                           center: c, startRadius: 0, endRadius: 260))
            // 光芒
            for k in 0..<24 {
                let a = Double(k) / 24 * 2 * .pi + now * 0.03
                var ray = Path()
                ray.move(to: c)
                ray.addLine(to: CGPoint(x: c.x + cos(a - 0.03) * 440, y: c.y + sin(a - 0.03) * 440))
                ray.addLine(to: CGPoint(x: c.x + cos(a + 0.03) * 440, y: c.y + sin(a + 0.03) * 440))
                ray.closeSubpath()
                ctx.fill(ray, with: .radialGradient(Gradient(colors: [fameGold.opacity(0.10), .clear]), center: c, startRadius: 40, endRadius: 440))
            }
            // 九重天的轨道
            for r in 0..<rings {
                let rad = 78 + Double(r) * 43
                ctx.stroke(Path(ellipseIn: CGRect(x: c.x - rad, y: c.y - rad, width: rad * 2, height: rad * 2)),
                           with: .color(fameGold.opacity(0.28 - Double(r) * 0.02)), lineWidth: r == 0 ? 1.2 : 0.7)
            }
            // 星辰
            for i in 0..<140 {
                let fi = Double(i)
                let x = fract(sin(fi * 12.9898) * 43758.5453) * S
                let y = fract(sin(fi * 78.233) * 12345.678) * S
                let tw = 0.3 + 0.7 * abs(sin(now * 0.8 + fi))
                let r = 0.6 + fract(fi * 0.37) * 1.2
                ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(fameGold.opacity(0.35 * tw)))
            }
        }
        .frame(width: S, height: S)
        .allowsHitTesting(false)
    }
}

// MARK: - 罗马神殿（仿万神殿：穹顶、圆孔光柱、三排柱廊）

struct TempleView: View {
    @State private var detail: Thinker?
    @State private var lit = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                HomeTitle(title: "罗马神殿", subtitle: "仿万神殿：最高分者立在穹顶圆孔落下的光里；三门学科各占一排柱廊，柱高即分数")
                if let top = rankedThinkers.first { dome(top) }
                ForEach(Region.allCases, id: \.self) { r in colonnade(r) }
                Spacer(minLength: 30)
            }
        }
        .scrollIndicators(.hidden)
        .onAppear { withAnimation(.easeOut(duration: 1.6)) { lit = true } }
        .sheet(item: $detail) { FameSheet(thinker: $0) }
    }

    private func dome(_ t: Thinker) -> some View {
        ZStack(alignment: .bottom) {
            DomeShape(lit: lit).aspectRatio(2, contentMode: .fit)
            Button { detail = t } label: {
                VStack(spacing: 6) {
                    Text("至 纯").font(.system(size: 10, weight: .semibold, design: .serif)).tracking(4).foregroundStyle(fameGold)
                    Text(t.name).font(.system(size: 26, weight: .semibold, design: .serif))
                    if let s = fameOf(t) { FameRing(score: s.total, size: 46) }
                }
                .foregroundStyle(Color.primary)
                .padding(.horizontal, 26).padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .modifier(FameCardStyle(tier: .pure, region: t.region, radius: 26))
            .padding(.bottom, 18)
            .scaleEffect(lit ? 1 : 0.9)
            .opacity(lit ? 1 : 0)
        }
        .padding(.horizontal, 16)
    }

    private func colonnade(_ r: Region) -> some View {
        let people = rankedThinkers.filter { $0.region == r }
        let latin = ["china": "SINAE", "west": "OCCIDENS", "math": "MATHESIS"][r.rawValue] ?? ""
        return VStack(spacing: 0) {
            // 山花（三角楣）与额枋
            ZStack {
                Pediment().fill(LinearGradient(colors: [fameGold.opacity(0.22), fameGold.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                Pediment().stroke(fameGold.opacity(0.45), lineWidth: 0.8)
                VStack(spacing: 1) {
                    Text(latin).font(.system(size: 11, weight: .semibold, design: .serif)).tracking(5)
                    Text(r.title).font(.system(size: 15, weight: .semibold, design: .serif))
                }
                .padding(.top, 18)
            }
            .frame(height: 64)
            .padding(.horizontal, 16)
            Rectangle().fill(fameGold.opacity(0.25)).frame(height: 8).padding(.horizontal, 16)
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(people) { t in column(t) }
                }
                .padding(.horizontal, 22)
                .padding(.top, 6)
            }
            .scrollIndicators(.hidden)
            // 台阶
            VStack(spacing: 2) {
                Rectangle().fill(fameGold.opacity(0.18)).frame(height: 5)
                Rectangle().fill(fameGold.opacity(0.12)).frame(height: 5).padding(.horizontal, -6)
            }
            .padding(.horizontal, 16)
        }
    }

    private func column(_ t: Thinker) -> some View {
        let s = fameTotal(t)
        let tier = FameTier(s)
        let h = 90 + Double(max(0, s - 30)) * 2.1
        let name = shortName(t).replacingOccurrences(of: "·", with: "")
        return Button { detail = t } label: {
            VStack(spacing: 0) {
                // 柱头
                Text("\(s)").font(.system(size: 11, weight: .semibold, design: .serif).monospacedDigit())
                    .foregroundStyle(tier == .pure ? fameGold : Color.primary.opacity(0.7))
                    .frame(width: 46, height: 18)
                    .background(fameGold.opacity(tier == .pure ? 0.3 : 0.12), in: .rect(cornerRadius: 3))
                // 柱身：凹槽线 + 竖排名字
                ZStack {
                    HStack(spacing: 6) { ForEach(0..<4, id: \.self) { _ in Rectangle().fill(Color.primary.opacity(0.06)).frame(width: 1) } }
                    VStack(spacing: 0) {
                        ForEach(Array(name.prefix(6).enumerated()), id: \.offset) { _, ch in
                            Text(String(ch)).font(.system(size: tier == .pure ? 15 : 13, weight: .semibold, design: .serif))
                        }
                    }
                }
                .frame(width: 36, height: h)
                .glassEffect(tier == .pure ? Glass.regular.tint(fameGold.opacity(0.3)) : Glass.regular.tint(fameRegionTint(t.region).opacity(tier == .fine ? 0.22 : 0.1)),
                             in: .rect(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(tier == .pure ? fameGold.opacity(0.7) : .clear, lineWidth: 0.8))
                // 柱础
                RoundedRectangle(cornerRadius: 2).fill(fameGold.opacity(0.2)).frame(width: 46, height: 7)
            }
            .foregroundStyle(Color.primary)
        }
        .buttonStyle(.plain)
    }
}

private struct Pediment: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

/// 穹顶剖面：格子天花（藻井）、顶上的圆孔、落下的一道光
private struct DomeShape: View {
    let lit: Bool
    var body: some View {
        Canvas { ctx, size in
            let W = size.width, H = size.height
            let c = CGPoint(x: W / 2, y: H)
            let R = min(W / 2, H)
            // 穹顶
            var dome = Path()
            dome.addArc(center: c, radius: R, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            dome.closeSubpath()
            ctx.fill(dome, with: .linearGradient(Gradient(colors: [fameGold.opacity(0.16), fameGold.opacity(0.04)]), startPoint: .zero, endPoint: CGPoint(x: 0, y: H)))
            // 藻井：五圈格子
            for ring in 1...5 {
                let r = R * (1 - Double(ring) * 0.14)
                var arc = Path()
                arc.addArc(center: c, radius: r, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                ctx.stroke(arc, with: .color(fameGold.opacity(0.22)), lineWidth: 0.7)
            }
            for k in 1..<14 {
                let a = Double.pi + Double(k) / 14 * Double.pi
                var l = Path()
                l.move(to: CGPoint(x: c.x + cos(a) * R * 0.3, y: c.y + sin(a) * R * 0.3))
                l.addLine(to: CGPoint(x: c.x + cos(a) * R, y: c.y + sin(a) * R))
                ctx.stroke(l, with: .color(fameGold.opacity(0.18)), lineWidth: 0.6)
            }
            ctx.stroke(dome, with: .color(fameGold.opacity(0.5)), lineWidth: 1)
            // 圆孔与光柱
            let top = CGPoint(x: c.x, y: c.y - R)
            ctx.fill(Path(ellipseIn: CGRect(x: top.x - 18, y: top.y - 4, width: 36, height: 8)), with: .color(Color.white.opacity(0.9)))
            if lit {
                var beam = Path()
                beam.move(to: CGPoint(x: top.x - 16, y: top.y))
                beam.addLine(to: CGPoint(x: top.x + 16, y: top.y))
                beam.addLine(to: CGPoint(x: top.x + 70, y: H))
                beam.addLine(to: CGPoint(x: top.x - 70, y: H))
                beam.closeSubpath()
                ctx.fill(beam, with: .linearGradient(Gradient(colors: [Color.white.opacity(0.75), fameGold.opacity(0.25), fameGold.opacity(0.05)]),
                                                     startPoint: top, endPoint: CGPoint(x: top.x, y: H)))
            }
        }
    }
}
