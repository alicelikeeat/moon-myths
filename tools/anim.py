"""段落动画剧本的编写工具：小型 DSL + 校验。

用法：在 tools/anims/<书>.py 里 `from anim import *`，调用 scene(...)，最后 save("<全文 id>")。
校验：anchor 必须能在全文里找到（忽略标点），元素坐标在舞台内，每拍 5–9 秒，3–5 拍。
"""
import json, os, sys, unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_scenes = []

def _el(kind, id, **kw):
    d = {"id": id, "kind": kind}
    for k, v in kw.items():
        if v is None or v is False and k == "dash": continue
        if k == "at" and v == 0: continue
        d[k] = v
    return d

def N(id, x, y, label="", color="silver", r=14, at=0, size=None):
    return _el("node", id, x=x, y=y, label=label or None, color=color, r=r, at=at, size=size)

def B(id, x, y, label="", w=0.3, h=0.1, color="silver", at=0, size=None):
    return _el("box", id, x=x, y=y, label=label or None, w=w, h=h, color=color, at=at, size=size)

def R(id, x, y, r, label="", color="gold", at=0, dash=False):
    return _el("ring", id, x=x, y=y, r=r, label=label or None, color=color, at=at, dash=dash or None)

def T(id, x, y, label, color="primary", size=13, at=0):
    return _el("text", id, x=x, y=y, label=label, color=color, size=size, at=at)

def A(id, f, t, label="", color="gold", at=0, dash=False):
    return _el("arrow", id, **{"from": f}, to=t, label=label or None, color=color, at=at, dash=dash or None)

def P(id, x, y, r, n=30, color="silver", at=0, label=""):
    return _el("particles", id, x=x, y=y, r=r, n=n, color=color, at=at, label=label or None)

def Bar(id, x, y, h, label="", w=0.1, color="silver", at=0):
    return _el("bar", id, x=x, y=y, h=h, w=w, label=label or None, color=color, at=at)

def beat(headline, dur=6.5, set=None, hide=None, pulse=None):
    d = {"headline": headline, "dur": dur}
    if set: d["set"] = set
    if hide: d["hide"] = hide
    if pulse: d["pulse"] = pulse
    return d

def scene(anchor, title, els, beats, caption=None):
    s = {"anchor": anchor, "title": title, "elements": els, "beats": beats}
    if caption: s["caption"] = caption
    _scenes.append(s)

def _strip(s):
    return "".join(c for c in s if not unicodedata.category(c).startswith(("P", "S", "Z")) and not c.isspace())

