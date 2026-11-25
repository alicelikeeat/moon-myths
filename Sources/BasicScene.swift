import SwiftUI

// MARK: - 普通动画：在手机上按原文即时生成（与 tools/anim.py 的 basic_scene 同一套规则）
//
// 精讲、进阶动画从仓库下载；普通动画数量太大（几万段），不再下载，打开时现场生成。

private let keyZh = Set("仁道德君子禮礼義义孝信學学知智樂乐天命政善恕忠性心")

private func isCJK(_ c: Character) -> Bool {
    c.unicodeScalars.first.map { $0.value > 0x2E80 } ?? false
}

private func unitWidth(_ c: Character) -> Double { isCJK(c) ? 1.0 : 0.58 }

/// 按显示宽度折行：汉字算 1，西文字符算 0.58
private func wrapZh(_ s: String, _ n: Double = 17) -> [String] {
    var out: [String] = [], cur = "", w = 0.0
    for ch in s {
        let cw = unitWidth(ch)
        if w + cw > n && !cur.isEmpty { out.append(cur); cur = ""; w = 0 }
        cur.append(ch); w += cw
    }
    if !cur.isEmpty { out.append(cur) }
    return out
}

private func width(_ s: String) -> Double { s.reduce(0) { $0 + unitWidth($1) } }

private func wrapWords(_ sentence: String, _ n: Double = 40) -> [String] {
    let budget = n * 0.58
    var words: [String] = []
    for w in sentence.split(whereSeparator: { $0 == " " || $0 == "\n" }).map(String.init) {
        if width(w) > budget { words.append(contentsOf: wrapZh(w, budget)) } else { words.append(w) }
    }
    var lines: [String] = [], cur = ""
    for w in words {
        let cand = cur.isEmpty ? w : cur + " " + w
        if !cur.isEmpty && width(cand) > budget { lines.append(cur); cur = w } else { cur = cand }
    }
    if !cur.isEmpty { lines.append(cur) }
    return lines
}

private func clip(_ s: String, _ units: Double = 21) -> String {
    var out = "", w = 0.0
    for ch in s {
        w += unitWidth(ch)
        if w > units { return out.trimmingCharacters(in: .whitespaces) + "…" }
        out.append(ch)
    }
    return out
}

private func clausesZh(_ text: String) -> [String] {
    var t = text
    for q in ["「", "」", "『", "』", "“", "”"] { t = t.replacingOccurrences(of: q, with: "") }
    let seps = Set("，。；！？：、,.;!?:")
    let parts = t.split(whereSeparator: { seps.contains($0) }).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    var merged: [String] = []
    for x in parts {
        if !merged.isEmpty && x.count <= 2 { merged[merged.count - 1] += "，" + x } else { merged.append(x) }
    }
    return merged.flatMap { wrapZh($0) }
}

private func sentences(_ body: String) -> [String] {
    // 在 . ; : ? ! 之后的空白处断句
    var out: [String] = [], cur = ""
    let chars = Array(body)
    for (i, ch) in chars.enumerated() {
        cur.append(ch)
        if ".;:?!".contains(ch), i + 1 < chars.count, chars[i + 1] == " " {
            let s = cur.trimmingCharacters(in: .whitespaces)
            if !s.isEmpty { out.append(s) }
            cur = ""
        }
    }
    let s = cur.trimmingCharacters(in: .whitespaces)
    if !s.isEmpty { out.append(s) }
    return out
}

private func T(_ id: String, _ x: Double, _ y: Double, _ label: String, _ color: String, _ size: Double, at: Int) -> AnimElement {
    AnimElement(id: id, kind: "text", x: x, y: y, color: color, label: label, size: size, at: at)
}

