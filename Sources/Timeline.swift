import SwiftUI

// MARK: - 数据

enum Region: String, CaseIterable {
    case china, west, math
    var title: String {
        switch self {
        case .china: return "中国"
        case .west: return "西方"
        case .math: return "数学"
        }
    }
}

struct Thinker: Identifiable {
    let id: String
    let name: String
    let region: Region
    let born: Int          // 公元前用负数
    let died: Int
    let approx: Bool       // 生卒年有争议或只是约数
    let thesis: String
    var libraryId: String? = nil   // 已有深度内容时，指向书库里的人物
}

struct Era {
    let region: Region
    let name: String
    let start: Int
    let end: Int
}

struct Influence {
    let from: String
    let to: String
    var critical = false   // 以批判、反叛为主的影响
}

func yearText(_ y: Int) -> String { y < 0 ? "前\(-y)" : "\(y)" }

let thinkers: [Thinker] = [
    // 中国
    Thinker(id: "laozi", name: "老子", region: .china, born: -600, died: -470, approx: true,
            thesis: "以“道”为万物本源，主张无为、柔弱、返璞归真。生卒年不详。"),
    Thinker(id: "kongzi", name: "孔子", region: .china, born: -551, died: -479, approx: false,
            thesis: "以“仁”为核心、“礼”为规范，开创儒家，重视教育与修身。"),
    Thinker(id: "mozi", name: "墨子", region: .china, born: -470, died: -391, approx: true,
            thesis: "墨家创始人：兼爱、非攻、尚贤、节用，重视逻辑与实证。"),
    Thinker(id: "mengzi", name: "孟子", region: .china, born: -372, died: -289, approx: true,
            thesis: "性善论：人皆有恻隐之心；主张仁政与民本。"),
    Thinker(id: "zhuangzi", name: "庄子", region: .china, born: -369, died: -286, approx: true,
            thesis: "齐物与逍遥：打破是非、物我、生死的界限。"),
    Thinker(id: "xunzi", name: "荀子", region: .china, born: -313, died: -238, approx: true,
            thesis: "性恶论：人性需要礼义与后天教化来矫正。"),
    Thinker(id: "hanfei", name: "韩非", region: .china, born: -280, died: -233, approx: true,
            thesis: "法家集大成者：法、术、势相结合的治国之道。"),
    Thinker(id: "dongzhongshu", name: "董仲舒", region: .china, born: -179, died: -104, approx: true,
            thesis: "天人感应，推动儒学成为汉代官方学说。"),
    Thinker(id: "huineng", name: "慧能", region: .china, born: 638, died: 713, approx: false,
            thesis: "禅宗六祖：主张顿悟，明心见性，见性成佛。"),
    Thinker(id: "zhuxi", name: "朱熹", region: .china, born: 1130, died: 1200, approx: false,
            thesis: "理学集大成：格物致知，理与气不离不杂。"),
    Thinker(id: "wangyangming", name: "王阳明", region: .china, born: 1472, died: 1529, approx: false,
            thesis: "心学：心即理、知行合一、致良知。"),
    Thinker(id: "wangfuzhi", name: "王夫之", region: .china, born: 1619, died: 1692, approx: false,
            thesis: "以气为本，反思宋明理学，重视历史与实践。"),
    Thinker(id: "zhouyi", name: "《周易》", region: .china, born: -1046, died: -771, approx: true,
            thesis: "以卦象推演变化：一阴一阳之谓道。"),
    Thinker(id: "guanzhong", name: "管仲", region: .china, born: -723, died: -645, approx: true,
            thesis: "仓廪实而知礼节；礼义廉耻，国之四维。"),
    Thinker(id: "sunwu", name: "孙子", region: .china, born: -545, died: -470, approx: true,
            thesis: "知己知彼，百战不殆；不战而屈人之兵。"),
    Thinker(id: "zisi", name: "子思（《礼记》）", region: .china, born: -483, died: -402, approx: true,
            thesis: "《中庸》：诚者天之道；《大学》：明明德、亲民、止于至善。"),
    Thinker(id: "liezi", name: "列子", region: .china, born: -450, died: -375, approx: true,
            thesis: "贵虚：御风而行，顺应自然。"),
    Thinker(id: "gongsunlong", name: "公孙龙", region: .china, born: -320, died: -250, approx: true,
            thesis: "名家：白马非马；离坚白。"),
    Thinker(id: "wangchong", name: "王充", region: .china, born: 27, died: 97, approx: true,
            thesis: "疾虚妄：天道自然，反对天人感应。"),
    Thinker(id: "zhoudunyi", name: "周敦颐", region: .china, born: 1017, died: 1073, approx: false,
            thesis: "无极而太极；诚为五常之本。"),
    Thinker(id: "zhangzai", name: "张载", region: .china, born: 1020, died: 1077, approx: false,
            thesis: "太虚即气；民吾同胞，物吾与也。"),
    Thinker(id: "ercheng", name: "二程", region: .china, born: 1032, died: 1107, approx: false,
            thesis: "程颢、程颐：天理二字是自家体贴出来；性即理。"),
    Thinker(id: "luxiangshan", name: "陆九渊", region: .china, born: 1139, died: 1193, approx: false,
            thesis: "心即理；宇宙便是吾心，吾心即是宇宙。"),
    Thinker(id: "guyanwu", name: "顾炎武", region: .china, born: 1613, died: 1682, approx: false,
            thesis: "经世致用；天下兴亡，匹夫有责（意）。"),
    // 西方
    Thinker(id: "socrates", name: "苏格拉底", region: .west, born: -470, died: -399, approx: true,
            thesis: "以诘问追问定义；认为未经审视的生活不值得过。"),
    Thinker(id: "plato", name: "柏拉图", region: .west, born: -427, died: -347, approx: true,
            thesis: "理念论：可感事物只是永恒理念的摹本。"),
    Thinker(id: "aristotle", name: "亚里士多德", region: .west, born: -384, died: -322, approx: false,
            thesis: "形式与质料、四因说，奠定形式逻辑。"),
    Thinker(id: "lucretius", name: "卢克莱修", region: .west, born: -99, died: -55, approx: true,
            thesis: "用原子论解释万物，以此摆脱对神和死亡的恐惧。"),
    Thinker(id: "epictetus", name: "爱比克泰德", region: .west, born: 50, died: 135, approx: true,
            thesis: "斯多葛派：区分在我们控制之内与之外的事。"),
    Thinker(id: "marcusaurelius", name: "马可·奥勒留", region: .west, born: 121, died: 180, approx: false,
            thesis: "哲学家皇帝：顺应自然，安守本分，内心自足。"),
    Thinker(id: "augustine", name: "奥古斯丁", region: .west, born: 354, died: 430, approx: false,
            thesis: "信仰寻求理解；时间是心灵的延展。"),
    Thinker(id: "aquinas", name: "阿奎那", region: .west, born: 1225, died: 1274, approx: true,
            thesis: "融合亚里士多德哲学与基督教神学。"),
    Thinker(id: "machiavelli", name: "马基雅维利", region: .west, born: 1469, died: 1527, approx: false,
            thesis: "政治有自己的逻辑：君主要像狐狸也像狮子。"),
    Thinker(id: "hobbes", name: "霍布斯", region: .west, born: 1588, died: 1679, approx: false,
            thesis: "自然状态是一切人对一切人的战争；契约造就利维坦。"),
    Thinker(id: "descartes", name: "笛卡尔", region: .west, born: 1596, died: 1650, approx: false,
            thesis: "我思故我在；心与物是两种实体。"),
    Thinker(id: "pascal", name: "帕斯卡", region: .west, born: 1623, died: 1662, approx: false,
            thesis: "人是会思想的芦苇；心有理性不知道的理由。"),
    Thinker(id: "spinoza", name: "斯宾诺莎", region: .west, born: 1632, died: 1677, approx: false,
            thesis: "神即自然：只有唯一的实体。"),
    Thinker(id: "locke", name: "洛克", region: .west, born: 1632, died: 1704, approx: false,
            thesis: "心灵是白板；政府的正当性来自被统治者的同意。"),
    Thinker(id: "leibniz", name: "莱布尼茨", region: .west, born: 1646, died: 1716, approx: false,
            thesis: "单子论与前定和谐。"),
    Thinker(id: "berkeley", name: "贝克莱", region: .west, born: 1685, died: 1753, approx: false,
            thesis: "存在就是被感知。"),
    Thinker(id: "hume", name: "休谟", region: .west, born: 1711, died: 1776, approx: false,
            thesis: "因果只是习惯性的联想；归纳无法被理性证明。"),
    Thinker(id: "rousseau", name: "卢梭", region: .west, born: 1712, died: 1778, approx: false,
            thesis: "人生而自由，却无往不在枷锁之中；不平等起源于私有制。"),
    Thinker(id: "kant", name: "康德", region: .west, born: 1724, died: 1804, approx: false,
            thesis: "哥白尼式革命：对象符合认识的先天形式。", libraryId: "kant"),
    Thinker(id: "hegel", name: "黑格尔", region: .west, born: 1770, died: 1831, approx: false,
            thesis: "真理是全体：精神在否定中展开自身。", libraryId: "hegel"),
    Thinker(id: "schopenhauer", name: "叔本华", region: .west, born: 1788, died: 1860, approx: false,
            thesis: "世界是我的表象，也是盲目的意志；人生在痛苦与无聊之间摆动。"),
    Thinker(id: "kierkegaard", name: "克尔凯郭尔", region: .west, born: 1813, died: 1855, approx: false,
            thesis: "生存的三个阶段：审美、伦理、宗教；信仰的跳跃。"),
    Thinker(id: "mill", name: "密尔", region: .west, born: 1806, died: 1873, approx: false,
            thesis: "功利原则：最大多数人的最大幸福；个人自由的界限是不伤害他人。"),
    Thinker(id: "marx", name: "马克思", region: .west, born: 1818, died: 1883, approx: false,
            thesis: "历史是阶级斗争的历史；经济基础决定上层建筑。"),
    Thinker(id: "nietzsche", name: "尼采", region: .west, born: 1844, died: 1900, approx: false,
            thesis: "重估一切价值；权力意志与永恒轮回。"),
    Thinker(id: "james", name: "威廉·詹姆斯", region: .west, born: 1842, died: 1910, approx: false,
            thesis: "实用主义：一个观念的意义在于它带来的实际效果。"),
    Thinker(id: "russell", name: "罗素", region: .west, born: 1872, died: 1970, approx: false,
            thesis: "用逻辑分析澄清语言、数学与知识。", libraryId: "russell"),
    Thinker(id: "wittgenstein", name: "维特根斯坦", region: .west, born: 1889, died: 1951, approx: false,
            thesis: "早期：语言的界限即世界的界限；后期：意义在于使用。"),
    Thinker(id: "heidegger", name: "海德格尔", region: .west, born: 1889, died: 1976, approx: false,
            thesis: "追问存在的意义；此在是向死而在。"),
    Thinker(id: "sartre", name: "萨特", region: .west, born: 1905, died: 1980, approx: false,
            thesis: "存在先于本质；人被判定为自由。"),
    Thinker(id: "camus", name: "加缪", region: .west, born: 1913, died: 1960, approx: false,
            thesis: "荒诞：在没有意义的世界里反抗，想象西西弗是幸福的。"),

    // 数学
    Thinker(id: "euclid", name: "欧几里得", region: .math, born: -325, died: -265, approx: true,
            thesis: "《几何原本》：从定义、公设、公理出发，一步步证明几何命题，是公理化方法的典范。"),
    Thinker(id: "liuhui", name: "刘徽", region: .math, born: 225, died: 295, approx: true,
            thesis: "注《九章算术》：用出入相补证明句股，以割圆术逼近圆周率。"),
    Thinker(id: "archimedes", name: "阿基米德", region: .math, born: -287, died: -212, approx: true,
            thesis: "用杠杆“称”出面积与体积，再以穷竭法严格证明：抛物线弓形等于内接三角形的 4/3。"),
    Thinker(id: "zhaoshuang", name: "赵爽", region: .math, born: 182, died: 250, approx: true,
            thesis: "注《周髀算经》，作“勾股圆方图”（弦图），以朱实、黄实证明勾股定理。"),
    Thinker(id: "newton", name: "牛顿", region: .math, born: 1643, died: 1727, approx: false,
            thesis: "《自然哲学的数学原理》：三大运动定律与万有引力，用几何证明天体运动。"),
    Thinker(id: "descartes-geometry", name: "笛卡尔（数学）", region: .math, born: 1596, died: 1650, approx: false,
            thesis: "《几何学》：用字母和方程表示线段与曲线，开创解析几何。"),
]

