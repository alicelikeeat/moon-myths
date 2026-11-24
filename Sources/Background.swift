import SwiftUI
import PhotosUI

enum BackdropStyle: String, CaseIterable, Identifiable {
    case glow, aurora, dusk, black, photo
    var id: String { rawValue }
    var title: String {
        switch self {
        case .glow: return "柔光"
        case .aurora: return "极光"
        case .dusk: return "暮色"
        case .black: return "纯色"
        case .photo: return "我的照片"
        }
    }
    /// 三团漂移光斑的颜色与强度
    var lights: [Color] {
        switch self {
        case .glow: return [Moon.silver, Moon.violet, Moon.gold]
        case .aurora: return [Color(red: 0.2, green: 0.9, blue: 0.75), Color(red: 0.35, green: 0.45, blue: 1.0), Color(red: 0.85, green: 0.35, blue: 0.95)]
        case .dusk: return [Color(red: 1.0, green: 0.55, blue: 0.35), Color(red: 0.95, green: 0.35, blue: 0.55), Color(red: 0.4, green: 0.35, blue: 0.9)]
        case .black, .photo: return []
        }
    }
    var intensity: Double {
        switch self {
        case .glow: return 0.17
        case .aurora, .dusk: return 0.42
        default: return 0
        }
    }
}

/// 自定义背景照片：存放在 App 的 Documents 目录
final class PhotoBackground {
    static let shared = PhotoBackground()
    private(set) var image: UIImage?
    private let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("background.jpg")

    private init() { image = UIImage(contentsOfFile: url.path) }

    func save(_ data: Data) -> Bool {
        guard let img = UIImage(data: data) else { return false }
        let maxSide: CGFloat = 2000
        let scale = min(1, maxSide / max(img.size.width, img.size.height))
        let size = CGSize(width: img.size.width * scale, height: img.size.height * scale)
        let resized = UIGraphicsImageRenderer(size: size).image { _ in img.draw(in: CGRect(origin: .zero, size: size)) }
        guard let jpg = resized.jpegData(compressionQuality: 0.85) else { return false }
        do { try jpg.write(to: url, options: .atomic) } catch { return false }
        image = resized
        return true
    }
}

struct Backdrop: View {
    @AppStorage("backdropStyle") private var styleRaw = BackdropStyle.glow.rawValue
    @AppStorage("backdropDim") private var dim = 0.35
    @AppStorage("backdropPhotoVersion") private var photoVersion = 0

    var body: some View {
        let style = BackdropStyle(rawValue: styleRaw) ?? .glow
        ZStack {
            Moon.bg
            switch style {
            case .photo:
                if let img = PhotoBackground.shared.image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .id(photoVersion)
                }
            case .black:
                Moon.bg
            default:
                DriftingLights(colors: style.lights, intensity: style.intensity)
            }
            Moon.bg.opacity(dim)
        }
        .ignoresSafeArea()
    }
}

private struct DriftingLights: View {
    let colors: [Color]
    let intensity: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let w = Double(size.width), h = Double(size.height)
                let anchors: [(Double, Double, Double)] = [(0.25, 0.2, 0.0), (0.8, 0.45, 2.1), (0.4, 0.8, 4.2)]
                for (i, c) in colors.enumerated() where i < anchors.count {
                    let (bx, by, ph) = anchors[i]
                    let x = w * bx + sin(t * 0.13 + ph) * w * 0.15
                    let y = h * by + cos(t * 0.11 + ph) * h * 0.08
                    let r = w * 0.75
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                             with: .radialGradient(Gradient(colors: [c.opacity(intensity), c.opacity(0)]),
                                                   center: CGPoint(x: x, y: y), startRadius: 0, endRadius: r))
                }
            }
        }
    }
}

// MARK: - 设置面板

struct BackdropSettings: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("backdropStyle") private var styleRaw = BackdropStyle.glow.rawValue
    @AppStorage("backdropDim") private var dim = 0.35
    @AppStorage("backdropPhotoVersion") private var photoVersion = 0
    @AppStorage("appearance") private var appearance = "dark"
    @State private var pick: PhotosPickerItem?
    @State private var failed = false

    var body: some View {
        NavigationStack {
            Form {
                Section("模式") {
                    Picker("模式", selection: $appearance) {
                        Text("深色").tag("dark")
                        Text("白底黑字").tag("light")
                        Text("跟随系统").tag("system")
                    }
                    .pickerStyle(.segmented)
                }
                Section("背景") {
                    Picker("样式", selection: $styleRaw) {
                        ForEach(BackdropStyle.allCases) { s in
                            Text(s.title).tag(s.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()

                    PhotosPicker(selection: $pick, matching: .images) {
                        Label(PhotoBackground.shared.image == nil ? "从相册选择照片" : "更换照片",
                              systemImage: "photo.on.rectangle")
                    }
                    if failed {
                        Text("这张照片无法读取，换一张试试。").font(.footnote).foregroundStyle(.secondary)
                    }
                }
                Section {
                    Slider(value: $dim, in: 0...0.8) {
                        Text("暗度")
                    } minimumValueLabel: {
                        Image(systemName: "sun.max")
                    } maximumValueLabel: {
                        Image(systemName: "moon")
                    }
                } header: {
                    Text("暗度")
                } footer: {
                    Text("背景越亮、越有色彩，玻璃的折射越明显；调暗可以让文字更清楚。")
                }
                Section {
                    ForEach(library.flatMap(\.books) + thinkerWorks.values.flatMap { $0 }) { b in
                        ForEach(fullTexts[b.id] ?? []) { ft in
                            OfflineRow(title: "《\(b.title)》\(ft.label)", id: ft.id)
                        }
                    }
                } header: {
                    Text("离线全文")
                } footer: {
                    Text("全文第一次打开时下载，之后可离线阅读。")
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("外观")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成", systemImage: "checkmark") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .onChange(of: pick) { _, item in
            guard let item else { return }
            Task {
                let data = try? await item.loadTransferable(type: Data.self)
                await MainActor.run {
                    if let data, PhotoBackground.shared.save(data) {
                        failed = false
                        photoVersion += 1
                        styleRaw = BackdropStyle.photo.rawValue
                    } else {
                        failed = true
                    }
                }
            }
        }
    }
}


private struct OfflineRow: View {
    let title: String
    let id: String
    @State private var downloaded = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if downloaded {
                Button("删除", role: .destructive) {
                    TextStore.shared.delete(id)
                    downloaded = false
                }
                .buttonStyle(.glass)
            } else {
                Text("未下载").foregroundStyle(.secondary)
            }
        }
        .onAppear { downloaded = TextStore.shared.isDownloaded(id) }
    }
}
