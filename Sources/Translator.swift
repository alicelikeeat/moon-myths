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
    private var textId = ""
    private var scheduled = false

    init(target: String) { self.target = target }

    private static func language(_ code: String, source: Bool) -> Locale.Language {
        switch code {
        case "zh": return Locale.Language(identifier: source ? "zh-Hant" : "zh-Hans")
        default: return Locale.Language(identifier: code)
        }
    }

    func setup(textId: String, sourceLang: String) {
        guard self.textId != textId else { return }
        self.textId = textId
        cache = Self.load(textId, target)
        failed = nil
        if sourceLang == target { config = nil; return }
        if sourceLang == "la" {
            failed = "Apple 翻译暂不支持拉丁文，这本书只能阅读原文。"
            config = nil
            return
        }
        config = TranslationSession.Configuration(source: Self.language(sourceLang, source: true),
                                                  target: Self.language(target, source: false))
    }

    func text(for id: Int) -> String? { cache[id] }

    func request(_ id: Int, _ text: String) {
        guard config != nil, cache[id] == nil, pending[id] == nil else { return }
        pending[id] = text
        guard !scheduled else { return }
        scheduled = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            scheduled = false
            config?.invalidate()          // 触发 translationTask 重新运行
        }
    }

    func run(_ session: TranslationSession) async {
        do {
            try await session.prepareTranslation()
        } catch {
            failed = "需要先在系统中下载翻译语言包，或当前设备不支持设备端翻译。"
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
                failed = "翻译失败：\(error.localizedDescription)"
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
