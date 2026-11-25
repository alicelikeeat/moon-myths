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

    var coverURL: URL? { URL(string: "https://archive.org/services/img/\(ia)") }
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
                        .buttonStyle(.plain)
                    }
                    ForEach(editions.scans, id: \.self) { s in
                        Menu {
                            if let u = s.detailsURL { Link(destination: u) { Label("在线翻阅扫描本", systemImage: "book.pages") } }
                            if let u = s.pdfURL { Link(destination: u) { Label("下载 PDF", systemImage: "arrow.down.doc") } }
                        } label: {
                            EditionCard(url: s.coverURL, caption: s.caption,
                                        source: "Internet Archive" + (s.publisher.isEmpty ? "" : " · \(s.publisher)"), badge: "扫描本")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollClipDisabled()
            Text("图像与扫描本来自公共馆藏，均为公有领域或开放授权；点开书影可看大图和出处。")
                .font(.caption2).foregroundStyle(Color.primary.opacity(0.45))
        }
        .sheet(item: $viewing) { img in EditionViewer(image: img) }
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
