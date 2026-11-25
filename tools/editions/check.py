import json, urllib.request, hashlib
UA={'User-Agent':'PurePhilosophyApp/1.0 (github.com/alicelikeeat/moon-myths)'}
d=json.load(open('Sources/editions.json')); rep={}
def fetch(u):
    try:
        with urllib.request.urlopen(urllib.request.Request(u,headers=UA),timeout=40) as r:
            b=r.read(); return r.status, r.headers.get('Content-Type',''), hashlib.md5(b).hexdigest(), len(b)
    except Exception as e: return 0,'','',0
for b,v in d.items():
    for s in v['scans']:
        i=s['ia']
        rep[i]={'cover':fetch(f"https://archive.org/services/img/{i}"),'title':fetch(f"https://archive.org/download/{i}/page/title_w400.jpg"),'n4':fetch(f"https://archive.org/download/{i}/page/n4_w400.jpg")}
    print(b,flush=True)
json.dump(rep,open('check.json','w'),ensure_ascii=False,indent=1)