func basicScene(text: String, lang declared: String, score: Int?) -> AnimScene? {
    let compact = text.replacingOccurrences(of: " ", with: "")
    let cjk = text.filter(isCJK).count
    let zh = Double(cjk) > 0.3 * Double(max(1, compact.count))
    var speaker: String? = nil
    var body = text
    var lines: [String] = []
    var sents: [String] = []
    var title = ""

    if zh {
        if let r = text.range(of: #"^[^，。：；「」『』！？、]{1,8}?(曰|問曰|问曰|對曰|对曰)："#, options: .regularExpression) {
            let head = String(text[r])
            for mark in ["問曰：", "问曰：", "對曰：", "对曰：", "曰："] where head.hasSuffix(mark) {
                speaker = String(head.dropLast(mark.count)); break
            }
            body = String(text[r.upperBound...])
        }
        lines = clausesZh(body)
        guard !lines.isEmpty else { return nil }
        title = String(lines[0].prefix(10))
    } else {
        if let r = text.range(of: #"^\d+(\.\d+)*\.?\s+"#, options: .regularExpression) {
            speaker = text[r].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "."))
            body = String(text[r.upperBound...])
        }
        sents = sentences(body)
        lines = sents.flatMap { wrapWords($0) }
        guard !lines.isEmpty else { return nil }
        let words = body.split(separator: " ").prefix(4).joined(separator: " ")
        title = (speaker.map { $0 + " " } ?? "") + words
    }

    var els: [AnimElement] = []
    var beats: [AnimBeat] = []

    // 君子 / 小人 对照
    if zh && body.contains("君子") && body.contains("小人") && lines.count <= 8 {
        let jz = lines.filter { $0.contains("君子") }, xr = lines.filter { $0.contains("小人") }
        els.append(AnimElement(id: "L", kind: "box", x: 0.27, y: 0.34, w: 0.36, h: 0.1, color: "gold", label: "君子"))
        els.append(AnimElement(id: "R", kind: "box", x: 0.73, y: 0.34, w: 0.36, h: 0.1, color: "silver", label: "小人", at: 1))
        for (i, l) in (jz.isEmpty ? Array(lines.prefix(1)) : jz).prefix(3).enumerated() {
            els.append(T("l\(i)", 0.27, 0.52 + 0.1 * Double(i), String(l.prefix(9)), "primary", 12, at: 0))
        }
        for (i, l) in (xr.isEmpty ? Array(lines.suffix(1)) : xr).prefix(3).enumerated() {
            els.append(T("r\(i)", 0.73, 0.52 + 0.1 * Double(i), String(l.prefix(9)), "primary", 12, at: 1))
        }
        beats = [AnimBeat(dur: 6.5, headline: "君子"), AnimBeat(dur: 6.5, headline: "小人"),
                 AnimBeat(dur: 6.5, headline: "两相对照", pulse: ["L"])]
        return AnimScene(anchor: "", title: clip(title), caption: nil, elements: els, beats: beats, tier: "basic", score: score)
    }

    var groups: [[String]] = []
    var key: [String] = []
    if zh {
        let per = lines.count <= 9 ? 3 : min(5, (lines.count + 3) / 4)
        groups = stride(from: 0, to: lines.count, by: per).map { Array(lines[$0..<min(lines.count, $0 + per)]) }
        key = [lines.first { l in l.contains { keyZh.contains($0) } } ?? lines[lines.count - 1]]
    } else {
        for x in sents {
            let ls = wrapWords(x)
            let nch = (ls.count + 3) / 4
            let sz = (ls.count + nch - 1) / max(1, nch)
            for c in stride(from: 0, to: ls.count, by: max(1, sz)).map({ Array(ls[$0..<min(ls.count, $0 + sz)]) }) {
                if let last = groups.last, last.count + c.count <= 3 { groups[groups.count - 1] = last + c } else { groups.append(c) }
            }
        }
        key = Array(wrapWords(sents.first ?? lines[0]).prefix(3))
    }
    let total = groups.count
    groups = Array(groups.prefix(4))
    let truncated = groups.count < total
    title = clip(title)
    if groups.count == 1 && groups[0].count >= 2 {
        let g = groups[0], h = (g.count + 1) / 2
        groups = [Array(g[..<h]), Array(g[h...])]
    }

    if let sp = speaker {
        els.append(AnimElement(id: "sp", kind: "node", x: 0.5, y: 0.2, r: 11, color: "gold", label: sp))
    }
    let size = zh ? 15.0 : 13.0, gap = 0.1
    for (gi, g) in groups.enumerated() {
        let y0 = 0.52 - gap * Double(g.count - 1) / 2
        els.append(AnimElement(id: "q\(gi)", kind: "box", x: 0.08, y: 0.52, w: 0.008, h: gap * Double(g.count), color: "gold", at: gi))
        for (li, l) in g.enumerated() {
            els.append(T("t\(gi)_\(li)", 0.5, y0 + gap * Double(li), l, "primary", size, at: gi))
        }
    }
    for gi in groups.indices {
        let hide: [String]? = gi == 0 ? nil : groups[gi - 1].indices.map { "t\(gi - 1)_\($0)" } + ["q\(gi - 1)"]
        let head = title + (truncated && gi == groups.count - 1 ? "（节选）" : "")
        beats.append(AnimBeat(dur: 6, headline: head, hide: hide))
    }
    let last = groups.count - 1, kb = beats.count
    let ky0 = 0.52 - 0.12 * Double(key.count - 1) / 2
    for (li, l) in key.enumerated() {
        els.append(T("k\(li)", 0.5, ky0 + 0.12 * Double(li), l, "gold", zh ? 17 : 14, at: kb))
    }
    beats.append(AnimBeat(dur: 6.5, headline: "要点",
                          hide: groups[last].indices.map { "t\(last)_\($0)" } + ["q\(last)"],
                          pulse: speaker == nil ? nil : ["sp"]))
    guard beats.count <= 5 else { return nil }
    return AnimScene(anchor: "", title: title, caption: nil, elements: els, beats: beats, tier: "basic", score: score)
}

