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

def save(text_id, fill=True, skip=lambda i, p: False, scored=True, style=None):
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
    lang = doc.get("lang", "zh")
    scores = score_book(paras, lang)
    idx_of = {}
    for i, a_ in used.items():
        idx_of[a_] = i
    for sc in _scenes:
        if scored:
            sc["score"] = 100
    if fill:
        for i, p in enumerate(paras):
            if i in used or skip(i, p):
                continue
            b = (plus_scene(p, lang) if scored and scores[i] >= 60 else None) or basic_scene(p, lang)
            if b:
                if scored:
                    b["score"] = scores[i]
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
    # 普通动画在手机上按同样规则即时生成，这里只检查版面，不写进文件
    check = {"id": text_id, "scenes": _scenes}
    json.dump(check, open("/tmp/anim_check.json", "w", encoding="utf-8"), ensure_ascii=False)
    doc_out = {"id": text_id, "scenes": [x for x in _scenes if x.get("tier") != "basic"], "basic": fill}
    if scored:
        doc_out["scores"] = scores
    if style:
        doc_out["style"] = style
    json.dump(doc_out, open(out, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    plus = sum(1 for x in _scenes if x.get("tier") == "plus")
    rep = sorted((x for x in _scenes if x.get("tier") != "core"), key=lambda x: -x.get("score", 0))[:40]
    os.makedirs(os.path.join(ROOT, "tools", "scores"), exist_ok=True)
    with open(os.path.join(ROOT, "tools", "scores", f"{text_id}.txt"), "w", encoding="utf-8") as fh:
        for x in rep:
            fh.write(f"{x.get('score', 0):3d} {x['tier']:5s} {x['anchor'][:40]}\n")
    print(f"{text_id}: 精讲 {core} + 进阶 {plus} + 普通 {len(_scenes) - core - plus}，覆盖 {len(used)}/{len(paras)} 段")
    check_layout("/tmp/anim_check.json")


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
        m = _re.match(r"^(\d+(?:\.\d+)*)\.?\s+", text)
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


# MARK: 进阶动画：在普通段落里按句式找出结构清楚的，自动画成图 ------------------

_ANTONYMS = [("有", "無"), ("善", "惡"), ("生", "死"), ("上", "下"), ("大", "小"), ("多", "少"), ("美", "惡"),
             ("得", "失"), ("治", "亂"), ("是", "非"), ("貴", "賤"), ("富", "貧"), ("強", "弱"), ("剛", "柔"),
             ("進", "退"), ("先", "後"), ("利", "害"), ("禍", "福"), ("動", "靜"), ("義", "利"), ("君子", "小人"),
             ("古", "今"), ("內", "外"), ("賢", "不肖"), ("明", "暗"), ("陰", "陽")]

def _uw(x):
    return sum(1.0 if ord(c) > 0x2E80 else 0.58 for c in x)

def _clipw(x, units):
    out, w = "", 0.0
    for ch in x:
        w += 1.0 if ord(ch) > 0x2E80 else 0.58
        if w > units:
            return out.rstrip() + "…"
        out += ch
    return out

def _zh_clauses_raw(text):
    t = text
    for q in "「」『』“”":
        t = t.replace(q, "")
    m = _re.match(r"^([^，。：；！？、]{1,8}?)(曰|問曰|對曰)：", t)
    speaker = None
    if m:
        speaker, t = m.group(1), t[m.end():]
    return speaker, [c.strip() for c in _re.split(r"[，。；！？：]", t) if c.strip()]

def _plus_zh(text):
    speaker, cl = _zh_clauses_raw(text)
    if not cl or len(text) > 140:
        return None
    title = _clipw(cl[0], 12)
    sp = [N("sp", 0.5, 0.16, speaker, "gold", 10)] if speaker else []
    # 1) 定义：X者，Y也
    for i, c in enumerate(cl[:-1]):
        if (c.endswith("者") and 1 <= len(c) - 1 <= 2 and c[0] not in "苟若如雖使凡今昔故"
                and any(k in c for k in _KEYS_ZH + "人物事") and cl[i + 1].endswith("也") and 2 <= len(cl[i + 1]) <= 10):
            x, y = c[:-1], cl[i + 1][:-1]
            els = sp + [N("x", 0.25, 0.5, _clipw(x, 8), "gold", 16), B("y", 0.68, 0.5, _clipw(y, 12), 0.52, 0.13, "silver", at=1),
                        A("a", "x", "y", "即", "gold", at=1)]
            return {"title": title, "kind": "定义", "elements": els,
                    "beats": [beat(_clipw(c, 18)), beat(_clipw(cl[i + 1], 18)), beat(_clipw(x + " ＝ " + y, 20), 7, pulse=["x"])]}
    # 2) 条件链：A則B
    links = []
    for c in cl:
        if "則" in c:
            a, b = c.split("則", 1)
            if 1 <= len(a) <= 8 and 1 <= len(b) <= 8:
                links.append((a, b))
    if len(links) >= 2:
        chained = all(links[j][1] == links[j + 1][0] for j in range(len(links) - 1))
        els = list(sp)
        if chained:
            items = [links[0][0]] + [b_ for _, b_ in links][:4]
            k = len(items)
            for i, it in enumerate(items):
                at = 0 if i < 2 else (1 if i < 4 else 2)
                els.append(N(f"n{i}", 0.3 if i % 2 == 0 else 0.7, 0.3 + 0.48 * i / max(1, k - 1), _clipw(it, 8), "gold" if i == k - 1 else "silver", 12, at=at))
                if i:
                    els.append(A(f"e{i}", f"n{i-1}", f"n{i}", "則", "gold", at=at))
            return {"title": title, "kind": "条件链", "elements": els,
                    "beats": [beat(_clipw(cl[0], 18)), beat("一环扣一环"), beat("推到最后", 7, pulse=[f"n{k-1}"])]}
        rows = links[:4]
        k = len(rows)
        for j, (a_, b_) in enumerate(rows):
            y = 0.3 + 0.5 * j / max(1, k - 1)
            at = 0 if j < (k + 1) // 2 else 1
            els += [B(f"c{j}", 0.27, y, _clipw(a_, 7), 0.4, 0.085, "silver", at=at),
                    B(f"r{j}", 0.75, y, _clipw(b_, 7), 0.38, 0.085, "gold", at=at),
                    A(f"e{j}", f"c{j}", f"r{j}", "", "gold", at=at)]
        return {"title": title, "kind": "条件", "elements": els,
                "beats": [beat("如果……就……"), beat("对照各种条件"), beat("条件不同，结果不同", 7)]}
    # 3) 排比：三句以上等长、开头或结尾相同
    for i in range(len(cl) - 2):
        grp = [cl[i]]
        for c in cl[i + 1:]:
            if len(c) == len(grp[0]) and 3 <= len(c) <= 7 and (c[-1] == grp[0][-1] or c[0] == grp[0][0] or c[1:2] == grp[0][1:2]):
                grp.append(c)
            else:
                break
        if len(grp) >= 3:
            grp = grp[:6]
            k = len(grp)
            els = list(sp)
            for j, g in enumerate(grp):
                at = 0 if j < (k + 1) // 2 else 1
                els.append(B(f"b{j}", 0.5, 0.3 + 0.5 * j / max(1, k - 1), g, 0.46, 0.085, "gold" if j == k - 1 else "silver", at=at))
            return {"title": title, "kind": "排比", "elements": els,
                    "beats": [beat(_clipw(grp[0], 18)), beat("层层排比"), beat("合而观之", 7, pulse=[f"b{k-1}"])]}
    # 4) 对举：一对反义词分在两句
    for i in range(len(cl) - 1):
        a, b = cl[i], cl[i + 1]
        if not (2 <= len(a) <= 10 and 2 <= len(b) <= 10):
            continue
        for x, y in _ANTONYMS:
            if (x in a and y in b and y not in a) or (y in a and x in b and x not in a):
                els = sp + [B("L", 0.27, 0.42, _clipw(a, 8), 0.42, 0.12, "silver"), B("R", 0.73, 0.42, _clipw(b, 8), 0.42, 0.12, "violet", at=1),
                            T("tx", 0.27, 0.62, x if x in a else y, "gold", 20), T("ty", 0.73, 0.62, y if x in a else x, "gold", 20, at=1),
                            A("ab", "L", "R", "", "gold", at=2), A("ba", "R", "L", "", "dim", at=2)]
                rest = "，".join(cl[i + 2:i + 4])
                if rest:
                    els.append(T("rest", 0.5, 0.82, _clipw(rest, 20), "primary", 13, at=2))
                return {"title": title, "kind": "对举", "elements": els,
                        "beats": [beat(_clipw(a, 18)), beat(_clipw(b, 18)), beat("两相对照", 7)]}
    return None

def _plus_west(text, lang):
    body = _re.sub(r"^\d+(?:\.\d+)*\s+", "", text)
    if len(body) > 260:
        return None
    sents = [x for x in _re.split(r"(?<=[.;:?!])\s+", body) if x.strip()]
    if not sents:
        return None
    s0 = sents[0]
    title = _clipw(" ".join(body.split()[:5]), 20)
    num = _re.match(r"^(\d+(?:\.\d+)*)\s+", text)
    sp = [N("sp", 0.5, 0.16, num.group(1), "gold", 10)] if num else []
    # 定义：X ist Y / X is Y / By X, I mean Y
    m = _re.match(r"^By (.{3,40}?),? I (?:mean|understand) (.{3,140})$", s0)
    if _re.search(r"\b(replied|said|answered|sagte|antwortete)\b", s0):
        return None
    if not m and len(sents) <= 2 and len(s0.split()) <= 14:
        m = _re.match(r"^((?:Der|Die|Das|The|A|An|Ein|Eine|Le|La|Les)\s+[A-ZÄÖÜ]?\S+(?:\s+\S+){0,2}) (?:ist|is|sind|are|est) (.{3,100})$", s0)
        stop = {"which", "that", "who", "aber", "also", "nun", "doch", "so", "es", "dies", "this", "then", "one", "other", "same"}
        if m and (any(w.lower().strip(",") in stop for w in m.group(1).split()) or
                  (m.group(1).split()[0] in ("Der", "Die", "Das", "Ein", "Eine") and not m.group(1).split()[1][:1].isupper())):
            m = None
    if m:
        x, y = m.group(1).strip(), m.group(2).strip().rstrip(".")
        ys = _wrap_words(y, 34)[:3]
        els = sp + [N("x", 0.5, 0.32, _clipw(x, 16), "gold", 14)]
        for j, l in enumerate(ys):
            els.append(T(f"y{j}", 0.5, 0.58 + 0.08 * j, l, "primary", 13, at=1))
        els.append(A("a", "x", "y0", "", "gold", at=1))
        return {"title": title, "kind": "定义", "elements": els,
                "beats": [beat(_clipw(x, 22)), beat("它是什么？"), beat("定义", 7, pulse=["x"])]}
    # 转折：not X but Y / nicht X, sondern Y
    m = _re.search(r"\b(?:not|nicht)\b(.{2,70}?),?\s+\b(?:but|sondern)\b(.{2,90})", s0)
    if m:
        a, b = m.group(1).strip(" ,"), m.group(2).strip(" .")
        els = sp + [B("L", 0.27, 0.42, "", 0.42, 0.2, "dim"), B("R", 0.73, 0.42, "", 0.42, 0.2, "gold", at=1)]
        for j, l in enumerate(_wrap_words(a, 22)[:3]):
            els.append(T(f"a{j}", 0.27, 0.36 + 0.07 * j, l, "primary", 11))
        for j, l in enumerate(_wrap_words(b, 22)[:3]):
            els.append(T(f"b{j}", 0.73, 0.36 + 0.07 * j, l, "primary", 11, at=1))
        els.append(T("no", 0.27, 0.62, "✕", "violet", 18)); els.append(T("yes", 0.73, 0.62, "✓", "gold", 18, at=1))
        return {"title": title, "kind": "转折", "elements": els,
                "beats": [beat("不是……"), beat("而是……"), beat(_clipw(title, 22), 7, set={"L": {"opacity": 0.4}}, pulse=["R"])]}
    return None

def plus_scene(text, lang):
    cjk = sum(1 for c in text if ord(c) > 0x2E80)
    is_zh = cjk > 0.3 * max(1, len(text.replace(" ", "")))
    sc = _plus_zh(text) if is_zh else _plus_west(text, lang)
    if not sc:
        return None
    sc = {"anchor": "", "title": sc["title"], "tier": "plus", "caption": sc["kind"], "elements": sc["elements"], "beats": sc["beats"]}
    if layout_issues(sc):
        return None
    return sc


# MARK: 给每段打分（0–100，书内百分位）-------------------------------------------

_KEYS_ZH = "仁義义禮礼智信道德天命性心理氣气善惡恶學学知君子聖圣王政民孝忠恕誠诚中和無无為为有法術术勢势兼愛爱利真空佛"
_KEYS_W = ["reason", "virtue", "good", "soul", "truth", "god", "being", "nature", "knowledge", "justice", "freedom", "idea", "substance",
           "mind", "cause", "will", "happiness", "existence", "world", "experience", "law", "form", "essence",
           "vernunft", "wahrheit", "geist", "sein", "wesen", "begriff", "welt", "gott", "freiheit", "erkenntnis", "erfahrung", "satz",
           "wille", "mensch", "übermensch", "leben", "logik", "sprache", "ding", "tatsache", "notwendig", "a priori",
           "âme", "dieu", "monade", "raison", "deus", "mens", "anima", "cogito"]
_NOISE = ["[Footnote", "Footnote", "CHAP.", "Translator", "Project Gutenberg", "BOOK ", "SECTION", "ARTICLE", "Reply Obj", "Objection"]

def raw_score(text, lang):
    cjk = sum(1 for c in text if ord(c) > 0x2E80)
    zh = cjk > 0.3 * max(1, len(text.replace(" ", "")))
    s = 0.0
    if any(n in text for n in _NOISE):
        s -= 30
    if zh:
        n = len(text)
        if n < 8: return -50
        dens = sum(text.count(c) for c in _KEYS_ZH) / n * 100
        s += min(40, dens * 2.2)
        s += 20 if 10 <= n <= 80 else (8 if n <= 160 else -min(25, (n - 160) / 20))
        if _re.match(r"^(子曰|孔子曰|孟子曰|老子曰|莊子曰|荀子曰|曾子曰|有子曰)", text): s += 10
    else:
        low = text.lower()
        words = max(1, len(text.split()))
        if words < 5: return -50
        dens = sum(low.count(k) for k in _KEYS_W) / words * 100
        s += min(40, dens * 3)
        s += 20 if 12 <= words <= 60 else (8 if words <= 120 else -min(25, (words - 120) / 25))
        m = _re.match(r"^(\d+(?:\.\d+)*)\s", text)
        if m: s += max(0, 14 - 3 * len(m.group(1).replace(".", "")))   # 维特根斯坦：主命题优先
    if plus_scene(text, lang): s += 15
    return s

def score_book(paras, lang):
    raws = [raw_score(p, lang) for p in paras]
    order = sorted(range(len(paras)), key=lambda i: raws[i])
    pct = [0] * len(paras)
    for rank, i in enumerate(order):
        pct[i] = round(100 * rank / max(1, len(paras) - 1))
    return pct
