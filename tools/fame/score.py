"""合成人物评分 → Sources/fame.json
用法：python3 tools/fame/score.py fame.json [links.json]"""
import json, math, sys, os, re
sys.path.insert(0, os.path.dirname(__file__))
from evidence import E

fame = json.load(open(sys.argv[1]))
# 第二次抓取时这几条请求超时：沿用同一天第一次抓取的结果（条目篇幅缺失，按缺数据处理）
FALLBACK = {
 "newton": {"qid": "Q935", "langs": 239, "views": {"en": 2382399, "zh": 110973}, "influenced": 28, "sep": {"words": 6983}},
 "zhaoshuang": {"qid": "Q706283", "langs": 9, "views": {"en": 477, "zh": 755}, "influenced": 0},
 "descartes-geometry": {"qid": "Q210113", "langs": 19, "views": {"en": 11862}, "influenced": 0, "sep": {"words": 15327}},
}
for k, v in FALLBACK.items():
    if not fame.get(k, {}).get("langs"): fame[k] = {**fame.get(k, {}), **v}
links = json.load(open(sys.argv[2])) if len(sys.argv) > 2 else {}

# 生卒年：从 Timeline.swift 读
src = open(os.path.join(os.path.dirname(__file__), "../../Sources/Timeline.swift")).read()
REGION = {m[0]: m[1] for m in re.findall(r'Thinker\(id: "([^"]+)", name: "[^"]*", region: \.(\w+)', src)}
died = {m[0]: int(m[1]) for m in re.findall(r'Thinker\(id: "([^"]+)", name: "[^"]*", region: \.\w+, born: -?\d+, died: (-?\d+)', src)}

def lg(v): return math.log1p(v) if v else None
def metric(rec):
    p = rec.get("pantheon") or {}
    views = rec.get("views") or {}
    v = sum(x for x in views.values() if x) or None
    ln = max(rec.get("enlen") or 0, rec.get("zhlen") or 0) or None
    return dict(langs=rec.get("langs"), views=v, influenced=rec.get("influenced"),
                len=ln, sep=(rec.get("sep") or {}).get("words"))

M = {k: metric(fame.get(k, {})) for k in E}
def mx(f): return max((lg(m[f]) or 0) for m in M.values()) or 1
MAX = {f: mx(f) for f in ("langs", "views", "influenced", "sep", "len")}

def rel(m, f):
    return None if not m[f] else lg(m[f]) / MAX[f]

def weighted(parts):
    have = [(w, v) for w, v in parts if v is not None]
    if not have: return 0.3
    return sum(w * v for w, v in have) / sum(w for w, _ in have)

def dead_link(u):
    s = links.get(u)
    return s is not None and s != 200

out = {}
for k, ev in E.items():
    m = M[k]
    hist = ev["h"]
    # Wikidata 的影响关系对中国与数学人物几乎没有录入：记为 0 时按“缺数据”处理，而不是 0 分
    infl = rel(m, "influenced")
    if not m["influenced"] and REGION.get(k) != "west": infl = None
    scholar = round(25 * weighted([(0.35, infl), (0.35, rel(m, "sep")), (0.3, rel(m, "len"))]))
    popular = round(20 * weighted([(0.6, rel(m, "views")), (0.4, rel(m, "langs"))]))
    offs = [o for o in ev["off"] if not dead_link(o[1])]
    official = max(0, min(15, 4 + sum(o[2] for o in offs)))
    yrs = max(1, 2026 - died.get(k, 1900))
    time_ = round(10 * math.log10(1 + yrs) / math.log10(1 + 2600))
    total = hist + scholar + popular + official + time_
    out[k] = dict(total=total, parts=dict(hist=hist, scholar=scholar, popular=popular, official=official, time=time_),
                  hist=[dict(t=t, u=u) for t, u in ev["hist"] if not dead_link(u)],
                  off=[dict(t=t, u=u, p=p) for t, u, p in offs],
                  metrics={a: b for a, b in m.items() if b is not None})
order = sorted(out, key=lambda k: -out[k]["total"])
for i, k in enumerate(order): out[k]["rank"] = i + 1

doc = dict(
    rubric=[
        dict(key="hist", name="历史推动", max=30, rule="对制度、宗教、革命、科学的具体推动，按五级标准人工评定，逐条附出处"),
        dict(key="scholar", name="学者评价", max=25, rule="斯坦福哲学百科专条篇幅、Wikidata 影响关系条数、维基百科中英文条目篇幅（对数归一）"),
        dict(key="popular", name="民间热度", max=20, rule="维基百科中英文近 12 个月浏览量与条目语种数（对数归一）"),
        dict(key="official", name="官方认可", max=15, rule="基准 4 分；国家祀典、封号、国葬、货币、国家奖项、UNESCO 名录等逐条加分，处死、禁书、罢祀等逐条减分"),
        dict(key="time", name="历时检验", max=10, rule="去世至今的年代跨度（对数）：经受时间检验越久，得分越高"),
    ],
    scores=out,
    note="说明：学者评价与民间热度的数据源以英文世界为主，会低估部分中国思想家，因此民间热度同时计入中文维基浏览量。"
         "评分只反映可量化的影响力与可查证的事实，不代表对其学说是非的判断。数据抓取于 2026 年 11 月。")
json.dump(doc, open(os.path.join(os.path.dirname(__file__), "../../Sources/fame.json"), "w"), ensure_ascii=False, indent=1)
for k in order: print(out[k]["rank"], k, out[k]["total"], out[k]["parts"])
