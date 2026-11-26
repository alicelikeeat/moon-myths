"""为每位人物在 Wikidata 中查找“描绘了此人”的作品（胸像、雕塑、画像、照片），
带出作者、年代、收藏机构、馆藏编号、版权状态与馆方藏品页链接，并检查链接能否打开。
在 GitHub Actions 里运行（需要联网）。输入 fame.json（含 qid），输出 candidates.json。"""
import json, sys, time, urllib.parse, urllib.request
UA = {"User-Agent": "PureApp/1.0 (https://github.com/alicelikeeat/moon-myths) statue research"}

def get(url, timeout=40):
    for k in range(2):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout) as r:
                return r.read()
        except Exception as e:
            err = e; time.sleep(2)
    print("FAIL", url[:120], err, file=sys.stderr)
    return None

def status(url):
    try:
        req = urllib.request.Request(urllib.parse.quote(url, safe=":/?=&%#+,;~@!$'()*"), headers=UA)
        with urllib.request.urlopen(req, timeout=20) as r: return r.status
    except urllib.error.HTTPError as e: return e.code
    except Exception as e: return str(e)[:60]

# 机构的外部编号 → 藏品页
EXT = {
    "P3634": "https://www.metmuseum.org/art/collection/search/{}",
    "P9394": "https://collections.louvre.fr/ark:/53355/{}",
    "P1711": "https://www.britishmuseum.org/collection/object/{}",
    "P4659": "https://www.musee-orsay.fr/fr/oeuvres/{}",
    "P350": "https://rkd.nl/explore/images/{}",
    "P8737": "https://www.npg.org.uk/collections/search/portrait/{}",
    "P4704": "https://americanart.si.edu/artwork/{}",
    "P4400": "https://www.nga.gov/collection/art-object-page.{}.html",
    "P9123": "https://collection.cooperhewitt.org/objects/{}",
    "P7704": "https://www.europeana.eu/item/{}",
}
TYPES = {"Q241045": "bust", "Q860861": "sculpture", "Q179700": "statue", "Q3305213": "painting", "Q125191": "photo",
         "Q93184": "drawing", "Q11060274": "print", "Q11835431": "relief", "Q18761202": "statue", "Q4989906": "monument",
         "Q1153484": "relief", "Q15727816": "painting", "Q131597974": "photo"}

def query(qid):
    ext = " ".join(f"OPTIONAL {{ ?w wdt:{p} ?{p} }}" for p in EXT)
    sel = " ".join(f"(SAMPLE(?{p}) AS ?{p}s)" for p in EXT)
    q = f"""
SELECT ?w (SAMPLE(?t) AS ?type) (SAMPLE(?wl) AS ?label) (SAMPLE(?cl) AS ?creator) (SAMPLE(?inc) AS ?inception)
       (SAMPLE(?coll) AS ?collection) (SAMPLE(?inv0) AS ?inv) (SAMPLE(?u) AS ?url) (SAMPLE(?cs) AS ?copyright) (SAMPLE(?mat) AS ?material) {sel}
WHERE {{
  ?w wdt:P180 wd:{qid} ; wdt:P31 ?t .
  VALUES ?t {{ {' '.join('wd:' + k for k in TYPES)} }}
  OPTIONAL {{ ?w rdfs:label ?wl FILTER(LANG(?wl) IN ("en")) }}
  OPTIONAL {{ ?w wdt:P170 ?c . ?c rdfs:label ?cl FILTER(LANG(?cl) = "en") }}
  OPTIONAL {{ ?w wdt:P571 ?inc }}
  OPTIONAL {{ ?w wdt:P195 ?co . ?co rdfs:label ?coll FILTER(LANG(?coll) = "en") }}
  OPTIONAL {{ ?w wdt:P217 ?inv0 }}
  OPTIONAL {{ ?w wdt:P973 ?u }}
  OPTIONAL {{ ?w wdt:P6216 ?cst . ?cst rdfs:label ?cs FILTER(LANG(?cs) = "en") }}
  OPTIONAL {{ ?w wdt:P186 ?m . ?m rdfs:label ?mat FILTER(LANG(?mat) = "en") }}
  {ext}
}} GROUP BY ?w LIMIT 80"""
    b = get("https://query.wikidata.org/sparql?format=json&query=" + urllib.parse.quote(q))
    if not b: return []
    out = []
    for r in json.loads(b)["results"]["bindings"]:
        v = {k: x["value"] for k, x in r.items()}
        item = {"wikidata": v["w"], "type": TYPES.get(v.get("type", "").rsplit("/", 1)[-1], "other"),
                "label": v.get("label"), "creator": v.get("creator"), "inception": (v.get("inception") or "")[:10] or None,
                "collection": v.get("collection"), "inv": v.get("inv"), "copyright": v.get("copyright"), "material": v.get("material")}
        urls = [v["url"]] if v.get("url") else []
        for p, pat in EXT.items():
            if v.get(p + "s"): urls.append(pat.format(v[p + "s"]))
        item["urls"] = urls
        out.append(item)
    return out

fame = json.load(open("fame.json"))
only = set(sys.argv[1:])
res = {}
for tid, rec in fame.items():
    if only and tid not in only: continue
    qid = rec.get("qid")
    if not qid: res[tid] = {"qid": None, "works": []}; continue
    works = query(qid)
    for w in works:
        w["url_status"] = {u: status(u) for u in w["urls"][:3]}
    res[tid] = {"qid": qid, "works": works}
    print(tid, qid, len(works), flush=True)
    time.sleep(1)
json.dump(res, open("candidates.json", "w"), ensure_ascii=False, indent=1)
