"""candidates.json（Wikidata 线索 + 链接校验）→ 合并进 Sources/statues.json
人工核对过的记录（孔子、康德、罗素）保持不动；其余每人挑一件主原型、两件备选。
用法：python3 tools/statues/build.py candidates.json"""
import json, re, sys, os
ROOT = os.path.join(os.path.dirname(__file__), "../..")
cand = json.load(open(sys.argv[1]))
museums = json.load(open(sys.argv[2])) if len(sys.argv) > 2 else {}

def mtype(k):
    k = k or ""
    for key, t in (("sculpt", "sculpture"), ("bust", "bust"), ("medal", "relief"), ("relief", "relief"), ("photograph", "photo"),
                   ("print", "print"), ("drawing", "drawing"), ("paint", "painting")):
        if key in k: return t
    return "other"

europe = json.load(open(sys.argv[3])) if len(sys.argv) > 3 else {}
PORTRAIT = re.compile(r"portr|bildnis|bust|büste|buste|head of|medal|médaille|medaille|ritratto|retrato", re.I)

def rights(u):
    u = u or ""
    if "publicdomain/mark" in u: return ("公有领域标记（PDM）", True, False)
    if "publicdomain/zero" in u: return ("CC0", True, False)
    if "licenses/by-sa" in u: return ("CC BY-SA", False, True)
    if "licenses/by/" in u or u.rstrip("/").endswith("licenses/by"): return ("CC BY", False, True)
    return (u or "未载", False, False)

# Europeana：开放可再利用的肖像。1850 年以后出生的人，标题须含全名，避免同姓者误配
FULL = {"wittgenstein": "ludwig wittgenstein", "russell": "bertrand russell", "james": "william james", "hilbert": "david hilbert",
        "cantor": "georg cantor", "dedekind": "richard dedekind", "riemann": "riemann", "boole": "george boole", "godel": "gödel",
        "mill": "mill", "marx": "karl marx", "sartre": "sartre", "camus": "camus", "heidegger": "martin heidegger", "nietzsche": "nietzsche"}
for tid, hits in europe.items():
    lst = cand.setdefault(tid, {"qid": None, "works": []})["works"]
    for h in hits:
        if tid in FULL and FULL[tid] not in (h.get("title") or "").lower(): continue
        lab, pd, by = rights(h.get("rights"))
        t = h.get("title") or ""
        typ = "bust" if re.search(r"bust|büste|buste", t, re.I) else ("relief" if re.search(r"medal|médaille|medaille", t, re.I) else ("photo" if re.search(r"foto|photo", t, re.I) else "image"))
        ok = h.get("url") and h.get("url_status") == 200
        lst.append({"wikidata": None, "type": typ, "label": t, "creator": h.get("creator"), "inception": h.get("year"),
                    "collection": h.get("provider"), "inv": None, "copyright": "public domain" if pd else None, "material": None,
                    "urls": [h["url"]] if ok else [], "url_status": {h["url"]: 200} if ok else {},
                    "license": f"{lab}（{h.get('rights')}）" if h.get("rights") else lab, "pd": pd, "by": by})

# 开放馆藏接口的结果并入候选（许可由接口直接给出）；只收像是肖像的条目
for tid, hits in museums.items():
    lst = cand.setdefault(tid, {"qid": None, "works": []})["works"]
    for h in hits:
        if not PORTRAIT.search(h.get("title") or ""): continue
        lst.append({"wikidata": None, "type": mtype(h.get("kind")), "label": h.get("title"), "creator": h.get("creator"),
                    "inception": str(h["begin"]) if h.get("begin") not in (None, "") else None, "collection": h.get("museum"),
                    "inv": h.get("inv"), "copyright": "public domain" if h.get("pd") else None, "material": h.get("medium"),
                    "urls": [h["url"]] if h.get("url") else [], "url_status": {h["url"]: 200} if h.get("url") else {},
                    "license": h.get("license"), "pd": h.get("pd")})
doc = json.load(open(f"{ROOT}/Sources/statues.json"))
manual = {r["id"] for r in doc["records"]}

src = open(f"{ROOT}/Sources/Timeline.swift").read()
people = {m[0]: (m[1], m[2], int(m[3]), int(m[4])) for m in
          re.findall(r'Thinker\(id: "([^"]+)", name: "([^"]+)", region: \.(\w+), born: (-?\d+), died: (-?\d+)', src)}

