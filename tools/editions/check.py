import json, sys, urllib.request, hashlib
UA={'User-Agent':'PurePhilosophyApp/1.0 (github.com/alicelikeeat/moon-myths)'}
def fetch(u):
    try:
        with urllib.request.urlopen(urllib.request.Request(u,headers=UA),timeout=40) as r:
            b=r.read(); return r.status, r.headers.get('Content-Type',''), hashlib.md5(b).hexdigest(), len(b)
    except Exception: return 0,'','',0
rep={}
for i in sys.argv[1:]:
    try:
        m=json.load(urllib.request.urlopen(urllib.request.Request(f"https://archive.org/metadata/{i}/files",headers=UA),timeout=30))
        pdfs=[f['name'] for f in m.get('result',[]) if f['name'].lower().endswith('.pdf')]
    except Exception: pdfs=[]
    rep[i]={'pdf':pdfs[0] if pdfs else None,'cover':fetch(f"https://archive.org/services/img/{i}"),
            'title':fetch(f"https://archive.org/download/{i}/page/title_w400.jpg"),'n4':fetch(f"https://archive.org/download/{i}/page/n4_w400.jpg")}
    print(i, flush=True)
json.dump(rep,open('check.json','w'),ensure_ascii=False,indent=1)