def save(text_id, fill=True, skip=lambda i, p: False):
    doc = json.load(open(os.path.join(ROOT, "texts", f"{text_id}.json"), encoding="utf-8"))
    paras = [p for s in doc["sections"] for p in s["paragraphs"]]
    bare = [_strip(p) for p in paras]
    errors, used = [], {}
    for s in _scenes:
        want = None
        if isinstance(s["anchor"], int):          # 用段落序号写，自动取开头作为定位
            want = s["anchor"]
            L = 14
            while True:
                s["anchor"] = paras[want][:L]
                first = next(i for i, p in enumerate(paras) if s["anchor"] in p)
                if first == want or L >= len(paras[want]): break
                L += 6
        a = s["anchor"]
        idx = next((i for i, p in enumerate(paras) if a in p), None)
        if idx is None:
            idx = next((i for i, p in enumerate(bare) if _strip(a) in p), None)
        if idx is None:
            errors.append(f"找不到 anchor：{a}")
            continue
        if idx in used:
            errors.append(f"段落 {idx} 重复：{a} / {used[idx]}")
        used[idx] = a
        ids = {e["id"] for e in s["elements"]}
        nb = len(s["beats"])
        if not 3 <= nb <= 5:
            errors.append(f"{s['title']}：{nb} 拍")
        for e in s["elements"]:
            if e.get("at", 0) >= nb:
                errors.append(f"{s['title']}：{e['id']} 在第 {e['at']} 拍出现，但只有 {nb} 拍")
            for k in ("x", "y"):
                if k in e and not 0.04 <= e[k] <= 0.96:
                    errors.append(f"{s['title']}：{e['id']}.{k}={e[k]} 超出舞台")
            if e["kind"] == "arrow" and not (e["from"] in ids and e["to"] in ids):
                errors.append(f"{s['title']}：箭头 {e['id']} 端点不存在")
        for b in s["beats"]:
            if not 5 <= b["dur"] <= 9:
                errors.append(f"{s['title']}：节拍时长 {b['dur']}")
            for k in list(b.get("set", {})) + b.get("hide", []) + b.get("pulse", []):
                if k not in ids:
                    errors.append(f"{s['title']}：节拍引用了不存在的元素 {k}")
            for k, v in b.get("set", {}).items():
                for kk in ("x", "y"):
                    if kk in v and not 0.04 <= v[kk] <= 0.96:
                        errors.append(f"{s['title']}：{k}.{kk} 超出舞台")
    if errors:
        print("\n".join(errors)); sys.exit(1)
    for sc in _scenes:
        sc.setdefault("tier", "core")
    core = len(_scenes)
    if fill:
        lang = doc.get("lang", "zh")
        for i, p in enumerate(paras):
            if i in used or skip(i, p):
                continue
            b = basic_scene(p, lang)
            if b:
                L = 14
                while True:
                    a = paras[i][:L]
                    if next(j for j, q in enumerate(paras) if a in q) == i or L >= len(paras[i]): break
                    L += 6
                b["anchor"] = a
                used[i] = a
                _scenes.append(b)
    os.makedirs(os.path.join(ROOT, "anims"), exist_ok=True)
    out = os.path.join(ROOT, "anims", f"{text_id}.json")
    json.dump({"id": text_id, "scenes": _scenes}, open(out, "w", encoding="utf-8"),
              ensure_ascii=False, separators=(",", ":"))
    print(f"{text_id}: 精讲 {core} + 普通 {len(_scenes) - core}，覆盖 {len(used)}/{len(paras)} 段")
    check_layout(out)


# MARK: 常用模板 ---------------------------------------------------------------

def pairs(n, title, items, h0, h1, h2, cap):
    """成对的概念：先出现左边，再出现右边，最后互相转化"""
    els = []
    k = len(items)
    for i, (a, b) in enumerate(items):
        y = 0.2 + 0.62 * (i + 0.5) / k
        els += [N(f"a{i}", 0.3, y, "", "silver", 11), T(f"ta{i}", 0.16, y, a, size=13),
                N(f"b{i}", 0.7, y, "", "violet", 11, at=1), T(f"tb{i}", 0.84, y, b, size=13, at=1),
                A(f"x{i}", f"a{i}", f"b{i}", "", "gold", at=2), A(f"y{i}", f"b{i}", f"a{i}", "", "dim", at=2)]
    scene(n, title, els, [beat(h0), beat(h1), beat(h2, 7.5)], cap)