TYPE_ZH = {"image": "肖像图像", "bust": "胸像", "sculpture": "雕塑", "statue": "立像", "relief": "浮雕", "painting": "画像", "drawing": "素描",
           "print": "版画", "photo": "照片", "monument": "纪念像", "other": "图像"}
PRIO = {"image": 3, "bust": 6, "sculpture": 5, "statue": 4, "painting": 4, "photo": 4, "relief": 3, "drawing": 3, "print": 2, "monument": 1, "other": 0}

def year(w):
    m = re.match(r"(-?\d{1,4})", w.get("inception") or "")
    return int(m.group(1)) if m else None

def ok_url(w):
    for u, s in (w.get("url_status") or {}).items():
        if s == 200: return u
    return None

def score(w, born, died):
    s = PRIO.get(w["type"], 0) * 2
    if w.get("collection"): s += 2
    if w.get("inv"): s += 2
    if ok_url(w): s += 9            # 能打开的馆方页优先
    y = year(w)
    if y is not None and born - 5 <= y <= died + 5: s += 4
    if (w.get("copyright") or "").lower().startswith("public domain"): s += 2
    if w["type"] == "photo" and died < 1840: s -= 10
    if w.get("pd"): s += 3          # 明确标为公有领域 / CC0
    elif w.get("by"): s += 2        # CC BY / BY-SA：可改编，需署名
    return s

def wd(u): return u.replace("http://www.wikidata.org/entity/", "https://www.wikidata.org/wiki/")

def yrs(y): return f"前 {-y}" if y < 0 else f"{y}"

def kind_of(w, died):
    y = year(w)
    posthumous = y is not None and y > died + 30
    if w["type"] in ("bust", "sculpture", "statue", "relief", "monument"):
        return ("tradition", "据后世传统形象建模") if posthumous else ("sculpture", "据雕塑建模")
    if w["type"] == "photo": return ("photo", "据历史影像重建")
    return ("tradition", "据后世传统形象建模") if posthumous else ("portrait", "据画像建模")

FEATURES = {
    "sculpture": ["头部外轮廓与面部比例", "发型", "衣领与胸像截断方式"],
    "portrait": ["头部外轮廓与面部比例", "发型或头饰", "衣领与服饰"],
    "photo": ["发际线与发型", "头部侧影", "衣领"],
    "tradition": ["冠饰或发型", "须发与面部轮廓", "衣领与服饰"],
}

