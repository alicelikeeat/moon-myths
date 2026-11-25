import SwiftUI
import Observation
import Translation

/// 用 Apple 设备端翻译逐段翻译全文；读到哪段翻哪段，结果缓存到本地。
@Observable
@MainActor
final class Translator {
    let target: String                  // "zh" 或 "en"
    private(set) var cache: [Int: String] = [:]
    private var pending: [Int: String] = [:]
    var config: TranslationSession.Configuration?
    private(set) var failed: String?
    /// 语言包还没下载：显示“下载语言包”按钮，而不是自动反复弹窗
    private(set) var needsDownload = false
    private var textId = ""
    private var source: Locale.Language?
    private var scheduled = false

    init(target: String) { self.target = target }

    private static func language(_ code: String, source: Bool) -> Locale.Language {
        switch code {
        case "zh": return Locale.Language(identifier: source ? "zh-Hant" : "zh-Hans")
        default: return Locale.Language(identifier: code)
        }
    }

    private static func name(_ code: String) -> String {
        ["en": "英语", "de": "德语", "fr": "法语", "la": "拉丁语", "zh": "中文"][code] ?? code
    }

    func setup(textId: String, sourceLang: String) {
        guard self.textId != textId else { return }
        self.textId = textId
        cache = Self.load(textId, target)
        failed = nil
        needsDownload = false
        config = nil
        if sourceLang == target { return }
        if sourceLang == "la" {
            failed = "Apple 翻译暂不支持拉丁文，这本书只能阅读原文。"
            return
        }
        let src = Self.language(sourceLang, source: true), dst = Self.language(target, source: false)
        source = src
        let pair = "\(Self.name(sourceLang)) → \(Self.name(target))"
        Task { @MainActor in
            let status = await LanguageAvailability().status(from: src, to: dst)
            guard self.textId == textId else { return }
            switch status {
            case .installed:
                start()
            case .supported:
                needsDownload = true
                failed = "需要先下载“\(pair)”离线语言包（只需一次）。"
            case .unsupported:
                failed = "这台设备不支持“\(pair)”的设备端翻译。"
            @unknown default:
                start()
            }
        }
    }

    private func start() {
        guard let src = source else { return }
        config = TranslationSession.Configuration(source: src, target: Self.language(target, source: false))
    }

    /// 用户点“下载语言包”或“重试”：重新建立会话，系统会弹出下载窗口
    func retry() {
        failed = nil
        needsDownload = false
        if config == nil { start() } else { config?.invalidate() }
    }

    func text(for id: Int) -> String? { cache[id] }

    func request(_ id: Int, _ text: String) {
        guard cache[id] == nil, pending[id] == nil else { return }
        pending[id] = text
        guard config != nil, failed == nil, !scheduled else { return }
        scheduled = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            scheduled = false
            if failed == nil { config?.invalidate() }          // 触发 translationTask 重新运行
        }
    }

    func run(_ session: TranslationSession) async {
        guard failed == nil else { return }
        do {
            try await session.prepareTranslation()
        } catch {
            // 用户关掉了下载窗口：停在这里，等用户再点按钮，不再反复弹窗
            needsDownload = true
            failed = "语言包还没有下载完成，翻译暂时不可用。"
            return
        }
        while !pending.isEmpty {
            let batch = Array(pending.prefix(10))
            for (id, _) in batch { pending[id] = nil }
            let requests = batch.map { TranslationSession.Request(sourceText: $0.value, clientIdentifier: String($0.key)) }
            do {
                let responses = try await session.translations(from: requests)
                for r in responses {
                    if let s = r.clientIdentifier, let id = Int(s) { cache[id] = r.targetText }
                }
            } catch {
                for (id, text) in batch { pending[id] = text }   // 留着，重试时再翻
                needsDownload = true
                failed = "翻译没有成功，通常是离线语言包还没下载好。"
                return
            }
        }
        Self.save(textId, target, cache)
    }

    // MARK: 缓存

    private static func file(_ id: String, _ target: String) -> URL {
        let d = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("translations", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d.appendingPathComponent("\(id)-\(target).json")
    }

    private static func load(_ id: String, _ target: String) -> [Int: String] {
        guard let data = try? Data(contentsOf: file(id, target)),
              let raw = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
        var out: [Int: String] = [:]
        for (k, v) in raw { if let i = Int(k) { out[i] = v } }
        return out
    }

    private static func save(_ id: String, _ target: String, _ cache: [Int: String]) {
        var raw: [String: String] = [:]
        for (k, v) in cache { raw[String(k)] = v }
        if let data = try? JSONEncoder().encode(raw) { try? data.write(to: file(id, target), options: .atomic) }
    }
}
