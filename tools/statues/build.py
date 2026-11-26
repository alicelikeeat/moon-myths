"""candidates.json（Wikidata 线索 + 链接校验）→ 合并进 Sources/statues.json
人工核对过的记录（孔子、康德、罗素）保持不动；其余每人挑一件主原型、两件备选。
用法：python3 tools/statues/build.py candidates.json"""
import json, re, sys, os
ROOT = os.path.join(os.path.dirname(__file__), "../..")
cand = json.load(open(sys.argv[1]))
doc = json.load(open(f"{ROOT}/Sources/statues.json"))
manual = {r["id"] for r in doc["records"]}

src = open(f"{ROOT}/Sources/Timeline.swift").read()
people = {m[0]: (m[1], m[2], int(m[3]), int(m[4])) for m in
          re.findall(r'Thinker\(id: "([^"]+)", name: "([^"]+)", region: \.(\w+), born: (-?\d+), died: (-?\d+)', src)}

TYPE_ZH = {"bust": "胸像", "sculpture": "雕塑", "statue": "立像", "relief": "浮雕", "painting": "画像", "drawing": "素描",
           "print": "版画", "photo": "照片", "monument": "纪念像", "other": "图像"}
PRIO = {"bust": 6, "sculpture": 5, "statue": 4, "painting": 4, "photo": 4, "relief": 3, "drawing": 3, "print": 2, "monument": 1, "other": 0}

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
    if ok_url(w): s += 5
    y = year(w)
    if y is not None and born - 5 <= y <= died + 5: s += 4
    if (w.get("copyright") or "").lower().startswith("public domain"): s += 2
    if w["type"] == "photo" and died < 1840: s -= 10
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
    verification = "Wikidata 线索 + 馆方链接可达性校验（2026-11-26），尚未逐件人工核对作品身份与图像"
    if not works:
        records.append({
            "id": tid, "kind": "none", "kindLabel": "原型待查", "status": "待考",
            "work": "未找到有馆藏记录的原型", "author": "未载", "date": "未载", "sitterDates": sitter,
            "institution": "未载", "accession": "未载",
            "url": f"https://www.wikidata.org/wiki/{c.get('qid')}" if c.get("qid") else "https://www.wikidata.org",
            "reason": "Wikidata 中没有记载描绘此人、且带收藏信息的胸像、雕塑、画像或照片。",
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
    reason = (f"Wikidata 记载描绘{name}的作品共 {len(works)} 件；此件为{TYPE_ZH.get(w['type'], '图像')}"
              f"{'，作于人物生前' if (y is not None and born <= y <= died + 5) else ''}"
              f"{'，收藏机构与编号齐全' if w.get('collection') and w.get('inv') else '，收藏信息不全'}"
              f"{'，馆方页面可以打开' if url else '，未找到可打开的馆方页面'}。")
    cr = w.get("copyright") or ""
    alts = []
    for a in works[1:]:
        au = ok_url(a) or wd(a["wikidata"])
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
        "url": url or wd(w["wikidata"]),
        "reason": reason, "relation": relation,
        "features": [{"name": n, "state": "待对照"} for n in FEATURES[kind]],
        "inferred": ["在取得同一件原作的多角度资料之前，侧面与背面为推定", "材质统一为白石，属视觉简化"],
        "usage": {"original": "公有领域（据 Wikidata 版权状态）" if cr.lower().startswith("public domain") else (f"Wikidata 版权状态：{cr}" if cr else "未载"),
                  "reference": "馆方图像的使用条件未核", "existing3D": "未查", "license": "未载",
                  "attribution": f"{inst}{(', ' + w['inv']) if w.get('inv') else ''}",
                  "adapt": "待核", "distribute": "待核", "thumbnail": "待核"},
        "model": None,
        "pending": (["人工打开馆方藏品页，核对作品身份、年代与图像"] if url else ["找到该作品的馆方藏品页（目前只有 Wikidata 线索）"])
                   + ["确认图像或扫描的使用许可", "逐项对照三项造型特征"],
        "alternates": alts, "verification": verification})

order = {k: i for i, k in enumerate(people)}
doc["records"] = sorted([r for r in doc["records"]] + records, key=lambda r: order.get(r["id"], 999))
for r in doc["records"]:
    r.setdefault("verification", "人工打开馆方藏品页核对（2026-11-26）")
json.dump(doc, open(f"{ROOT}/Sources/statues.json", "w"), ensure_ascii=False, indent=1)
kinds = {}
for r in doc["records"]: kinds[r["kindLabel"]] = kinds.get(r["kindLabel"], 0) + 1
print(len(doc["records"]), kinds)
print("可打开馆方页：", sum(1 for r in records if not r["url"].startswith("https://www.wikidata.org")), "/", len(records))
