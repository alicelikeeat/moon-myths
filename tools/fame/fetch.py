"""抓取每位思想家的客观指标：维基数据语种数、维基百科浏览量、"受其影响"条数、斯坦福哲学百科条目篇幅、Pantheon 历史影响指数。
在 GitHub Actions 里运行（需要联网），输出 fame.json。"""
import json, re, sys, time, urllib.parse, urllib.request

UA = {"User-Agent": "PureApp/1.0 (https://github.com/alicelikeeat/moon-myths) research script"}

# id -> (英文维基条目, 斯坦福哲学百科条目 slug 或 None)
T = {
 "laozi": ("Laozi", "laozi"), "kongzi": ("Confucius", "confucius"), "mozi": ("Mozi", "mohism"),
 "mengzi": ("Mencius", "mencius"), "zhuangzi": ("Zhuangzi (philosopher)", "zhuangzi"), "xunzi": ("Xunzi (philosopher)", "xunzi"),
 "hanfei": ("Han Fei", "chinese-legalism"), "dongzhongshu": ("Dong Zhongshu", None), "huineng": ("Huineng", None),
 "zhuxi": ("Zhu Xi", "zhu-xi"), "wangyangming": ("Wang Yangming", "wang-yangming"), "wangfuzhi": ("Wang Fuzhi", None),
 "zhouyi": ("I Ching", None), "guanzhong": ("Guan Zhong", None), "sunwu": ("Sun Tzu", None),
 "zisi": ("Zisi", None), "liezi": ("Liezi", None), "gongsunlong": ("Gongsun Long", "school-names"),
 "wangchong": ("Wang Chong", "wang-chong"), "zhoudunyi": ("Zhou Dunyi", None), "zhangzai": ("Zhang Zai", None),
 "ercheng": ("Cheng Yi (philosopher)", "cheng-yi"), "luxiangshan": ("Lu Jiuyuan", None), "guyanwu": ("Gu Yanwu", None),
 "socrates": ("Socrates", "socrates"), "plato": ("Plato", "plato"), "aristotle": ("Aristotle", "aristotle"),
 "lucretius": ("Lucretius", "lucretius"), "epictetus": ("Epictetus", None), "marcusaurelius": ("Marcus Aurelius", "marcus-aurelius"),
 "augustine": ("Augustine of Hippo", "augustine"), "aquinas": ("Thomas Aquinas", "aquinas"), "machiavelli": ("Niccolò Machiavelli", "machiavelli"),
 "hobbes": ("Thomas Hobbes", "hobbes"), "descartes": ("René Descartes", "descartes"), "pascal": ("Blaise Pascal", "pascal"),
 "spinoza": ("Baruch Spinoza", "spinoza"), "locke": ("John Locke", "locke"), "leibniz": ("Gottfried Wilhelm Leibniz", "leibniz"),
 "berkeley": ("George Berkeley", "berkeley"), "hume": ("David Hume", "hume"), "rousseau": ("Jean-Jacques Rousseau", "rousseau"),
 "kant": ("Immanuel Kant", "kant"), "hegel": ("Georg Wilhelm Friedrich Hegel", "hegel"), "schopenhauer": ("Arthur Schopenhauer", "schopenhauer"),
 "kierkegaard": ("Søren Kierkegaard", "kierkegaard"), "mill": ("John Stuart Mill", "mill"), "marx": ("Karl Marx", "marx"),
 "nietzsche": ("Friedrich Nietzsche", "nietzsche"), "james": ("William James", "james"), "russell": ("Bertrand Russell", "russell"),
 "wittgenstein": ("Ludwig Wittgenstein", "wittgenstein"), "heidegger": ("Martin Heidegger", "heidegger"), "sartre": ("Jean-Paul Sartre", "sartre"),
 "camus": ("Albert Camus", "camus"), "euclid": ("Euclid", None), "liuhui": ("Liu Hui", None),
 "archimedes": ("Archimedes", None), "zhaoshuang": ("Zhao Shuang", None), "newton": ("Isaac Newton", "newton"),
 "descartes-geometry": ("La Géométrie", "descartes-mathematics"),
}

def get(url, tries=2, timeout=20):
    for k in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout) as r:
                return r.read()
        except Exception as e:
            err = e; time.sleep(1 + k * 2)
    print("FAIL", url, err, file=sys.stderr)
    return None

def jget(url, **kw):
    b = get(url, **kw)
    return json.loads(b) if b else None

out = {}
pantheon_ok = True
for tid, (en, sep) in T.items():
    rec = {"en": en}
    q = jget("https://en.wikipedia.org/w/api.php?action=query&format=json&redirects=1&prop=pageprops&titles=" + urllib.parse.quote(en))
    try:
        page = next(iter(q["query"]["pages"].values()))
        rec["en"] = page["title"]; qid = page["pageprops"]["wikibase_item"]
    except Exception:
        print("no qid", tid, file=sys.stderr); out[tid] = rec; continue
    rec["qid"] = qid
    ent = jget(f"https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&props=sitelinks&ids={qid}")
    links = ent["entities"][qid].get("sitelinks", {}) if ent else {}
    rec["langs"] = sum(1 for k in links if k.endswith("wiki") and k not in ("commonswiki", "specieswiki", "metawiki"))
    rec["zh"] = links.get("zhwiki", {}).get("title")
    views = {}
    for lang, title in (("en", rec["en"]), ("zh", rec["zh"])):
        if not title: continue
        u = (f"https://wikimedia.org/api/rest_v1/metrics/pageviews/per-article/{lang}.wikipedia/all-access/user/"
             f"{urllib.parse.quote(title.replace(' ', '_'), safe='')}/monthly/2025110100/2026103100")
        d = jget(u)
        views[lang] = sum(i["views"] for i in d["items"]) if d and "items" in d else None
    rec["views"] = views
    sparql = f"SELECT (COUNT(DISTINCT ?x) AS ?c) WHERE {{ {{ ?x wdt:P737 wd:{qid} }} UNION {{ wd:{qid} wdt:P1299 ?x }} }}"
    s = jget("https://query.wikidata.org/sparql?format=json&query=" + urllib.parse.quote(sparql))
    try: rec["influenced"] = int(s["results"]["bindings"][0]["c"]["value"])
    except Exception: rec["influenced"] = None
    if pantheon_ok:
        p = jget(f"https://api.pantheon.world/person?wd_id=eq.{qid}&select=name,hpi,l,occupation", tries=1, timeout=12)
        if p is None: pantheon_ok = False
        elif p: rec["pantheon"] = p[0]
    if sep:
        h = get(f"https://plato.stanford.edu/entries/{sep}/", tries=1, timeout=20)
        if h:
            txt = re.sub(r"<[^>]+>", " ", h.decode("utf-8", "ignore"))
            rec["sep"] = {"slug": sep, "words": len(txt.split())}
    out[tid] = rec
    print(tid, json.dumps(rec, ensure_ascii=False), flush=True)
    time.sleep(0.2)

json.dump(out, open("fame.json", "w"), ensure_ascii=False, indent=1)
