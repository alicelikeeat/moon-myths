"""第三轮：Europeana（欧洲各博物馆、图书馆、档案馆的聚合目录）检索人物肖像。
只收开放可再利用的图像（reusability=open），标题须含此人名字且像是肖像（portrait / Bildnis / bust 等），
带出提供机构、机构藏品页（edmIsShownAt）、许可（rights）与年代。输出 europeana.json。"""
import json, re, sys, time, urllib.parse, urllib.request
UA = {"User-Agent": "PureApp/1.0 (https://github.com/alicelikeeat/moon-myths) statue research"}

def jget(url):
    for k in range(2):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30) as r:
                return json.loads(r.read())
        except Exception as e:
            err = e; time.sleep(1.5)
    print("FAIL", url[:100], err, file=sys.stderr)
    return None

def status(url):
    try:
        with urllib.request.urlopen(urllib.request.Request(urllib.parse.quote(url, safe=":/?=&%#+,;~@!$'()*"), headers=UA), timeout=20) as r: return r.status
    except urllib.error.HTTPError as e: return e.code
    except Exception as e: return str(e)[:60]

src = open("Sources/Names.swift").read()
names = {m[0]: (m[1], m[3]) for m in re.findall(r'^    "([^"]+)": \("([^"]+)", "([^"]+)", "([^"]+)"\)', src, re.M)}
SKIP = {"zhouyi", "ercheng", "descartes-geometry"}
PORTRAIT = re.compile(r"portr|bildnis|bust|büste|buste|ritratto|retrato|porträt|kop|head|medail|medal|médaille|gedenkmünze", re.I)
out = {}
for tid, (en, de) in names.items():
    if tid in SKIP: continue
    keys = {en, de}
    hits = []
    for key in keys:
        last = key.split()[-1]
        q = urllib.parse.quote(f'title:"{key}"' if len(key.split()) > 1 or len(key) > 5 else f'title:"{key}" AND what:portrait')
        d = jget(f"https://api.europeana.eu/record/v2/search.json?wskey=api2demo&query={q}&qf=TYPE:IMAGE&reusability=open&rows=40&profile=rich")
        for it in (d or {}).get("items") or []:
            title = (it.get("title") or [""])[0]
            if last.lower() not in title.lower() or not PORTRAIT.search(title): continue
            shown = (it.get("edmIsShownAt") or [None])[0]
            hits.append({"title": title, "provider": (it.get("dataProvider") or [""])[0], "country": (it.get("country") or [""])[0],
                         "year": (it.get("year") or [None])[0], "creator": (it.get("dcCreator") or [None])[0],
                         "rights": (it.get("rights") or [""])[0], "europeana": it.get("guid"), "url": shown})
        time.sleep(0.3)
    # 去重、只保留前 8 条，并检查机构页能否打开
    seen, uniq = set(), []
    for h in hits:
        k = h["europeana"]
        if k in seen: continue
        seen.add(k); uniq.append(h)
    for h in uniq[:8]:
        h["url_status"] = status(h["url"]) if h.get("url") else None
    out[tid] = uniq[:8]
    print(tid, en, len(uniq), flush=True)
json.dump(out, open("europeana.json", "w"), ensure_ascii=False, indent=1)