let eras: [Era] = [
    Era(region: .china, name: "西周", start: -1046, end: -771),
    Era(region: .china, name: "春秋", start: -770, end: -476),
    Era(region: .china, name: "战国", start: -475, end: -221),
    Era(region: .china, name: "秦汉", start: -221, end: 220),
    Era(region: .china, name: "魏晋南北朝", start: 220, end: 589),
    Era(region: .china, name: "隋唐", start: 589, end: 907),
    Era(region: .china, name: "宋元", start: 960, end: 1368),
    Era(region: .china, name: "明", start: 1368, end: 1644),
    Era(region: .china, name: "清", start: 1644, end: 1912),
    Era(region: .math, name: "古代数学", start: -600, end: 500),
    Era(region: .math, name: "中世纪与东方", start: 500, end: 1500),
    Era(region: .math, name: "近代数学", start: 1500, end: 1800),
    Era(region: .math, name: "现代数学", start: 1800, end: 2000),
    Era(region: .west, name: "古希腊", start: -600, end: -323),
    Era(region: .west, name: "希腊化与罗马", start: -323, end: 476),
    Era(region: .west, name: "中世纪", start: 476, end: 1400),
    Era(region: .west, name: "文艺复兴", start: 1400, end: 1600),
    Era(region: .west, name: "近代哲学", start: 1600, end: 1781),
    Era(region: .west, name: "德国古典", start: 1781, end: 1831),
    Era(region: .west, name: "现代哲学", start: 1831, end: 2000),
]

