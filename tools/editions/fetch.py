import json, urllib.request, urllib.parse, time, sys
sys.path.insert(0, 'tools/editions')
from queries import Q
UA = {'User-Agent': 'PurePhilosophyApp/1.0 (github.com/alicelikeeat/moon-myths)'}
def get(url):
    for _ in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30) as r: return json.load(r)
        except Exception as e: err = e; time.sleep(2)
    return {'error': str(err)}
out = {}
for bid, (ia, cm) in Q.items():
    rec = {'ia': [], 'commons': []}
    for q in ia:
        u = 'https://archive.org/advancedsearch.php?' + urllib.parse.urlencode({'q': q + ' AND mediatype:texts', 'fl[]': ['identifier', 'title', 'date', 'publisher', 'creator', 'downloads', 'language', 'licenseurl', 'possible-copyright-status'], 'rows': 15, 'sort[]': 'downloads desc', 'output': 'json'}, doseq=True)
        d = get(u); rec['ia'] += d.get('response', {}).get('docs', [])
    for q in cm:
        u = 'https://commons.wikimedia.org/w/api.php?' + urllib.parse.urlencode({'action': 'query', 'format': 'json', 'generator': 'search', 'gsrsearch': q, 'gsrnamespace': 6, 'gsrlimit': 12, 'prop': 'imageinfo', 'iiprop': 'url|size|extmetadata|mime', 'iiurlwidth': 600})
        d = get(u)
        for p in (d.get('query', {}).get('pages', {}) or {}).values():
            ii = (p.get('imageinfo') or [{}])[0]; m = ii.get('extmetadata', {})
            rec['commons'].append({'title': p['title'], 'thumb': ii.get('thumburl'), 'mime': ii.get('mime'), 'w': ii.get('width'), 'h': ii.get('height'),
                'license': m.get('LicenseShortName', {}).get('value'), 'desc': (m.get('ImageDescription', {}).get('value') or '')[:300], 'date': (m.get('DateTimeOriginal', {}).get('value') or '')[:100]})
        time.sleep(0.5)
    out[bid] = rec
    print(bid, len(rec['ia']), len(rec['commons']), flush=True)
json.dump(out, open('candidates.json', 'w'), ensure_ascii=False, indent=1)
