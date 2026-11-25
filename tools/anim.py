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

def save(text_id):
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
    os.makedirs(os.path.join(ROOT, "anims"), exist_ok=True)
    out = os.path.join(ROOT, "anims", f"{text_id}.json")
    json.dump({"id": text_id, "scenes": _scenes}, open(out, "w", encoding="utf-8"),
              ensure_ascii=False, separators=(",", ":"))
    print(f"{text_id}: {len(_scenes)} 个段落动画，覆盖 {len(used)}/{len(paras)} 段")


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