let influences: [Influence] = [
    Influence(from: "kongzi", to: "mengzi"), Influence(from: "kongzi", to: "xunzi"),
    Influence(from: "xunzi", to: "hanfei"), Influence(from: "laozi", to: "zhuangzi"),
    Influence(from: "kongzi", to: "dongzhongshu"), Influence(from: "mengzi", to: "zhuxi"),
    Influence(from: "zhuxi", to: "wangyangming", critical: true),
    Influence(from: "plato", to: "euclid"), Influence(from: "euclid", to: "archimedes"), Influence(from: "euclid", to: "descartes-geometry"),
    Influence(from: "zhaoshuang", to: "liuhui"), Influence(from: "descartes-geometry", to: "newton"), Influence(from: "euclid", to: "newton"),
    Influence(from: "newton", to: "kant"), Influence(from: "euclid", to: "spinoza"),
    Influence(from: "socrates", to: "plato"), Influence(from: "plato", to: "aristotle"),
    Influence(from: "plato", to: "augustine"), Influence(from: "aristotle", to: "aquinas"),
    Influence(from: "descartes", to: "spinoza"), Influence(from: "descartes", to: "leibniz"),
    Influence(from: "leibniz", to: "kant"), Influence(from: "hume", to: "kant"),
    Influence(from: "kant", to: "hegel"), Influence(from: "hegel", to: "russell", critical: true),
    Influence(from: "russell", to: "wittgenstein"),
    Influence(from: "epictetus", to: "marcusaurelius"),
    Influence(from: "kongzi", to: "zisi"), Influence(from: "zisi", to: "mengzi"), Influence(from: "laozi", to: "liezi"),
    Influence(from: "dongzhongshu", to: "wangchong", critical: true), Influence(from: "zhoudunyi", to: "ercheng"),
    Influence(from: "zhangzai", to: "ercheng"), Influence(from: "ercheng", to: "zhuxi"),
    Influence(from: "luxiangshan", to: "wangyangming"), Influence(from: "zhuxi", to: "luxiangshan", critical: true),
    Influence(from: "wangyangming", to: "guyanwu", critical: true), Influence(from: "hobbes", to: "locke"),
    Influence(from: "locke", to: "berkeley"), Influence(from: "berkeley", to: "hume"),
    Influence(from: "locke", to: "rousseau"), Influence(from: "rousseau", to: "kant"),
    Influence(from: "kant", to: "schopenhauer"), Influence(from: "hegel", to: "kierkegaard", critical: true),
    Influence(from: "hegel", to: "marx"), Influence(from: "schopenhauer", to: "nietzsche"),
    Influence(from: "kierkegaard", to: "heidegger"), Influence(from: "heidegger", to: "sartre"),
    Influence(from: "james", to: "russell", critical: true),
]

// MARK: - 布局

private let minYear = -1100
private let maxYear = 2000
private let leftPad = 70.0          // 左侧留给泳道名称
private let rulerH = 44.0           // 顶部年代尺
private let rowH = 42.0

private struct Placed {
    let thinker: Thinker
    let x: Double, y: Double, w: Double
}

private struct Layout {
    var placed: [Placed] = []
    var tops: [Region: Double] = [:]
    var heights: [Region: Double] = [:]
    var total = 0.0
}

private func xOf(_ year: Double, _ s: Double) -> Double { (year - Double(minYear)) * s + leftPad }

/// 每条泳道按需要的行数自动加高，人物胶囊互不重叠
private func layout(scale: Double) -> Layout {
    var L = Layout()
    var top = rulerH + 12
    for region in Region.allCases {
        var rowEnds: [Double] = []
        for t in thinkers.filter({ $0.region == region }).sorted(by: { $0.born < $1.born }) {
            let x = xOf(Double(t.born), scale)
            let w = max(Double(t.died - t.born) * scale, 64)
            let row = rowEnds.firstIndex { $0 + 6 <= x } ?? rowEnds.count
            if row == rowEnds.count { rowEnds.append(x + w) } else { rowEnds[row] = x + w }
            L.placed.append(Placed(thinker: t, x: x, y: top + 40 + Double(row) * rowH, w: w))
        }
        let h = 40 + Double(max(1, rowEnds.count)) * rowH + 26
        L.tops[region] = top
        L.heights[region] = h
        top += h + 14
    }
    L.total = top + 70
    return L
}