// MARK: - 经文动画：庄重、安静，只用几何与光

/// style：bible / quran / buddhist / vedic；reference：显示在顶部的出处（卷名 + 节号）
func scriptureScene(text: String, style: String, section: String) -> AnimScene? {
    var body = text.trimmingCharacters(in: .whitespaces)
    var verse = ""
    if let r = body.range(of: #"^(\d+:\d+|\d+\.)\s*"#, options: .regularExpression) {
        verse = body[r].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: "."))
        body = String(body[r.upperBound...])
    }
    guard !body.isEmpty else { return nil }
    let compact = body.replacingOccurrences(of: " ", with: "")
    let zh = Double(body.filter(isCJK).count) > 0.3 * Double(max(1, compact.count))
    let arabic = body.unicodeScalars.contains { (0x0600...0x06FF).contains($0.value) }

    // 折行：经文字号更大，每行更短
    var lines: [String]
    if zh {
        var t = body
        for q in ["「", "」", "『", "』"] { t = t.replacingOccurrences(of: q, with: "") }
        // 按标点切成短句（保留标点），再把短句拼成不超过 13 个字宽的行
        var clauses: [String] = [], cur = ""
        for ch in t {
            cur.append(ch)
            if "，。；！？、：".contains(ch) { clauses.append(cur); cur = "" }
        }
        if !cur.trimmingCharacters(in: .whitespaces).isEmpty { clauses.append(cur) }
        lines = []
        var line = ""
        for c in clauses.flatMap({ width($0) > 13 ? wrapZh($0, 13) : [$0] }) {
            if !line.isEmpty && width(line + c) > 13 { lines.append(line); line = c } else { line += c }
        }
        if !line.isEmpty { lines.append(line) }
    } else {
        lines = wrapWords(body, arabic ? 30 : 34)
    }
    guard !lines.isEmpty else { return nil }
    let per = zh ? 3 : 4
    var groups = stride(from: 0, to: lines.count, by: per).map { Array(lines[$0..<min(lines.count, $0 + per)]) }
    let truncated = groups.count > 4
    groups = Array(groups.prefix(4))

    // 出处：卷名（取“·”后面的部分，或末尾的“Called …”）+ 节号
    var book = section
    if let r = book.range(of: "Called ") { book = String(book[r.upperBound...]) }
    if let r = book.range(of: " · ") { book = String(book[r.upperBound...]) }
    let reference = clip([book, verse].filter { !$0.isEmpty }.joined(separator: " "), 20) + (truncated ? "（节选）" : "")

    var els: [AnimElement] = [AnimElement(id: "frame", kind: "frame", color: "gold")]
    switch style {
    case "quran":
        els.append(AnimElement(id: "motif", kind: "star", r: 70, color: "gold"))
    case "buddhist":
        els.append(AnimElement(id: "motif", kind: "lotus", x: 0.5, y: 0.84, r: 62, color: "gold", n: 10))
    case "vedic":
        els.append(AnimElement(id: "motif", kind: "rings", x: 0.5, y: 0.52, r: 150, color: "gold", n: 5))
    default:
        els.append(AnimElement(id: "motif", kind: "rays", x: 0.5, y: 0.1, r: 300, color: "gold", n: 17))
    }
    els.append(AnimElement(id: "halo", kind: "halo", x: 0.5, y: 0.52, r: 150, color: "gold"))

    let size = zh ? 19.0 : (arabic ? 21.0 : 15.0)
    let gap = zh ? 0.12 : (arabic ? 0.13 : 0.1)
    var beats: [AnimBeat] = []
    for (gi, g) in groups.enumerated() {
        let y0 = 0.52 - gap * Double(g.count - 1) / 2
        for (li, l) in g.enumerated() {
            els.append(AnimElement(id: "t\(gi)_\(li)", kind: "text", x: 0.5, y: y0 + gap * Double(li), color: "primary",
                                   label: l, size: size, at: gi, font: "serif"))
        }
        let hide: [String]? = gi == 0 ? nil : groups[gi - 1].indices.map { "t\(gi - 1)_\($0)" }
        beats.append(AnimBeat(dur: 7.5, headline: reference, hide: hide))
    }
    // 最后一拍：经文慢慢化为金色
    let last = groups.count - 1
    var toGold: [String: AnimPatch] = [:]
    for li in groups[last].indices { toGold["t\(last)_\(li)"] = AnimPatch(color: "gold") }
    toGold["halo"] = AnimPatch(r: 175)
    beats.append(AnimBeat(dur: 7.5, headline: reference, set: toGold))
    guard beats.count <= 5 else { return nil }
    return AnimScene(anchor: "", title: reference, caption: nil, elements: els, beats: beats, tier: "scripture", score: nil)
}

