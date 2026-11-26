"""逐条检查证据链接能否打开，输出 {url: 状态码}"""
import json, sys, urllib.request, urllib.parse
UA = {"User-Agent": "PureApp/1.0 (https://github.com/alicelikeeat/moon-myths) link check"}
res = {}
for u in sorted(set(l.strip() for l in open(sys.argv[1]) if l.strip())):
    try:
        with urllib.request.urlopen(urllib.request.Request(urllib.parse.quote(u, safe=':/?=&%#'), headers=UA), timeout=12) as r: res[u] = r.status
    except urllib.error.HTTPError as e: res[u] = e.code
    except Exception as e: res[u] = str(e)[:80]
print(json.dumps(res, ensure_ascii=False, indent=1))