private func regionTint(_ r: Region) -> Color {
    switch r {
    case .china: return Moon.violet
    case .west: return Moon.silver
    case .math: return Color(red: 0.35, green: 0.72, blue: 0.62)
    }
}

// MARK: - 视图

/// 时间轴：可上下左右自由拖动；双指缩放时以手指处的年代为中心；
/// 顶部年代尺、左侧泳道名始终可见；可一键跳到某个时代。
struct HistoryTimelineView: View {
    @State private var scale = 0.9               // 每年多少点
    @State private var pinchStart: (scale: Double, year: Double, screenX: Double)?
    @State private var position = ScrollPosition(edge: .leading)
    @State private var offset: CGPoint = .zero
    @State private var viewport: CGSize = .zero
    @State private var selected: Thinker?
    @State private var focus: String?            // 高亮某人的影响关系
    @State private var didStart = false

    private static let jumps: [(String, Int)] = [
        ("西周", -1000), ("轴心时代", -550), ("秦汉 · 希腊化", -200), ("魏晋 · 罗马", 250), ("隋唐 · 中世纪", 800),
        ("宋明 · 经院哲学", 1150), ("文艺复兴 · 明", 1500), ("启蒙 · 清", 1720), ("19 世纪", 1850), ("20 世纪", 1930),
    ]

