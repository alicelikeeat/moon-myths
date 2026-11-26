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

// MARK: - 未评分模式：隐藏官方分数、排名与等级，由用户自己打分

enum ScoreMode {
    static var blind: Bool { UserDefaults.standard.bool(forKey: "blindMode") }
}

/// 用户自己的评分：人物 0–100 分，作品 1–5 星（存在本机）
enum UserRatings {
    private static func dict(_ key: String) -> [String: Int] {
        (UserDefaults.standard.dictionary(forKey: key) as? [String: Int]) ?? [:]
    }
    static func score(_ id: String) -> Int? { dict("userScores")[id] }
    static func setScore(_ id: String, _ v: Int?) {
        var d = dict("userScores"); d[id] = v
        UserDefaults.standard.set(d, forKey: "userScores")
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "ratingsRev") + 1, forKey: "ratingsRev")
    }
    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: "userScores")
        UserDefaults.standard.removeObject(forKey: "workStars")
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "ratingsRev") + 1, forKey: "ratingsRev")
    }
        static func stars(_ bookId: String) -> Int { dict("workStars")[bookId] ?? 0 }
    static func setStars(_ bookId: String, _ v: Int) {
        var d = dict("workStars"); d[bookId] = v == 0 ? nil : v
        UserDefaults.standard.set(d, forKey: "workStars")
    }
}

/// 分数与排名的缓存：只在模式或用户评分变化时重算（原来每次访问都要重新读取、排序）
enum ScoreCache {
    private static var key = ""
    private static var totals: [String: Int] = [:]
    private static var ranked: [Thinker] = []

    private static func refresh() {
        let d = UserDefaults.standard
        let k = "\(d.bool(forKey: "blindMode"))-\(d.integer(forKey: "ratingsRev"))"
        guard k != key else { return }
        key = k
        let blind = d.bool(forKey: "blindMode")
        var t: [String: Int] = [:]
        for p in thinkers { t[p.id] = blind ? (UserRatings.score(p.id) ?? 0) : (fameOf(p)?.total ?? 0) }
        totals = t
        ranked = thinkers.sorted { (t[$0.id] ?? 0, -$0.born) > (t[$1.id] ?? 0, -$1.born) }
    }
    static func total(_ id: String) -> Int { refresh(); return totals[id] ?? 0 }
    static var rankedList: [Thinker] { refresh(); return ranked }
}

/// 当前模式下的分数：官方模式为评分结果；未评分模式为用户自己打的分（没打为 0，即“未评”）
func fameTotal(_ t: Thinker) -> Int { ScoreCache.total(t.id) }

/// 按当前模式的分数从高到低（未评的人按年代排在最后）
var rankedThinkers: [Thinker] { ScoreCache.rankedList }

let fameGold = Color(red: 0.80, green: 0.63, blue: 0.30)

enum FameTier {
    case pure, fine, plain, unrated
    init(_ s: Int) { self = s <= 0 ? .unrated : (s >= 85 ? .pure : (s >= 75 ? .fine : .plain)) }
    var name: String { switch self { case .pure: "至纯"; case .fine: "精致"; case .plain: "专业"; case .unrated: "未评" } }
    /// 至纯 = 香槟金；精致 = 纯金；专业 = 钻石；未评 = 素白
    var color: Color { switch self { case .pure: champagne; case .fine: pureGold; case .plain: diamond; case .unrated: Color(white: 0.9) } }
    var deep: Color { switch self { case .pure: champagneDeep; case .fine: pureGoldDeep; case .plain: diamondDeep; case .unrated: Color(white: 0.5) } }
    var sheen: [Color] {
        switch self {
        case .unrated: [Color(white: 0.92), .white, Color(white: 0.75), Color(white: 0.92)]
        case .pure: [champagne, Color(red: 1, green: 0.97, blue: 0.9), champagneDeep, champagne]
        case .fine: [pureGold, Color(red: 1, green: 0.9, blue: 0.5), pureGoldDeep, pureGold]
        case .plain: [diamond, .white, diamondDeep, .white, diamond]
        }
    }
}

let champagne = Color(red: 0.91, green: 0.82, blue: 0.66)
let champagneDeep = Color(red: 0.70, green: 0.58, blue: 0.40)
let pureGold = Color(red: 0.88, green: 0.68, blue: 0.14)
let pureGoldDeep = Color(red: 0.68, green: 0.50, blue: 0.06)
let diamond = Color(red: 0.80, green: 0.93, blue: 1.0)
let diamondDeep = Color(red: 0.40, green: 0.64, blue: 0.82)

func fameRegionTint(_ r: Region) -> Color {
    switch r {
    case .china: return Moon.violet
    case .west: return Moon.gold
    case .math: return Color(red: 0.35, green: 0.72, blue: 0.62)
    }
}


// MARK: - 分数圈

struct FameRing: View {
    let score: Int
    var size: CGFloat = 54
    var body: some View {
        let tier = FameTier(score)
        ZStack {
            Circle().stroke(Color.primary.opacity(0.08), lineWidth: size * 0.08)
            Circle().trim(from: 0, to: CGFloat(score) / 100)
                .stroke(AngularGradient(colors: tier.sheen, center: .center),
                        style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(score > 0 ? "\(score)" : "未评").font(.system(size: size * (score > 0 ? 0.36 : 0.24), weight: .semibold, design: .serif)).monospacedDigit()
        }
        .frame(width: size, height: size)
    }
}

/// 卡片的分级外观：至纯 = 香槟金；精致 = 纯金；专业 = 钻石
struct FameCardStyle: ViewModifier {
    let tier: FameTier
    let region: Region
    var radius: CGFloat = 28
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        let border = LinearGradient(colors: tier.sheen, startPoint: .topLeading, endPoint: .bottomTrailing)
        switch tier {
        case .pure:
            // 至纯：素白（夜间素黑）底，香槟金双线
            content
                .background((scheme == .dark ? Color.black : Color.white).opacity(0.86), in: .rect(cornerRadius: radius))
                .glassEffect(.regular, in: .rect(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(border, lineWidth: 0.9))
                .overlay(RoundedRectangle(cornerRadius: radius - 5).strokeBorder(champagne.opacity(0.4), lineWidth: 0.5).padding(5))
        case .fine:
            // 精致：纯金染色玻璃，金色细线
            content
                .glassEffect(Glass.regular.tint(pureGold.opacity(0.16)), in: .rect(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(border, lineWidth: 0.8))
        case .plain, .unrated:
            // 专业：钻石般清透的玻璃，冷白细线
            content
                .glassEffect(Glass.regular.tint(diamond.opacity(0.22)), in: .rect(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(border.opacity(0.8), lineWidth: 0.6))
        }
    }
}
