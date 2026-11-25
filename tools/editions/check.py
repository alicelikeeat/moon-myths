import json, urllib.request, urllib.parse
UA={'User-Agent':'PurePhilosophyApp/1.0 (github.com/alicelikeeat/moon-myths)'}
d=json.load(open('Sources/editions.json')); rep={}
def ok(u):
    try:
        with urllib.request.urlopen(urllib.request.Request(u,headers=UA,method='HEAD'),timeout=30) as r: return r.status<400
    except Exception as e: return False
for b,v in d.items():
    for s in v['scans']:
        try:
            m=json.load(urllib.request.urlopen(urllib.request.Request(f"https://archive.org/metadata/{s['ia']}/files",headers=UA),timeout=30))
            pdfs=[f['name'] for f in m.get('result',[]) if f['name'].lower().endswith('.pdf')]
        except Exception: pdfs=[]
        rep[s['ia']]={'pdf':pdfs[0] if pdfs else None,'cover':ok(f"https://archive.org/services/img/{s['ia']}")}
    for i in v['images']:
        rep[i['file']]={'thumb':ok(i['thumb'])}
    print(b,flush=True)
json.dump(rep,open('check.json','w'),ensure_ascii=False,indent=1)
