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
        if isinstance(s["anchor"], int):          # 用段落序号写，自动取开头作为定位
            s["anchor"] = paras[s["anchor"]][:14]
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
