"""第二轮：检索三家开放馆藏 API（大都会艺术博物馆、芝加哥艺术博物馆、克利夫兰艺术博物馆），
只收标题中明确含有此人名字的画像、雕塑、版画、照片，带出作者、年代、编号、公有领域 / CC0 状态与藏品页。
输入 Sources/Names.swift（英文名），输出 museums.json。"""
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

names = {m[0]: m[1] for m in re.findall(r'^    "([^"]+)": \("([^"]+)"', open("Sources/Names.swift").read(), re.M)}
SKIP = {"zhouyi", "ercheng", "descartes-geometry"}
GOOD = re.compile(r"paint|sculpt|print|drawing|photograph|medal|bust|relief", re.I)

def match(title, name):
    t = (title or "").lower()
    key = name.lower().replace("j. s. ", "john stuart ")
    last = key.split()[-1]
    # 只收标题里出现全名或姓氏（姓氏至少 4 个字母，避免误配）
    return key in t or (len(last) >= 4 and re.search(r"\b" + re.escape(last) + r"\b", t))

out = {}
for tid, name in names.items():
    if tid in SKIP: continue
    hits = []
    q = urllib.parse.quote(name)
    # 大都会
    s = jget(f"https://collectionapi.metmuseum.org/public/collection/v1/search?q={q}")
    for oid in ((s or {}).get("objectIDs") or [])[:25]:
        o = jget(f"https://collectionapi.metmuseum.org/public/collection/v1/objects/{oid}")
        if not o or not match(o.get("title"), name) or not GOOD.search((o.get("classification") or "") + " " + (o.get("objectName") or "")): continue
        hits.append({"museum": "The Metropolitan Museum of Art", "title": o.get("title"), "creator": o.get("artistDisplayName") or None,
                     "date": o.get("objectDate") or None, "begin": o.get("objectBeginDate"), "inv": o.get("accessionNumber"),
                     "kind": (o.get("classification") or o.get("objectName") or "").lower(), "medium": o.get("medium"),
                     "pd": bool(o.get("isPublicDomain")), "license": "CC0（大都会开放获取）" if o.get("isPublicDomain") else "非公有领域",
                     "url": o.get("objectURL")})
        time.sleep(0.05)
    # 芝加哥
    s = jget(f"https://api.artic.edu/api/v1/artworks/search?q={q}&limit=20&fields=id,title,artist_display,date_display,date_start,main_reference_number,is_public_domain,classification_title,medium_display")
    for o in (s or {}).get("data") or []:
        if not match(o.get("title"), name) or not GOOD.search(o.get("classification_title") or ""): continue
        hits.append({"museum": "Art Institute of Chicago", "title": o.get("title"), "creator": (o.get("artist_display") or "").split("\n")[0] or None,
                     "date": o.get("date_display"), "begin": o.get("date_start"), "inv": o.get("main_reference_number"),
                     "kind": (o.get("classification_title") or "").lower(), "medium": o.get("medium_display"),
                     "pd": bool(o.get("is_public_domain")), "license": "CC0（芝加哥艺术博物馆开放获取）" if o.get("is_public_domain") else "非公有领域",
                     "url": f"https://www.artic.edu/artworks/{o['id']}"})
    # 克利夫兰
    s = jget(f"https://openaccess-api.clevelandart.org/api/artworks/?q={q}&limit=20")
    for o in (s or {}).get("data") or []:
        if not match(o.get("title"), name) or not GOOD.search((o.get("type") or "") + " " + (o.get("technique") or "")): continue
        cre = o.get("creators") or []
        hits.append({"museum": "Cleveland Museum of Art", "title": o.get("title"), "creator": (cre[0].get("description") if cre else None),
                     "date": o.get("creation_date"), "begin": o.get("creation_date_earliest"), "inv": o.get("accession_number"),
                     "kind": (o.get("type") or "").lower(), "medium": o.get("technique"),
                     "pd": o.get("share_license_status") == "CC0", "license": "CC0（克利夫兰艺术博物馆开放获取）" if o.get("share_license_status") == "CC0" else (o.get("share_license_status") or "未载"),
                     "url": o.get("url")})
    out[tid] = hits
    print(tid, name, len(hits), flush=True)
json.dump(out, open("museums.json", "w"), ensure_ascii=False, indent=1)
