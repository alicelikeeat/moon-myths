import SwiftUI

// MARK: - 实体书版本：初版书影（Wikimedia Commons）与古籍 / 旧版扫描（Internet Archive）
// 只收公有领域或开放授权的图像；扫描本均为 1930 年以前的出版物或古籍。

struct EditionImage: Codable, Hashable {
    let file: String
    let thumb: String
    let caption: String
    let license: String

    var thumbURL: URL? { URL(string: thumb) }
    var pageURL: URL? {
        URL(string: "https://commons.wikimedia.org/wiki/File:" + (file.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? file))
    }
}

struct EditionScan: Codable, Hashable {
    let ia: String
    let caption: String
    let title: String
    let publisher: String
    let pdf: String?
    let img: String?
    let kind: String?

    var coverURL: URL? { URL(string: img ?? "https://archive.org/services/img/\(ia)") }
    var detailsURL: URL? { URL(string: "https://archive.org/details/\(ia)") }
    var pdfURL: URL? {
        guard let pdf, let name = pdf.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return nil }
        return URL(string: "https://archive.org/download/\(ia)/\(name)")
    }
}

struct BookEditions: Codable {
    let images: [EditionImage]
    let scans: [EditionScan]
    var isEmpty: Bool { images.isEmpty && scans.isEmpty }
}

let bookEditions: [String: BookEditions] = {
    guard let url = Bundle.main.url(forResource: "editions", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let map = try? JSONDecoder().decode([String: BookEditions].self, from: data) else { return [:] }
    return map
}()

struct EditionsSection: View {
    let editions: BookEditions
    @State private var viewing: EditionImage?
    @State private var scan: EditionScan?
    @Namespace private var zoom

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("实体书版本")
                .font(.footnote.weight(.semibold)).foregroundStyle(Color.primary.opacity(0.6))
                .padding(.top, 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(editions.images, id: \.self) { img in
                        Button { viewing = img } label: {
                            EditionCard(url: img.thumbURL, caption: img.caption, source: "Wikimedia Commons · \(img.license)", badge: "书影")
                        }
                        .buttonStyle(PressCardStyle())
                        .matchedTransitionSource(id: img.file, in: zoom)
                    }
                    ForEach(editions.scans, id: \.self) { s in
                        // 不用 Menu：菜单在横向滚动条里展开时卡片会先消失、再从别处冒出来，很突兀。
                        // 改成点开后从卡片放大成详情页，里面再选“在线翻阅”或“下载 PDF”。
                        Button { scan = s } label: {
                            EditionCard(url: s.coverURL, caption: s.caption,
                                        source: "Internet Archive" + (s.publisher.isEmpty ? "" : " · \(s.publisher)"), badge: "扫描本 · \(s.kind ?? "封面")")
                        }
                        .buttonStyle(PressCardStyle())
                        .matchedTransitionSource(id: s.ia, in: zoom)
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
            Text("图像与扫描本来自公共馆藏，均为公有领域或开放授权；点开可看大图、出处，扫描本可在线翻阅或下载 PDF。")
                .font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
        }
        .sheet(item: $viewing) { img in
            EditionViewer(image: img).navigationTransition(.zoom(sourceID: img.file, in: zoom))
        }
        .sheet(item: $scan) { s in
            ScanViewer(scan: s).navigationTransition(.zoom(sourceID: s.ia, in: zoom))
        }
    }
}

/// 卡片按下时轻轻缩小，松手弹回
private struct PressCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(duration: 0.25, bounce: 0.35), value: configuration.isPressed)
    }
}

extension EditionScan: Identifiable { var id: String { ia } }

/// 扫描本详情：大图 + 出处 + 在线翻阅 / 下载 PDF
private struct ScanViewer: View {
    let scan: EditionScan
    @Environment(\.dismiss) private var dismiss

    private var big: URL? { scan.coverURL.flatMap { URL(string: $0.absoluteString.replacingOccurrences(of: "_w400", with: "_w800")) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    AsyncImage(url: big, transaction: Transaction(animation: .easeOut(duration: 0.35))) { phase in
                        switch phase {
                        case .success(let image): image.resizable().scaledToFit().transition(.opacity)
                        case .failure:
                            AsyncImage(url: scan.coverURL) { $0.resizable().scaledToFit() } placeholder: { ProgressView() }
                        default: ProgressView().frame(maxWidth: .infinity, minHeight: 320)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 14))
                    Text(scan.caption).font(.headline)
                    Text(scan.title).font(.subheadline).foregroundStyle(.secondary)
                    if !scan.publisher.isEmpty {
                        Text(scan.publisher).font(.caption).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 10) {
                        if let u = scan.detailsURL {
                            Link(destination: u) { Label("在线翻阅", systemImage: "book.pages").frame(maxWidth: .infinity) }
                                .buttonStyle(.glassProminent)
                        }
                        if let u = scan.pdfURL {
                            Link(destination: u) { Label("下载 PDF", systemImage: "arrow.down.doc").frame(maxWidth: .infinity) }
                                .buttonStyle(.glass)
                        }
                    }
                    .controlSize(.large)
                    Text("来源：Internet Archive（\(scan.ia)）").font(.caption2).foregroundStyle(.tertiary)
                }
                .padding(20)
            }
            .navigationTitle("扫描本").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成", systemImage: "checkmark") { dismiss() } } }
        }
    }
}

extension EditionImage: Identifiable { var id: String { file } }

private struct EditionCard: View {
    let url: URL?
    let caption: String
    let source: String
    let badge: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                case .failure: Image(systemName: "book.closed").font(.title).foregroundStyle(.secondary)
                default: ProgressView()
                }
            }
            .frame(width: 132, height: 176)
            .clipped()
            .background(Color.primary.opacity(0.05))
            .clipShape(.rect(cornerRadius: 12))
            .overlay(alignment: .topLeading) {
                Text(badge).font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6).padding(.vertical, 3)
                    .glassEffect(.regular, in: .capsule)
                    .padding(6)
            }
            Text(caption).font(.caption).foregroundStyle(Color.primary.opacity(0.85))
                .lineLimit(3).multilineTextAlignment(.leading)
            Text(source).font(.caption2).foregroundStyle(Color.primary.opacity(0.45)).lineLimit(1)
        }
        .frame(width: 132)
        .padding(8)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }
}

private struct EditionViewer: View {
    let image: EditionImage
    @Environment(\.dismiss) private var dismiss

    var big: URL? { URL(string: image.thumb.replacingOccurrences(of: "/600px-", with: "/1280px-")) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    AsyncImage(url: big) { phase in
                        if let img = phase.image { img.resizable().scaledToFit() }
                        else if phase.error != nil {
                            AsyncImage(url: image.thumbURL) { $0.resizable().scaledToFit() } placeholder: { ProgressView() }
                        } else { ProgressView().frame(maxWidth: .infinity, minHeight: 300) }
                    }
                    .clipShape(.rect(cornerRadius: 12))
                    Text(image.caption).font(.headline)
                    Text("文件：\(image.file)\n授权：\(image.license)").font(.caption).foregroundStyle(.secondary)
                    if let u = image.pageURL {
                        Link(destination: u) { Label("在 Wikimedia Commons 查看出处", systemImage: "arrow.up.right.square") }
                            .buttonStyle(.glass)
                    }
                }
                .padding(20)
            }
            .navigationTitle("书影").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成", systemImage: "checkmark") { dismiss() } } }
        }
    }
}