// MARK: - 截图用：四种经文风格并排（`-scriptureShot -animBeat b`）

struct ScriptureShotView: View {
    let beat: Int
    private let samples: [(String, String, String)] = [
        ("1:1 In the beginning God created the heaven and the earth.", "bible", "The First Book of Moses: Called Genesis"),
        ("1. بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ", "quran", "1. الفاتحة · Al-Fatiha"),
        ("觀自在菩薩行深般若波羅蜜多時，照見五蘊皆空，度一切苦厄。", "buddhist", "般若波羅蜜多心經"),
        ("That is whole; this is whole; from that whole this whole came.", "vedic", "Isa-Upanishad"),
    ]

    var body: some View {
        let cols = Array(repeating: GridItem(.fixed(190), spacing: 6), count: 2)
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(Array(samples.enumerated()), id: \.offset) { _, s in
                if let sc = scriptureScene(text: s.0, style: s.1, section: s.2) {
                    let rt = SceneRuntime(sc)
                    let b = min(beat, rt.durations.count - 1)
                    let t = rt.durations.prefix(b).reduce(0, +) + rt.durations[b] * 0.85
                    Canvas { ctx, size in rt.draw(&ctx, size, t) }
                        .frame(width: 350, height: 380)
                        .background(Color.primary.opacity(0.04))
                        .scaleEffect(0.53)
                        .frame(width: 190, height: 206)
                }
            }
        }
        .padding(.top, 60)
    }
}