records = []
for tid, (name, region, born, died) in people.items():
    if tid in manual: continue
    c = cand.get(tid) or {"works": []}
    works = sorted(c["works"], key=lambda w: -score(w, born, died))
    sitter = f"{name} {yrs(born)}—{yrs(died)} 年"
    verification = "Wikidata、Europeana 与开放馆藏接口检索 + 馆方链接可达性校验（2026-11-26），尚未逐件人工核对作品身份与图像"
    if not works:
        records.append({
            "id": tid, "kind": "none", "kindLabel": "原型待查", "status": "待考",
            "work": "未找到有馆藏记录的原型", "author": "未载", "date": "未载", "sitterDates": sitter,
            "institution": "未载", "accession": "未载",
            "url": f"https://www.wikidata.org/wiki/{c.get('qid')}" if c.get("qid") else "https://www.wikidata.org",
            "reason": "Wikidata、Europeana 与大都会、芝加哥、克利夫兰三家开放馆藏接口中，都没有找到标题含此人名字、且带收藏信息的胸像、雕塑、画像或照片。",
            "relation": "未载",
            "features": [{"name": n, "state": "待对照"} for n in FEATURES["tradition"]],
            "inferred": ["在找到原型之前，全部造型均为推定"],
            "usage": {"original": "未载", "reference": "未载", "existing3D": "未查", "license": "未载",
                      "attribution": "未载", "adapt": "待核", "distribute": "待核", "thumbnail": "待核"},
            "model": None, "pending": ["在博物馆、图书馆、档案馆中查找有明确馆藏记录的画像或雕塑"],
            "alternates": [], "verification": verification})
        continue
    w = works[0]
    kind, label = kind_of(w, died)
    y = year(w)
    if y is None: relation = "作品年代未载，与人物本人的关系待查。"
    elif y <= died + 5 and y >= born: relation = f"生前作品：作于 {yrs(y)} 年，{name}时年约 {y - born} 岁。"
    elif y > died: relation = f"身后作品：晚于{name}去世约 {y - died} 年，反映后世对其形象的理解，并非写真。"
    else: relation = f"作品年代（{yrs(y)}）早于人物生年，记录可能有误，待查。"
    url = ok_url(w)
    inst = w.get("collection") or "未载"
    reason = (f"在 Wikidata、Europeana 与开放馆藏接口中找到描绘{name}的作品 {len(works)} 件；此件为{TYPE_ZH.get(w['type'], '图像')}"
              f"{'，作于人物生前' if (y is not None and born <= y <= died + 5) else ''}"
              f"{'，收藏机构与编号齐全' if w.get('collection') and w.get('inv') else '，收藏信息不全'}"
              f"{'，馆方页面可以打开' if url else '，未找到可打开的馆方页面'}。")
    cr = w.get("copyright") or ""
    alts = []
    for a in works[1:]:
        au = ok_url(a) or (wd(a["wikidata"]) if a.get("wikidata") else "")
        alts.append({"work": f"{a.get('label') or '未载'}（{TYPE_ZH.get(a['type'], '图像')}，{a.get('creator') or '作者未载'}，{(a.get('inception') or '年代未载')[:4]}）",
                     "institution": f"{a.get('collection') or '收藏未载'}{('，编号 ' + a['inv']) if a.get('inv') else ''}", "url": au})
        if len(alts) == 2: break
    records.append({
        "id": tid, "kind": kind, "kindLabel": label, "status": "待考",
        "work": w.get("label") or "未载",
        "author": w.get("creator") or "未载",
        "date": (f"{yrs(y)} 年" if y is not None else "未载") + (f"，{w['material']}" if w.get("material") else ""),
        "sitterDates": sitter,
        "institution": inst, "accession": w.get("inv") or "未载",
        "url": url or (wd(w["wikidata"]) if w.get("wikidata") else ""),
        "reason": reason, "relation": relation,
        "features": [{"name": n, "state": "待对照"} for n in FEATURES[kind]],
        "inferred": ["在取得同一件原作的多角度资料之前，侧面与背面为推定", "材质统一为白石，属视觉简化"],
        "usage": {"original": "公有领域（据 Wikidata 版权状态）" if cr.lower().startswith("public domain") else (f"Wikidata 版权状态：{cr}" if cr else "未载"),
                  "reference": (f"开放许可：{w['license']}" if (w.get("pd") or w.get("by")) else "馆方图像的使用条件未核"), "existing3D": "未查",
                  "license": (w.get("license") or "未载"),
                  "attribution": f"{inst}{(', ' + w['inv']) if w.get('inv') else ''}",
                  "adapt": "允许（公有领域）" if w.get("pd") else ("允许，须署名" + ("并以相同许可分享" if "SA" in (w.get("license") or "") else "") if w.get("by") else "待核"),
                  "distribute": "允许" if (w.get("pd") or w.get("by")) else "待核",
                  "thumbnail": "条件允许，本版不内嵌，链接馆方页" if (w.get("pd") or w.get("by")) else "待核"},
        "model": None,
        "pending": (["人工打开馆方藏品页，核对作品身份、年代与图像"] if url else ["找到该作品的馆方藏品页（目前只有 Wikidata 线索）"])
                   + ["确认图像或扫描的使用许可", "逐项对照三项造型特征"],
        "alternates": alts, "verification": verification})

# 同一人的另一个条目（笛卡尔的数学身份）沿用同一份原型记录
by = {r["id"]: r for r in records}
if "descartes" in by and "descartes-geometry" in by:
    by["descartes-geometry"].update({k: v for k, v in by["descartes"].items() if k not in ("id", "sitterDates")})
order = {k: i for i, k in enumerate(people)}
doc["records"] = sorted([r for r in doc["records"]] + records, key=lambda r: order.get(r["id"], 999))
for r in doc["records"]:
    r.setdefault("verification", "人工打开馆方藏品页核对（2026-11-26）")
json.dump(doc, open(f"{ROOT}/Sources/statues.json", "w"), ensure_ascii=False, indent=1)
kinds = {}
for r in doc["records"]: kinds[r["kindLabel"]] = kinds.get(r["kindLabel"], 0) + 1
print(len(doc["records"]), kinds)
print("可打开馆方页：", sum(1 for r in records if not r["url"].startswith("https://www.wikidata.org")), "/", len(records))