    var body: some View {
        let s = scale
        let L = layout(scale: s)
        let width = xOf(Double(maxYear), s) + 60
        ZStack(alignment: .topLeading) {
            Backdrop()
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    lanes(s, L, width)
                    links(L.placed)
                    ForEach(L.placed, id: \.thinker.id) { p in
                        capsule(p, s)
                            .position(x: p.x + p.w / 2, y: p.y)
                            .onTapGesture { selected = p.thinker }
                            .onLongPressGesture(minimumDuration: 0.35) {
                                withAnimation(.snappy) { focus = focus == p.thinker.id ? nil : p.thinker.id }
                            }
                    }
                }
                .frame(width: width, height: L.total, alignment: .topLeading)
            }
            .scrollPosition($position)
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: CGPoint.self) { $0.contentOffset } action: { _, new in offset = new }
            .onGeometryChange(for: CGSize.self) { $0.size } action: { viewport = $0 }
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { v in
                        if pinchStart == nil {
                            let sx = Double(v.startLocation.x)
                            let year = (Double(offset.x) + sx - leftPad) / scale + Double(minYear)
                            pinchStart = (scale, year, sx)
                        }
                        guard let st = pinchStart else { return }
                        zoom(to: st.scale * v.magnification, keeping: st.year, at: st.screenX)
                    }
                    .onEnded { _ in pinchStart = nil }
            )
            ruler(s)
            regionLabels(L)
        }
        .navigationTitle("时间轴")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(Self.jumps, id: \.1) { j in
                        Button("\(j.0)（\(yearText(j.1))）") { jump(to: j.1) }
                    }
                } label: { Image(systemName: "calendar.badge.clock") }
                .accessibilityLabel("跳到某个时代")
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 10) {
                Button { zoomCenter(by: 1 / 1.4) } label: { Image(systemName: "minus.magnifyingglass") }
                    .buttonStyle(.glass)
                Text(focus == nil ? "拖动浏览 · 双指缩放 · 点人物看详情 · 长按看影响" : "已高亮影响关系，长按同一人取消")
                    .font(.caption).foregroundStyle(Color.primary.opacity(0.65))
                    .lineLimit(1).minimumScaleFactor(0.8)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .glassEffect(.regular, in: .capsule)
                Button { zoomCenter(by: 1.4) } label: { Image(systemName: "plus.magnifyingglass") }
                    .buttonStyle(.glass)
            }
            .padding(.bottom, 6)
        }
        .sheet(item: $selected) { t in ThinkerSheet(thinker: t) }
        .onAppear {
            guard !didStart else { return }
            didStart = true
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(60))
                jump(to: -620, animated: false)
            }
        }
    }

    // MARK: 缩放与跳转

    private func zoom(to newScale: Double, keeping year: Double, at screenX: Double) {
        let ns = min(5, max(0.15, newScale))
        scale = ns
        let x = max(0, xOf(year, ns) - screenX)
        position.scrollTo(point: CGPoint(x: x, y: offset.y))
    }

    private func zoomCenter(by k: Double) {
        let cx = Double(viewport.width) / 2
        let year = (Double(offset.x) + cx - leftPad) / scale + Double(minYear)
        withAnimation(.snappy) { zoom(to: scale * k, keeping: year, at: cx) }
    }

    private func jump(to year: Int, animated: Bool = true) {
        let x = max(0, xOf(Double(year), scale) - 40)
        if animated { withAnimation(.smooth(duration: 0.6)) { position.scrollTo(point: CGPoint(x: x, y: offset.y)) } }
        else { position.scrollTo(point: CGPoint(x: x, y: 0)) }
    }

    // MARK: 固定在屏幕上的年代尺与泳道名

    private func ruler(_ s: Double) -> some View {
        Canvas { ctx, size in
            let w = Double(size.width)
            let step = s > 2.5 ? 25 : (s > 1.2 ? 50 : (s > 0.5 ? 100 : 200))
            let firstYear = Int((Double(offset.x) - leftPad) / s) + minYear
            var y = (firstYear / step - 1) * step
            while true {
                let x = xOf(Double(y), s) - Double(offset.x)
                if x > w + 40 { break }
                if x > -40 && y >= minYear && y <= maxYear {
                    let major = y % (step * 2) == 0
                    ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: rulerH - (major ? 12 : 7))); p.addLine(to: CGPoint(x: x, y: rulerH - 2)) },
                               with: .color(Color.primary.opacity(major ? 0.45 : 0.25)), lineWidth: 1)
                    if major || s > 1.2 {
                        ctx.draw(Text(y == 0 ? "公元" : yearText(y)).font(.system(size: 10, weight: .medium).monospacedDigit())
                                    .foregroundColor(Color.primary.opacity(0.6)), at: CGPoint(x: x, y: 14))
                    }
                }
                y += step
            }
            // 公元元年那条线
            let x0 = xOf(0, s) - Double(offset.x)
            if x0 > 0 && x0 < w {
                ctx.stroke(Path { p in p.move(to: CGPoint(x: x0, y: 24)); p.addLine(to: CGPoint(x: x0, y: rulerH)) },
                           with: .color(Moon.gold.opacity(0.8)), lineWidth: 1.5)
            }
        }
        .frame(height: rulerH)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial.opacity(0.85))
        .overlay(alignment: .bottom) { Rectangle().fill(Color.primary.opacity(0.08)).frame(height: 0.5) }
        .allowsHitTesting(false)
    }

    private func regionLabels(_ L: Layout) -> some View {
        ZStack(alignment: .topLeading) {
            ForEach(Region.allCases, id: \.self) { r in
                let y = (L.tops[r] ?? 0) - Double(offset.y) + 6
                if y > rulerH - 4 && y < Double(viewport.height) {
                    Text(r.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(regionTint(r) == Moon.silver ? Color.primary.opacity(0.75) : regionTint(r))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .glassEffect(.regular, in: .capsule)
                        .offset(x: 8, y: y)
                }
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: 画布

    private func lanes(_ s: Double, _ L: Layout, _ width: Double) -> some View {
        Canvas { ctx, size in
            for region in Region.allCases {
                let top = L.tops[region] ?? 0
                let height = L.heights[region] ?? 200
                let lane = Path(roundedRect: CGRect(x: 6, y: top, width: Double(size.width) - 12, height: height), cornerRadius: 24)
                ctx.fill(lane, with: .color(regionTint(region).opacity(0.05)))
                for (ei, e) in eras.filter({ $0.region == region }).enumerated() {
                    let x0 = xOf(Double(e.start), s), x1 = xOf(Double(e.end), s)
                    let r = CGRect(x: x0, y: top + 30, width: max(1, x1 - x0), height: height - 36)
                    ctx.fill(Path(roundedRect: r, cornerRadius: 10), with: .color((ei % 2 == 0 ? Moon.violet : Moon.silver).opacity(0.06)))
                    if x1 - x0 > 40 {
                        // 时代名放在泳道顶部，靠左；很宽时在可见区域内跟随
                        let visibleL = max(x0 + 8, Double(offset.x) + leftPad + 40)
                        let lx = min(visibleL, x1 - 8)
                        ctx.draw(Text(e.name).font(.system(size: 11, weight: .medium)).foregroundColor(Color.primary.opacity(0.45)),
                                 at: CGPoint(x: lx, y: top + 18), anchor: .leading)
                    }
                }
            }
            // 竖向网格
            let step = s > 2.5 ? 25 : (s > 1.2 ? 50 : (s > 0.5 ? 100 : 200))
            var y = (minYear / step) * step
            while y <= maxYear {
                let x = xOf(Double(y), s)
                ctx.stroke(Path { p in p.move(to: CGPoint(x: x, y: rulerH)); p.addLine(to: CGPoint(x: x, y: L.total)) },
                           with: .color(y == 0 ? Moon.gold.opacity(0.25) : Color.primary.opacity(0.04)), lineWidth: y == 0 ? 1 : 0.5)
                y += step
            }
        }
        .allowsHitTesting(false)
    }

    private func links(_ placed: [Placed]) -> some View {
        Canvas { ctx, _ in
            let pos = Dictionary(uniqueKeysWithValues: placed.map { ($0.thinker.id, $0) })
            for inf in influences {
                guard let a = pos[inf.from], let b = pos[inf.to] else { continue }
                let on = focus == nil || focus == inf.from || focus == inf.to
                let p0 = CGPoint(x: a.x + a.w / 2, y: a.y)
                let p1 = CGPoint(x: b.x + b.w / 2, y: b.y)
                var path = Path()
                path.move(to: p0)
                path.addQuadCurve(to: p1, control: CGPoint(x: (p0.x + p1.x) / 2, y: min(p0.y, p1.y) - 30))
                let base = (inf.critical ? Moon.violet : Moon.gold)
                ctx.stroke(path, with: .color(base.opacity(focus == nil ? 0.35 : (on ? 0.95 : 0.06))),
                           style: StrokeStyle(lineWidth: on && focus != nil ? 2.2 : 1.1, dash: inf.critical ? [4, 4] : []))
                if on && focus != nil {
                    // 箭头：表示影响的方向
                    let ang = atan2(p1.y - ((p0.y + p1.y) / 2 - 15), p1.x - (p0.x + p1.x) / 2)
                    var head = Path()
                    head.move(to: p1)
                    head.addLine(to: CGPoint(x: p1.x - 9 * cos(ang - 0.4), y: p1.y - 9 * sin(ang - 0.4)))
                    head.move(to: p1)
                    head.addLine(to: CGPoint(x: p1.x - 9 * cos(ang + 0.4), y: p1.y - 9 * sin(ang + 0.4)))
                    ctx.stroke(head, with: .color(base), lineWidth: 2)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func capsule(_ p: Placed, _ s: Double) -> some View {
        let t = p.thinker
        let deep = t.libraryId != nil
        let dim = focus != nil && focus != t.id && !influences.contains { ($0.from == focus && $0.to == t.id) || ($0.to == focus && $0.from == t.id) }
        return VStack(spacing: 0) {
            Text(t.name).font(.system(size: 13, weight: .semibold)).lineLimit(1).minimumScaleFactor(0.75)
            if p.w >= 84 {
                Text("\(t.approx ? "约" : "")\(yearText(t.born))–\(yearText(t.died))")
                    .font(.system(size: 9).monospacedDigit()).opacity(0.7)
            }
        }
        .foregroundStyle(Color.primary)
        .padding(.horizontal, 4)
        .frame(width: p.w, height: 34)
        .mask {
            // 生卒年不确定时两端渐隐
            LinearGradient(stops: t.approx
                           ? [.init(color: .black.opacity(0.35), location: 0), .init(color: .black, location: 0.2),
                              .init(color: .black, location: 0.8), .init(color: .black.opacity(0.35), location: 1)]
                           : [.init(color: .black, location: 0), .init(color: .black, location: 1)],
                           startPoint: .leading, endPoint: .trailing)
        }
        .glassEffect(Glass.regular.tint((deep ? Moon.gold : regionTint(t.region)).opacity(deep ? 0.35 : 0.18)), in: .capsule)
        .overlay {
            if focus == t.id { Capsule().strokeBorder(Moon.gold, lineWidth: 2) }
        }
        .opacity(dim ? 0.3 : 1)
        .contentShape(.capsule)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(t.name)，\(yearText(t.born)) 至 \(yearText(t.died))")
    }
}

// MARK: - 人物卡片

private struct ThinkerSheet: View {
    let thinker: Thinker

    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(thinker.name)
                            .font(.system(size: 34, weight: .semibold, design: .serif))
                            .foregroundStyle(Color.primary)
                        Text("\(thinker.region.title) · \(thinker.approx ? "约" : "")\(yearText(thinker.born))–\(yearText(thinker.died))\(thinker.approx ? "（生卒年说法不一）" : "")")
                            .font(.subheadline).foregroundStyle(Color.primary.opacity(0.6))
                        Text(thinker.thesis)
                            .font(.title3).foregroundStyle(Color.primary)
                            .padding(18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.regular, in: .rect(cornerRadius: 22))
                        relations
                        if let pid = thinker.libraryId, let p = library.first(where: { $0.id == pid }) {
                            Text("深度内容").font(.headline).foregroundStyle(Color.primary).padding(.top, 6)
                            ForEach(p.books) { b in
                                NavigationLink {
                                    BookView(book: b)
                                } label: {
                                    Label("《\(b.title)》 · \(b.chapters.count) 章", systemImage: "book.closed")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(14)
                                        .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if let works = thinkerWorks[thinker.id] {
                            Text("全文").font(.headline).foregroundStyle(Color.primary).padding(.top, 6)
                            ForEach(works) { b in
                                NavigationLink {
                                    BookReaderView(book: b)
                                } label: {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Label("《\(b.title)》", systemImage: "text.book.closed").font(.body.weight(.semibold))
                                        Text("\(b.year) · \(b.summary)").font(.caption).foregroundStyle(Color.primary.opacity(0.6))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if thinker.libraryId == nil {
                            Text(thinkerWorks[thinker.id] == nil
                                 ? "暂无可用的公有领域全文；章节动画将逐步加入。"
                                 : "章节动画与三语原文将逐步加入。")
                                .font(.footnote).foregroundStyle(Color.primary.opacity(0.5))
                        }
                    }
                    .padding(20)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private var relations: some View {
        let from = influences.filter { $0.to == thinker.id }.compactMap { i in thinkers.first { $0.id == i.from }.map { ($0, i.critical) } }
        let to = influences.filter { $0.from == thinker.id }.compactMap { i in thinkers.first { $0.id == i.to }.map { ($0, i.critical) } }
        if !from.isEmpty || !to.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                if !from.isEmpty {
                    Text("思想来源：" + from.map { $0.0.name + ($0.1 ? "（批判继承）" : "") }.joined(separator: "、"))
                }
                if !to.isEmpty {
                    Text("影响了：" + to.map { $0.0.name + ($0.1 ? "（批判继承）" : "") }.joined(separator: "、"))
                }
            }
            .font(.subheadline).foregroundStyle(Color.primary.opacity(0.8))
        }
    }
}

// MARK: - 时间轴人物的著作全文（只收公有领域版本）

private func work(_ id: String, _ title: String, _ original: String, _ year: String, _ summary: String) -> Book {
    Book(id: id, title: title, original: original, year: year, summary: summary,
         parts: workParts(id), chapters: workChapters[id] ?? [])
}

let thinkerWorks: [String: [Book]] = [
    "euclid": [work("euclid", "几何原本", "Στοιχεῖα（Elements）", "约前 300 年",
                    "十三卷，从 23 条定义、5 条公设、5 条公理推出全部命题。收利玛窦、徐光启 1607 年中译前六卷，以及 Casey 1885 年英译前六卷。")],
    "archimedes": [work("archimedes", "方法", "Περὶ μηχανικῶν θεωρημάτων（The Method）", "约前 250 年",
                    "致埃拉托色尼的信：先用杠杆原理“称”出结果，再以几何证明。1906 年在一部羊皮纸重写本中被重新发现。收 1909 年英译本。")],
    "zhaoshuang": [work("zhoubi", "周髀算经", "周髀算經（四部丛刊本）", "约西汉成书 / 三国赵爽注",
                    "商高论勾股、陈子论日影与盖天说。附赵爽注、甄鸾重述、李淳风等注释。")],
    "newton": [work("principia", "自然哲学的数学原理", "Philosophiæ Naturalis Principia Mathematica", "1687",
                    "定义、运动定律，卷一论物体在无阻力空间中的运动，卷二论有阻力介质中的运动，卷三“宇宙体系”推出万有引力。收 1687 年伦敦初版拉丁文全文。")],
    "descartes-geometry": [work("geometrie", "几何学", "La Géométrie", "1637",
                    "《谈谈方法》的附录之一：把几何作图化为代数运算，用方程研究曲线。法文原文。")],
    "liuhui": [work("jiuzhang", "九章算术", "九章算術（四部丛刊本）", "约东汉成书 / 263 年刘徽注",
                    "246 道应用题，分方田、粟米、衰分、少广、商功、均输、盈不足、方程、句股九章。附刘徽注、李淳风等注释。")],
    "kongzi": [work("lunyu", "论语", "論語", "春秋末至战国初", "孔子及其弟子的言行录。原文 + 理雅各（Legge）英译。")],
    "laozi": [work("daodejing", "道德经", "道德經", "约战国", "五千言，八十一章。原文 + 理雅各英译。")],
    "zhuangzi": [work("zhuangzi", "庄子", "Chuang Tzu (tr. Giles)", "战国", "原文全文（漢籍リポジトリ）+ 翟理斯（Giles）1889 年英译。")],
    "mengzi": [work("mengzi", "孟子", "孟子", "战国", "性善、四端、仁政、民贵君轻。原文全文。")],
    "hanfei": [work("hanfeizi", "韩非子", "韓非子（四庫本）", "战国末", "法、术、势；二柄；以法为教。四库全书本原文（无标点）。")],
    "zhuxi": [work("zhuziyulei", "朱子语类", "朱子語類（四庫本）", "1270 年编成", "朱熹与弟子的问答，共 140 卷：理气、性理、为学、四书。四库全书本原文（无标点），分四册。")],
    "mozi": [work("mozi", "墨子", "墨子", "战国", "兼爱、非攻、尚贤、节用，以及墨辩。")],
    "xunzi": [work("xunzi", "荀子集解", "荀子集解（王先謙）", "战国 / 清代集解", "《荀子》原文与王先谦集解（1891）。")],
    "dongzhongshu": [work("chunqiufanlu", "春秋繁露", "春秋繁露", "西汉", "以阴阳五行解释《春秋》，提出天人感应。")],
    "huineng": [work("tanjing", "六祖坛经", "六祖大師法寶壇經", "唐", "慧能说法，弟子法海集录。")],
    "wangyangming": [work("chuanxilu", "传习录", "傳習錄", "明", "王阳明与弟子的问答语录。")],
    "socrates": [work("apology", "申辩篇", "Apology (Plato, tr. Jowett)", "约前 399 年后", "柏拉图记述的苏格拉底受审答辩。乔伊特英译。")],
    "plato": [work("republic", "理想国", "The Republic (tr. Jowett)", "约前 375 年", "正义、理念与洞穴之喻。乔伊特英译。"),
              work("phaedo", "斐多", "Phaedo (tr. Jowett)", "约前 380 年", "苏格拉底临终论灵魂不朽。乔伊特英译。"),
              work("symposium", "会饮", "Symposium (tr. Jowett)", "约前 385 年", "论爱：从美的身体上升到美本身。乔伊特英译。")],
    "augustine": [work("confessions", "忏悔录", "The Confessions (tr. Pusey)", "约 400 年", "包含著名的时间之问。蒲赛英译。")],
    "descartes": [
        work("discourse", "谈谈方法", "Discourse on the Method (tr. Veitch)", "1637", "“我思故我在”首次出现于此。维奇英译。"),
        work("meditationes", "第一哲学沉思集", "Meditationes de prima philosophia", "1641", "拉丁文原文。"),
    ],
    "spinoza": [work("ethics", "伦理学", "Ethics (tr. Elwes)", "1677", "按几何学方式证明。埃尔维斯英译。")],
    "hume": [work("enquiry", "人类理解研究", "An Enquiry Concerning Human Understanding", "1748", "因果、习惯与归纳问题。英文原著。")],
    "aristotle": [work("nicomachean", "尼各马可伦理学", "The Ethics of Aristotle (tr. Chase)", "约前 4 世纪", "幸福、德性与中道。蔡斯（Chase）1847 年英译。"),
                  work("politics", "政治学", "Politics (tr. Ellis)", "约前 4 世纪", "人是政治的动物。埃利斯英译。")],
    "aquinas": [work("summa", "神学大全（第一集）", "Summa Theologica, Part I", "1265–1274", "包含证明上帝存在的“五路”。多明我会英译。")],
    "leibniz": [work("monadologie", "单子论", "La Monadologie", "1714", "法文原文（皮亚 1909 年校注本）。")],
    "wittgenstein": [work("tractatus", "逻辑哲学论", "Logisch-philosophische Abhandlung", "1921", "德文原文，526 条编号命题。")],
    "zhouyi": [work("zhouyi", "周易", "周易", "西周", "六十四卦经文与彖、象、文言。原文（漢籍リポジトリ）。")],
    "guanzhong": [work("guanzi", "管子", "管子（四部丛刊本）", "春秋至战国", "原文，无标点。")],
    "sunwu": [work("sunzi", "孙子兵法", "孫子（四庫本）", "春秋末", "原文，无标点。")],
    "zisi": [work("liji", "礼记", "禮記", "战国至汉", "含《大学》《中庸》等四十九篇。原文。")],
    "liezi": [work("liezi", "列子", "列子", "战国（成书较晚）", "原文。")],
    "gongsunlong": [work("gongsunlong", "公孙龙子", "公孫龍子（四庫本）", "战国", "白马论、指物论、坚白论等。原文，无标点。")],
    "wangchong": [work("lunheng", "论衡", "論衡（四部丛刊本）", "东汉", "原文，无标点。")],
    "zhoudunyi": [work("zhouyuangong", "周元公集", "周元公集（四庫本）", "北宋", "含《太极图说》《通书》。原文，无标点。")],
    "zhangzai": [work("zhangzi", "张子全书", "張子全書（四庫本）", "北宋", "含《西铭》《正蒙》。原文，无标点。")],
    "ercheng": [work("ercheng", "二程遗书", "二程遺書（四庫本）", "北宋", "程颢、程颐语录。原文，无标点。")],
    "luxiangshan": [work("xiangshan", "象山集", "象山集（四部丛刊本）", "南宋", "原文，无标点。")],
    "guyanwu": [work("rizhilu", "日知录", "日知錄（四庫本）", "清初", "原文，无标点。")],
    "lucretius": [work("lucretius", "物性论", "De Rerum Natura (tr. Leonard)", "前 1 世纪", "用原子论解释世界。伦纳德英译。")],
    "epictetus": [work("enchiridion", "手册", "Enchiridion (tr. Higginson)", "约 125", "斯多葛派的人生手册。希金森英译。")],
    "marcusaurelius": [work("meditations", "沉思录", "Meditations (tr. Casaubon)", "约 170–180", "皇帝写给自己的笔记。卡索邦英译。")],
    "machiavelli": [work("prince", "君主论", "The Prince (tr. Marriott)", "1513", "马里奥特英译。")],
    "hobbes": [work("leviathan", "利维坦", "Leviathan", "1651", "英文原文。")],
    "pascal": [work("pensees", "思想录", "Pensées (tr. Trotter)", "1670", "特罗特英译。")],
    "locke": [work("locke-government", "政府论（下篇）", "Second Treatise of Government", "1689", "英文原文。")],
    "berkeley": [work("berkeley-principles", "人类知识原理", "A Treatise Concerning the Principles of Human Knowledge", "1710", "英文原文。")],
    "rousseau": [work("rousseau-inequality", "论人类不平等的起源", "Discourse on the Origin of Inequality", "1755", "英译。")],
    "schopenhauer": [work("schopenhauer-essays", "叔本华论文集", "Essays of Schopenhauer (tr. Dircks)", "1851", "选自《附录与补遗》。迪克斯英译。")],
    "mill": [work("on-liberty", "论自由", "On Liberty", "1859", "英文原文。"),
             work("utilitarianism", "功利主义", "Utilitarianism", "1863", "英文原文。")],
    "marx": [work("manifesto", "共产党宣言", "Manifesto of the Communist Party", "1848", "穆尔英译（1888，恩格斯审定）。")],
    "james": [work("pragmatism", "实用主义", "Pragmatism", "1907", "英文原文。")],
    "kant": [work("groundwork", "道德形而上学奠基", "Grundlegung zur Metaphysik der Sitten (tr. Abbott)", "1785", "绝对命令。阿博特英译。")],
    "nietzsche": [work("bge", "善恶的彼岸", "Beyond Good and Evil (tr. Zimmern)", "1886", "齐默恩英译。"),
                  work("zarathustra", "查拉图斯特拉如是说", "Also sprach Zarathustra", "1883–1885", "德文原文 + 康芒（Common）英译。")],
]

/// 时间轴人物著作的全文版本
let thinkerFullTexts: [String: [FullText]] = [
    "euclid": [FullText(id: "jihe-zh", label: "徐光启译"), FullText(id: "euclid-en", label: "English")],
    "jiuzhang": [FullText(id: "jiuzhang-zh", label: "原文")],
    "zhoubi": [FullText(id: "zhoubi-zh", label: "原文")],
    "archimedes": [FullText(id: "archimedes-en", label: "English")],
    "geometrie": [FullText(id: "geometrie-fr", label: "Français")],
    "principia": [FullText(id: "principia-la", label: "Latina")],
    "lunyu": [FullText(id: "lunyu-zh", label: "原文"), FullText(id: "lunyu-en", label: "English")],
    "daodejing": [FullText(id: "daodejing-zh", label: "原文"), FullText(id: "daodejing-en", label: "English")],
    "zhuangzi": [FullText(id: "zhuangzi-zh", label: "原文"), FullText(id: "zhuangzi-en", label: "English")],
    "mengzi": [FullText(id: "mengzi-zh", label: "原文")],
    "hanfeizi": [FullText(id: "hanfeizi-zh", label: "原文")],
    "zhuziyulei": [FullText(id: "zhuziyulei-1-zh", label: "卷1–35"), FullText(id: "zhuziyulei-36-zh", label: "卷36–70"),
                   FullText(id: "zhuziyulei-71-zh", label: "卷71–105"), FullText(id: "zhuziyulei-106-zh", label: "卷106–140")],
    "mozi": [FullText(id: "mozi-zh", label: "原文")],
    "xunzi": [FullText(id: "xunzi-zh", label: "原文")],
    "chunqiufanlu": [FullText(id: "chunqiufanlu-zh", label: "原文")],
    "tanjing": [FullText(id: "tanjing-zh", label: "原文")],
    "chuanxilu": [FullText(id: "chuanxilu-zh", label: "原文")],
    "apology": [FullText(id: "apology-en", label: "English")],
    "republic": [FullText(id: "republic-en", label: "English")],
    "confessions": [FullText(id: "confessions-en", label: "English")],
    "discourse": [FullText(id: "discourse-en", label: "English")],
    "meditationes": [FullText(id: "meditationes-la", label: "Latina")],
    "ethics": [FullText(id: "ethics-en", label: "English")],
    "enquiry": [FullText(id: "enquiry-en", label: "English")],
    "zarathustra": [FullText(id: "zarathustra-de", label: "Deutsch"), FullText(id: "zarathustra-en", label: "English")],
    "nicomachean": [FullText(id: "ethics-aristotle-en", label: "English")],
    "summa": [FullText(id: "summa-en", label: "English")],
    "monadologie": [FullText(id: "monadologie-fr", label: "Français")],
    "tractatus": [FullText(id: "tractatus-de", label: "Deutsch")],
    "lucretius": [FullText(id: "lucretius-en", label: "English")],
    "zhouyi": [FullText(id: "zhouyi-zh", label: "原文")],
    "guanzi": [FullText(id: "guanzi-zh", label: "原文")],
    "sunzi": [FullText(id: "sunzi-zh", label: "原文")],
    "liji": [FullText(id: "liji-zh", label: "原文")],
    "liezi": [FullText(id: "liezi-zh", label: "原文")],
    "gongsunlong": [FullText(id: "gongsunlong-zh", label: "原文")],
    "lunheng": [FullText(id: "lunheng-zh", label: "原文")],
    "zhouyuangong": [FullText(id: "zhouyuangong-zh", label: "原文")],
    "zhangzi": [FullText(id: "zhangzi-zh", label: "原文")],
    "ercheng": [FullText(id: "ercheng-zh", label: "原文")],
    "xiangshan": [FullText(id: "xiangshan-zh", label: "原文")],
    "rizhilu": [FullText(id: "rizhilu-zh", label: "原文")],
    "enchiridion": [FullText(id: "enchiridion-en", label: "English")],
    "meditations": [FullText(id: "meditations-en", label: "English")],
    "prince": [FullText(id: "prince-en", label: "English")],
    "leviathan": [FullText(id: "leviathan-en", label: "English")],
    "pensees": [FullText(id: "pensees-en", label: "English")],
    "locke-government": [FullText(id: "locke-government-en", label: "English")],
    "berkeley-principles": [FullText(id: "berkeley-principles-en", label: "English")],
    "rousseau-inequality": [FullText(id: "rousseau-inequality-en", label: "English")],
    "schopenhauer-essays": [FullText(id: "schopenhauer-essays-en", label: "English")],
    "on-liberty": [FullText(id: "on-liberty-en", label: "English")],
    "utilitarianism": [FullText(id: "utilitarianism-en", label: "English")],
    "manifesto": [FullText(id: "manifesto-en", label: "English")],
    "pragmatism": [FullText(id: "pragmatism-en", label: "English")],
    "groundwork": [FullText(id: "groundwork-en", label: "English")],
    "bge": [FullText(id: "bge-en", label: "English")],
    "phaedo": [FullText(id: "phaedo-en", label: "English")],
    "symposium": [FullText(id: "symposium-en", label: "English")],
    "politics": [FullText(id: "politics-en", label: "English")],
]
