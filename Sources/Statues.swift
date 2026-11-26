import SwiftUI
import RealityKit

// MARK: - 有公开原型的 3D 人物雕像：研究记录、状态与加载
//
// 数据在 statues.json：每条记录写明原型作品、作者、年代、机构与编号、来源链接、可对照特征、推定部分、素材使用记录与审核状态。
// 只有“可展示”且模型文件存在的条目才在席位上显示雕像，其余一律显示刻名基座。

struct StatueFeature: Codable, Hashable { let name: String; let state: String }
struct StatueAlt: Codable, Hashable { let work: String; let institution: String; let url: String }
struct StatueUsage: Codable {
    let original: String
    let reference: String
    let existing3D: String
    let license: String
    let attribution: String
    let adapt: String
    let distribute: String
    let thumbnail: String
}
struct StatueRecord: Codable, Identifiable {
    let id: String
    let kind: String
    let kindLabel: String
    let status: String
    let work: String
    let author: String
    let date: String
    let sitterDates: String
    let institution: String
    let accession: String
    let url: String
    let reason: String
    let relation: String
    let features: [StatueFeature]
    let inferred: [String]
    let usage: StatueUsage
    let model: String?
    let pending: [String]
    let alternates: [StatueAlt]

    /// 只有“可展示”、且模型文件真的随 App 打包时才显示雕像
    var modelURL: URL? {
        guard status == "可展示", let model else { return nil }
        return Bundle.main.url(forResource: model, withExtension: "usdz")
    }
}
struct StatueDoc: Codable { let queried: String; let rule: String; let records: [StatueRecord] }

let statueDoc: StatueDoc? = {
    guard let url = Bundle.main.url(forResource: "statues", withExtension: "json"),
          let data = try? Data(contentsOf: url) else { return nil }
    return try? JSONDecoder().decode(StatueDoc.self, from: data)
}()

func statueRecord(_ id: String) -> StatueRecord? { statueDoc?.records.first { $0.id == id } }

/// 运行时计数：正式雕像几尊、刻名席位几席
func statueCount(_ ids: [String]) -> (statues: Int, plaques: Int) {
    let n = ids.filter { statueRecord($0)?.modelURL != nil }.count
    return (n, ids.count - n)
}

/// 异步加载雕像：先显示刻名基座；模型到了再换上。快速切换时，迟到的旧请求不会覆盖新的。
final class StatueLoader {
    static let shared = StatueLoader()
    private var generation: [String: Int] = [:]

    func load(_ id: String, into slot: Entity) {
        guard let url = statueRecord(id)?.modelURL else { return }
        let g = (generation[id] ?? 0) + 1
        generation[id] = g
        Task { @MainActor in
            guard let bust = try? await Entity(contentsOf: url) else { return }   // 文件损坏：保留刻名基座
            guard self.generation[id] == g else { return }                        // 已有更新的请求
            // 统一展示尺度：头肩高约 6 cm，底面落在基座顶面
            let b = bust.visualBounds(relativeTo: nil)
            let s = 0.06 / max(0.001, b.extents.y)
            bust.scale = .init(repeating: s)
            bust.position = [-b.center.x * s, -b.min.y * s, -b.center.z * s]
            slot.children.removeAll()
            slot.addChild(bust)
        }
    }

    func cancel(_ id: String) { generation[id] = (generation[id] ?? 0) + 1 }
}

// MARK: - 查看原型