def chain(n, title, items, heads, cap, colors=None, vertical=False):
    """依次出现、用箭头连起来的链条"""
    els = []
    k = len(items)
    nb = len(heads)
    for i, it in enumerate(items):
        at = min(nb - 1, i * nb // k)
        x, y = (0.5, 0.18 + 0.66 * i / max(1, k - 1)) if vertical else (0.1 + 0.8 * i / max(1, k - 1), 0.5)
        c = (colors or {}).get(i, "gold" if i == k - 1 else "silver")
        els.append(N(f"n{i}", x, y, it, c, 13, at=at))
        if i:
            els.append(A(f"e{i}", f"n{i-1}", f"n{i}", "", "gold", at=at))
    scene(n, title, els, [beat(h) for h in heads], cap)

def versus(n, title, left, right, h0, h1, h2, cap, win="left"):
    """两种人 / 两种做法对照，最后一方胜出。left/right = [标题, 说明…]"""
    els = [B("L", 0.27, 0.32, left[0], 0.4, 0.11, "gold" if win == "left" else "silver"),
           B("Rt", 0.73, 0.32, right[0], 0.4, 0.11, "silver" if win == "left" else "gold", at=1)]
    for i, s in enumerate(left[1:]):
        els.append(T(f"l{i}", 0.27, 0.5 + 0.1 * i, s, size=12))
    for i, s in enumerate(right[1:]):
        els.append(T(f"r{i}", 0.73, 0.5 + 0.1 * i, s, size=12, at=1))
    w = "L" if win == "left" else "Rt"
    lose = "Rt" if win == "left" else "L"
    final = {} if win == "both" else {lose: {"opacity": 0.35}, w: {"h": 0.14}}
    scene(n, title, els, [beat(h0), beat(h1), beat(h2, 7.5, set=final, pulse=[] if win == "both" else [w])], cap)

def junzi(n, title, jz, xr, h0, h1, h2, cap):
    """君子 / 小人 对照"""
    versus(n, title, ["君子"] + jz, ["小人"] + xr, h0, h1, h2, cap)

def hub(n, title, items, center, heads, cap, center_color="gold"):
    """若干要素依次出现，汇向中心"""
    import math
    els = [N("c", 0.5, 0.52, center, center_color, 18, at=len(heads) - 1)]
    k = len(items)
    nb = len(heads)
    for i, it in enumerate(items):
        ang = -math.pi / 2 + 2 * math.pi * i / k
        at = min(nb - 2, i * (nb - 1) // k) if nb > 1 else 0
        els.append(N(f"i{i}", 0.5 + 0.33 * math.cos(ang), 0.52 + 0.27 * math.sin(ang), it, "silver", 12, at=at))
        els.append(A(f"a{i}", f"i{i}", "c", "", "gold", at=nb - 1))
    scene(n, title, els, [beat(h) for h in heads[:-1]] + [beat(heads[-1], 7.5, pulse=["c"])], cap)

def ladder(n, title, levels, heads, cap):
    """由低到高的台阶（levels 从低到高）"""
    els = []
    k = len(levels)
    nb = len(heads)
    for i, lv in enumerate(levels):
        at = min(nb - 1, i * nb // k)
        h = 0.12 + 0.55 * (i + 1) / k
        els.append(Bar(f"b{i}", 0.12 + 0.76 * (i + 0.5) / k, 0.8, h, lv, 0.7 / k, "gold" if i == k - 1 else "silver", at=at))
    scene(n, title, els, [beat(h) for h in heads[:-1]] + [beat(heads[-1], 7.5, pulse=[f"b{k-1}"])], cap)

def balance(n, title, a, b, h0, h1, h2, cap, mid="中"):
    """两端失衡，最后回到中间（过犹不及、文质彬彬）"""
    els = [B("beam", 0.5, 0.5, "", 0.8, 0.02, "dim"),
           N("l", 0.15, 0.5, a, "silver", 14), N("r", 0.85, 0.5, b, "violet", 14),
           N("p", 0.15, 0.4, "", "gold", 10, at=1), T("m", 0.5, 0.72, mid, "gold", 15, at=2)]
    scene(n, title, els, [beat(h0), beat(h1, set={"p": {"x": 0.85}}), beat(h2, 7.5, set={"p": {"x": 0.5, "r": 16}})], cap)


# MARK: 普通动画：按原文自动生成 ------------------------------------------------

import re as _re
_KEY_ZH = "仁道德君子禮礼義义孝信學学知智樂乐天命政善恕忠性心"

def _wrap_zh(c, n=17):
    """按显示宽度折行：汉字算 1，西文字符算 0.58"""
    out, cur, w = [], "", 0.0
    for ch in c:
        cw = 1.0 if ord(ch) > 0x2E80 else 0.58
        if w + cw > n and cur:
            out.append(cur); cur, w = "", 0.0
        cur += ch; w += cw
    if cur: out.append(cur)
    return out

def _clauses_zh(text):
    t = text.replace("「", "").replace("」", "").replace("『", "").replace("』", "").replace("“", "").replace("”", "")
    parts = [x.strip() for x in _re.split(r"[，。；！？：、,.;!?:]", t) if x.strip()]
    merged = []
    for x in parts:
        if merged and len(x) <= 2:
            merged[-1] += "，" + x
        else:
            merged.append(x)
    return [l for x in merged for l in _wrap_zh(x)]

def _wrap_words(sent, n=40):
    """按显示宽度折行（西文字符 0.58，汉字 1），每行不超过 n×0.58 个汉字宽"""
    budget = n * 0.58
    def width(x): return sum(1.0 if ord(c) > 0x2E80 else 0.58 for c in x)
    words = []
    for w in sent.split():
        if width(w) > budget:
            words.extend(_wrap_zh(w, budget))
        else:
            words.append(w)
    lines, cur = [], ""
    for w in words:
        cand = (cur + " " + w).strip()
        if cur and width(cand) > budget:
            lines.append(cur); cur = w
        else:
            cur = cand
    if cur: lines.append(cur)
    return lines

def basic_scene(text, lang):
    """说话人 → 逐句浮现 → 点亮关键句"""
    cjk = sum(1 for c in text if ord(c) > 0x2E80)
    lang = "zh" if cjk > 0.3 * max(1, len(text.replace(" ", ""))) else ("en" if lang == "zh" else lang)
    speaker = None
    if lang == "zh":
        m = _re.match(r"^([^，。：；「」『』！？、]{1,8}?)(曰|問曰|问曰|對曰|对曰)：", text)
        body = text
        if m:
            speaker = m.group(1)
            body = text[m.end():]
        lines = _clauses_zh(body)
        if not lines:
            return None
        title = lines[0][:10]
    else:
        num = None
        m = _re.match(r"^(\d+(?:\.\d+)*)\s+", text)
        body = text
        if m:
            num = m.group(1); body = text[m.end():]
        sents = [x for x in _re.split(r"(?<=[.;:?!])\s+", body) if x.strip()]
        lines = [l for x in sents for l in _wrap_words(x)]
        if not lines:
            return None
        speaker = num
        title = (num + " " if num else "") + " ".join(body.split()[:4])
    # 君子 / 小人 对照：自动排成两栏
    if lang == "zh" and "君子" in body and "小人" in body and len(lines) <= 8:
        jz = [l for l in lines if "君子" in l] or lines[:1]
        xr = [l for l in lines if "小人" in l] or lines[-1:]
        els = [B("L", 0.27, 0.34, "君子", 0.36, 0.1, "gold"), B("R", 0.73, 0.34, "小人", 0.36, 0.1, "silver", at=1)]
        for i, l in enumerate(jz[:3]):
            els.append(T(f"l{i}", 0.27, 0.52 + 0.1 * i, l[:9], size=12))
        for i, l in enumerate(xr[:3]):
            els.append(T(f"r{i}", 0.73, 0.52 + 0.1 * i, l[:9], size=12, at=1))
        sc = {"anchor": "", "title": title, "tier": "basic", "elements": els,
              "beats": [beat("君子"), beat("小人"), beat("两相对照", 6.5, pulse=["L"])]}
        return sc
    if lang == "zh":
        per = 3 if len(lines) <= 9 else min(5, -(-len(lines) // 4))
        groups = [lines[i:i + per] for i in range(0, len(lines), per)]
        key = None
        for l in lines:
            if any(c in l for c in _KEY_ZH):
                key = [l]; break
        key = key or [lines[-1]]
    else:
        # 西文：一拍一句（太长的句子拆成每拍最多 4 行），短句合并
        groups = []
        for x in sents:
            ls = _wrap_words(x)
            nch = -(-len(ls) // 4)
            sz = -(-len(ls) // nch)
            chunks = [ls[i:i + sz] for i in range(0, len(ls), sz)]
            for c in chunks:
                if groups and len(groups[-1]) + len(c) <= 3:
                    groups[-1] = groups[-1] + c
                else:
                    groups.append(c)
        key = _wrap_words(sents[0])[:3]
    total = len(groups)
    groups = groups[:4]
    truncated = len(groups) < total
    def _clip(x, units=21):
        out, w = "", 0.0
        for ch in x:
            w += 1.0 if ord(ch) > 0x2E80 else 0.58
            if w > units:
                return out.rstrip() + "…"
            out += ch
        return out
    title = _clip(title)
    if len(groups) == 1 and len(groups[0]) >= 2:
        g = groups[0]; h = (len(g) + 1) // 2
        groups = [g[:h], g[h:]]
    els, beats_ = [], []
    if speaker:
        els.append(N("sp", 0.5, 0.2, speaker, "gold", 11))
    size = 15 if lang == "zh" else 13
    gap = 0.1
    maxl = max(len(g) for g in groups)
    for gi, g in enumerate(groups):
        y0 = 0.52 - gap * (len(g) - 1) / 2
        els.append(B(f"q{gi}", 0.08, 0.52, "", 0.008, gap * len(g), "gold", at=gi))
        for li, l in enumerate(g):
            els.append(T(f"t{gi}_{li}", 0.5, y0 + gap * li, l, "primary", size, at=gi))
    for gi, g in enumerate(groups):
        hide = ([f"t{gi-1}_{li}" for li in range(len(groups[gi - 1]))] + [f"q{gi-1}"]) if gi else None
        bt = beat(title + ("（节选）" if truncated and gi == len(groups) - 1 else ""), 6)
        if hide: bt["hide"] = hide
        beats_.append(bt)
    last = len(groups) - 1
    kb = len(beats_)
    ky0 = 0.52 - 0.12 * (len(key) - 1) / 2
    for li, l in enumerate(key):
        els.append(T(f"k{li}", 0.5, ky0 + 0.12 * li, l, "gold", 17 if lang == "zh" else 14, at=kb))
    bt = beat("要点", 6.5, hide=[f"t{last}_{li}" for li in range(len(groups[last]))] + [f"q{last}"])
    if speaker: bt["pulse"] = ["sp"]
    beats_.append(bt)
    if len(beats_) > 5:
        return None
    return {"anchor": "", "title": title, "tier": "basic", "elements": els, "beats": beats_}


# MARK: 版面检查：同一拍里文字是否互相压住 --------------------------------------

def _tw(label, size):
    w = sum(size * (1.0 if ord(c) > 0x2E80 else 0.58) for c in label)
    return w / 350, size * 1.25 / 380

def layout_issues(sc):
    els = {e["id"]: dict(e) for e in sc["elements"]}
    hidden = set()
    issues = []
    for b, bt in enumerate(sc["beats"]):
        for k, v in (bt.get("set") or {}).items():
            els[k].update({kk: vv for kk, vv in v.items()})
            if v.get("opacity", 1) <= 0.05: hidden.add(k)
        for k in bt.get("hide") or []:
            hidden.add(k)
        boxes = []
        for e in els.values():
            if e.get("at", 0) > b or e["id"] in hidden or e["kind"] == "arrow" or e.get("opacity", 1) <= 0.05:
                continue
            x, y = e.get("x", 0.5), e.get("y", 0.5)
            lab = e.get("label") or ""
            size = e.get("size") or (13 if e["kind"] in ("text", "box") else 12)
            if e["kind"] == "text":
                w, h = _tw(lab, size); boxes.append((e["id"], x, y, w, h))
            elif e["kind"] in ("node", "particles") and lab:
                r = e.get("r", 14)
                w, h = _tw(lab, size if e["kind"] == "node" else 11)
                boxes.append((e["id"] + ".label", x, y + (r + 13) / 380, w, h))
            elif e["kind"] == "bar" and lab:
                w, h = _tw(lab, 11); boxes.append((e["id"] + ".label", x, y + 14 / 380, w, h))
            elif e["kind"] == "ring" and lab:
                w, h = _tw(lab, 12); boxes.append((e["id"] + ".label", x, y - (e.get("r", 14) + 12) / 380, w, h))
        boxes.append(("headline", 0.5, 22 / 380, *_tw(bt["headline"], 14)))
        if sc.get("caption"):
            boxes.append(("caption", 0.5, 1 - 18 / 380, *_tw(sc["caption"], 13)))
        for i in range(len(boxes)):
            for j in range(i + 1, len(boxes)):
                a, c = boxes[i], boxes[j]
                if abs(a[1] - c[1]) < (a[3] + c[3]) / 2 - 0.01 and abs(a[2] - c[2]) < (a[4] + c[4]) / 2 - 0.004:
                    issues.append(f"第{b+1}拍 {a[0]} × {c[0]}")
        for bx in boxes:
            if bx[1] - bx[3] / 2 < -0.02 or bx[1] + bx[3] / 2 > 1.02:
                issues.append(f"第{b+1}拍 {bx[0]} 超出左右边界")
    return sorted(set(issues))

def check_layout(path):
    d = json.load(open(path, encoding="utf-8"))
    n = 0
    for sc in d["scenes"]:
        iss = layout_issues(sc)
        if iss:
            n += 1
            print(f"[{sc.get('tier')}] {sc['title']}: " + "；".join(iss[:4]))
    print(f"{n} 个动画有版面问题")

def reset():
    _scenes.clear()