struct PrototypeSheet: View {
    let record: StatueRecord
    let thinker: Thinker
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Text(record.kindLabel).font(.caption.weight(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .glassEffect(.regular.tint(champagne.opacity(0.3)), in: .capsule)
                        Text(record.status).font(.caption.weight(.semibold))
                            .foregroundStyle(record.status == "可展示" ? Color.green : diamondDeep)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .glassEffect(.regular, in: .capsule)
                    }
                    Text("圆桌席位上目前是卡通示意形象，不依据这件原型，也不代表人物的真实相貌；这件原型完成对照、状态变为“可展示”后，席位会换成考据雕像。")
                        .font(.caption).foregroundStyle(Color.primary.opacity(0.6))
                        .padding(10).background(Color.primary.opacity(0.05), in: .rect(cornerRadius: 12))
                    Text(record.work).font(.system(size: 22, weight: .semibold, design: .serif))
                    VStack(alignment: .leading, spacing: 6) {
                        row("作者", record.author)
                        row("年代", record.date)
                        row("人物", record.sitterDates)
                        row("机构", record.institution)
                        row("编号", record.accession)
                        row("查询日期", statueDoc?.queried ?? "未载")
                    }
                    if let u = URL(string: record.url) {
                        Link(destination: u) {
                            Label("打开馆方藏品页", systemImage: "building.columns")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)
                    }
                    Text("本版不在 App 内嵌入原作图像，请在馆方页面上查看，那里同时载有馆方的图像使用说明。")
                        .font(.caption).foregroundStyle(Color.primary.opacity(0.55))

                    section("模型呈现的是哪一件作品", record.reason)
                    section("这件作品与人物本人的关系", record.relation)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("可对照的造型特征").font(.headline)
                        ForEach(record.features, id: \.self) { f in
                            HStack {
                                Text(f.name).font(.subheadline)
                                Spacer()
                                Text(f.state).font(.caption.weight(.semibold)).foregroundStyle(f.state == "已对照" ? Color.green : diamondDeep)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("推定部分").font(.headline)
                        ForEach(record.inferred, id: \.self) { Text("· " + $0).font(.subheadline).foregroundStyle(Color.primary.opacity(0.8)) }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("素材使用记录").font(.headline)
                        row("原作", record.usage.original)
                        row("参考图像", record.usage.reference)
                        row("现成 3D", record.usage.existing3D)
                        row("许可", record.usage.license)
                        row("署名", record.usage.attribution)
                        row("可否改编", record.usage.adapt)
                        row("可否随 App 分发", record.usage.distribute)
                        row("缩略图展示", record.usage.thumbnail)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("仍缺的证据与待办").font(.headline)
                        ForEach(record.pending, id: \.self) { Text("· " + $0).font(.subheadline).foregroundStyle(Color.primary.opacity(0.8)) }
                    }
                    if !record.alternates.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("其他候选原型").font(.headline)
                            ForEach(record.alternates, id: \.self) { a in
                                if let u = URL(string: a.url) {
                                    Link(destination: u) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(a.work).font(.subheadline.weight(.medium)).multilineTextAlignment(.leading)
                                            Text(a.institution).font(.caption).foregroundStyle(Color.primary.opacity(0.55)).multilineTextAlignment(.leading)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Text(statueDoc?.rule ?? "").font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
                }
                .padding(20)
            }
            .navigationTitle("\(thinker.name) · 原型")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("关闭", systemImage: "xmark") { dismiss() } }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func row(_ k: String, _ v: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(k).font(.footnote).foregroundStyle(Color.primary.opacity(0.55)).frame(width: 88, alignment: .leading)
            Text(v).font(.footnote).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func section(_ t: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t).font(.headline)
            Text(body).font(.subheadline).foregroundStyle(Color.primary.opacity(0.85)).fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - 卡通示意形象：没有合格雕像的席位用它代替（不依据任何原型，不代表人物真实相貌）

enum CartoonStyle: String {
    case sinoAncient = "先秦至汉唐的中国士人：冠与交领袍"
    case sinoLater = "宋明以后的中国学者：幞头与长袍"
    case classical = "古希腊罗马：长袍与胡须"
    case medieval = "中世纪：兜帽长袍"
    case earlyModern = "近代早期：白色假发与外套"
    case modern = "近现代：西装与领带"

    static func of(_ t: Thinker) -> CartoonStyle {
        let chinese = t.region == .china || ["liuhui", "zhaoshuang", "zuchongzhi", "qinjiushao", "liye", "yanghui", "zhushijie", "xuguangqi", "meiwending"].contains(t.id)
        if chinese { return t.born < 900 ? .sinoAncient : .sinoLater }
        switch t.born {
        case ..<500: return .classical
        case ..<1500: return .medieval
        case ..<1760: return .earlyModern
        default: return .modern
        }
    }
}

/// 共享网格与材质：82 个小人只建一份
private enum Toy {
    static func m(_ c: UIColor, rough: Float = 0.6) -> PhysicallyBasedMaterial {
        var x = PhysicallyBasedMaterial()
        x.baseColor = .init(tint: c)
        x.roughness = .init(floatLiteral: rough)
        x.metallic = .init(floatLiteral: 0)
        return x
    }
    static let skin = m(UIColor(red: 0.98, green: 0.86, blue: 0.74, alpha: 1), rough: 0.5)
    static let black = m(UIColor(white: 0.12, alpha: 1), rough: 0.4)
    static let white = m(UIColor(white: 0.96, alpha: 1), rough: 0.7)
    static let grey = m(UIColor(white: 0.62, alpha: 1))
    static let blush = m(UIColor(red: 1, green: 0.62, blue: 0.62, alpha: 1))
    static let head = MeshResource.generateSphere(radius: 0.0085)
    static let eye = MeshResource.generateSphere(radius: 0.0011)
    static let cheek = MeshResource.generateSphere(radius: 0.0016)
    static let robe = MeshResource.generateCone(height: 0.026, radius: 0.0115)
    static let suit = MeshResource.generateBox(size: [0.017, 0.022, 0.012], cornerRadius: 0.005)
}

func cartoonFigure(for t: Thinker) -> Entity {
    let fig = Entity()
    fig.name = "cartoon"
    let style = CartoonStyle.of(t)
    func add(_ mesh: MeshResource, _ mat: any RealityKit.Material, _ p: SIMD3<Float>, scale: SIMD3<Float> = .one, flip: Bool = false) {
        let e = ModelEntity(mesh: mesh, materials: [mat])
        e.position = p
        e.scale = scale
        if flip { e.orientation = simd_quatf(angle: .pi, axis: [1, 0, 0]) }
        fig.addChild(e)
    }
    // 身体
    let headY: Float = style == .modern ? 0.030 : 0.034
    switch style {
    case .modern:
        add(Toy.suit, Toy.m(UIColor(red: 0.22, green: 0.25, blue: 0.32, alpha: 1)), [0, 0.011, 0])
        add(.generateBox(size: [0.006, 0.006, 0.002]), Toy.white, [0, 0.019, 0.0058])
        add(.generateBox(size: [0.0022, 0.009, 0.0015]), Toy.m(UIColor(red: 0.7, green: 0.18, blue: 0.2, alpha: 1)), [0, 0.016, 0.0066])
    case .classical:
        add(Toy.robe, Toy.white, [0, 0.013, 0])
        add(.generateBox(size: [0.003, 0.022, 0.0015]), Toy.m(UIColor(red: 0.62, green: 0.25, blue: 0.22, alpha: 1)), [0.002, 0.014, 0.0062])
    case .medieval:
        add(Toy.robe, Toy.m(UIColor(red: 0.42, green: 0.3, blue: 0.22, alpha: 1)), [0, 0.013, 0])
    case .earlyModern:
        add(Toy.robe, Toy.m(UIColor(red: 0.2, green: 0.24, blue: 0.42, alpha: 1)), [0, 0.013, 0])
        add(.generateBox(size: [0.005, 0.004, 0.002]), Toy.white, [0, 0.023, 0.0045])
    case .sinoAncient, .sinoLater:
        let robeColor = style == .sinoAncient ? UIColor(red: 0.55, green: 0.42, blue: 0.62, alpha: 1) : UIColor(red: 0.3, green: 0.45, blue: 0.55, alpha: 1)
        add(Toy.robe, Toy.m(robeColor), [0, 0.013, 0])
        add(.generateBox(size: [0.012, 0.0015, 0.004]), Toy.m(UIColor(red: 0.85, green: 0.7, blue: 0.35, alpha: 1)), [0, 0.012, 0.0055])
    }
    // 头与脸（大头、圆眼、腮红）
    add(Toy.head, Toy.skin, [0, headY, 0])
    add(Toy.eye, Toy.black, [-0.003, headY + 0.0008, 0.0078])
    add(Toy.eye, Toy.black, [0.003, headY + 0.0008, 0.0078])
    add(Toy.cheek, Toy.blush, [-0.0048, headY - 0.0022, 0.0068], scale: [1, 0.6, 0.4])
    add(Toy.cheek, Toy.blush, [0.0048, headY - 0.0022, 0.0068], scale: [1, 0.6, 0.4])
    // 头饰与发型
    switch style {
    case .modern:
        add(.generateSphere(radius: 0.0088), Toy.grey, [0, headY + 0.0022, -0.0012], scale: [1, 0.7, 1])
    case .classical:
        add(.generateSphere(radius: 0.0088), Toy.grey, [0, headY + 0.0025, -0.001], scale: [1.02, 0.65, 1])
        add(.generateSphere(radius: 0.0055), Toy.grey, [0, headY - 0.0065, 0.004], scale: [1, 0.9, 0.6])   // 胡须
    case .medieval:
        add(.generateSphere(radius: 0.0102), Toy.m(UIColor(red: 0.35, green: 0.25, blue: 0.18, alpha: 1)), [0, headY + 0.001, -0.0025])
    case .earlyModern:
        add(.generateSphere(radius: 0.009), Toy.white, [0, headY + 0.0025, -0.0012], scale: [1.03, 0.7, 1])
        add(.generateSphere(radius: 0.0032), Toy.white, [-0.0082, headY - 0.001, -0.001])
        add(.generateSphere(radius: 0.0032), Toy.white, [0.0082, headY - 0.001, -0.001])
        add(.generateBox(size: [0.002, 0.007, 0.002]), Toy.black, [0, headY - 0.004, -0.0088])     // 发辫
    case .sinoAncient:
        add(.generateBox(size: [0.007, 0.008, 0.009], cornerRadius: 0.0015), Toy.black, [0, headY + 0.0105, -0.0005])   // 冠
        add(.generateCone(height: 0.009, radius: 0.0035), Toy.black, [0, headY - 0.0105, 0.0055], scale: [1, 1, 0.6], flip: true)  // 长须
    case .sinoLater:
        add(.generateSphere(radius: 0.0088), Toy.black, [0, headY + 0.0028, -0.0008], scale: [1.02, 0.75, 1])   // 幞头
        add(.generateBox(size: [0.022, 0.0015, 0.003]), Toy.black, [0, headY + 0.003, -0.006])                  // 展脚
    }
    // 个别人物的小道具
    if t.id == "russell" {
        add(.generateCylinder(height: 0.006, radius: 0.0006), Toy.black, [0.0035, headY - 0.0035, 0.0105])
        add(.generateCylinder(height: 0.003, radius: 0.0016), Toy.m(UIColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1)), [0.0055, headY - 0.0045, 0.0128])
    }
    return fig
}

/// 席位上的说明：卡通还是考据雕像
func seatDisclaimer(_ id: String) -> String {
    if statueRecord(id)?.modelURL != nil { return "考据雕像" }
    guard let t = thinkers.first(where: { $0.id == id }) else { return "" }
    return "卡通示意 · \(CartoonStyle.of(t).rawValue) · 不代表真实相貌"
}
