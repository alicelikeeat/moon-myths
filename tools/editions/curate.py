import json, re
d=json.load(open('candidates.json'))
K={ # 必含关键词（任一），排除词
"kant-cpr":(["Kritik der reinen Vernunft","Critique of pure reason"],["Metakritik","Briefe","Entdeckung","Wörterbuch","Prüfung","Commentar","Beiträge","Gedächnis","Gesammelte","gesammelte"]),
"hegel-phen":(["Phänomenologie","Phanomenologie","System der Wissenschaft"],["Dialektik","Organisation","JSTOR","jstor","Wohnhaus","Logic","logic","Fenomenolog","OUTLINES","DoDo","1970"]),
"hegel-logic":(["Wissenschaft der Logik","Science of logic","Science Of Logic"],["Kritik des","culmination","Ethical","Science(Philosophy"]),
"russell-denoting":(["On Denoting"],[]),
"russell-pm":(["Principia"],["ocr","1981","Hasta","hasta","List of","54-43","PM-1"]),
"russell-problems":(["roblems of philosophy","roblems of Philosophy","roblems Of Philosophy"],["Persistent","Calkins","Analysis","gut","Bertrand Russell"]),
"lunyu":(["論語","Analects","Rongo"],["NCHU","Luan","svg"]),
"daodejing":(["道德經","道德真經","Mawangdui"],["2021","淨朋","TAO TE","古本集注直解","經問","SSID","Frame","ogg","Critical"]),
"zhuangzi":(["莊子"],[]),
"mengzi":(["孟子"],["字義","Portraits","statue","考文"]),
"hanfeizi":(["韓非子"],[]),
"zhuziyulei":(["朱子語類"],[]),
"mozi":(["墨子"],["2011"]),
"xunzi":(["荀子"],[]),
"chunqiufanlu":(["春秋繁露"],[]),
"tanjing":(["壇經"],["白話","精華","摘要","2014","2025","合刊","會意","俗眼","20230625","20230629"]),
"chuanxilu":(["傳習錄"],["金薯"]),
"apology":(["Apology","apology"],["Plato the teacher","Socrates: The Apology","2008"]),
"republic":(["Republic of Plato","Republic Of Plato","P. Oxy"],["0000"]),
"phaedo":(["Phaedo","Trial and death","trial and death"],[]),
"symposium":(["Symposium","Banquet"],[]),
"confessions":(["Confession"],[]),
"discourse":(["Discours","Discourse"],[]),
"meditationes":(["Meditationes"],[]),
"ethics":(["Ethic","Opera posthuma","Opera Posthuma"],[]),
"enquiry":(["nquiry","Philosophical essays","Philosophical Essays"],[]),
"nicomachean":(["Ethics","Ethica","Nicomach"],[]),
"politics":(["Politic"],[]),
"summa":(["Summa"],[]),
"monadologie":(["Monadolog"],[]),
"tractatus":(["Tractatus","Abhandlung"],[]),
"zhouyi":(["周易","I Ching"],[]),
"guanzi":(["管子"],[]),
"sunzi":(["孫子","Art of War","art of war"],[]),
"liji":(["禮記"],[]),
"liezi":(["列子","沖虛"],[]),
"gongsunlong":(["公孫龍"],[]),
"lunheng":(["論衡"],[]),
"zhouyuangong":(["周元公","周子","太極圖","周敦頤"],[]),
"zhangzi":(["張子","正蒙","張載"],[]),
"ercheng":(["二程"],[]),
"xiangshan":(["象山"],[]),
"rizhilu":(["日知錄"],[]),
"lucretius":(["rerum natura","Rerum Natura"],[]),
"enchiridion":(["Enchiridion","Epictetus"],[]),
"meditations":(["Meditations","Marcus"],[]),
"prince":(["Principe","Prince"],[]),
"leviathan":(["Leviathan"],[]),
"pensees":(["Pensées","Pensees","pensées"],[]),
"locke-government":(["reatises of government","reatises of Government"],[]),
"berkeley-principles":(["rinciples of human knowledge","rinciples of Human Knowledge"],[]),
"rousseau-inequality":(["inégalité","inegalite","Inégalité"],[]),
"schopenhauer-essays":(["Parerga","Essays"],[]),
"on-liberty":(["On liberty","On Liberty"],[]),
"utilitarianism":(["Utilitarianism"],[]),
"manifesto":(["Manifest"],[]),
"pragmatism":(["Pragmatism"],[]),
"groundwork":(["Grundlegung","metaphysic of morals","Metaphysic of Morals"],[]),
"bge":(["Jenseits","Beyond good","Beyond Good"],[]),
"zarathustra":(["Zarathustra"],[]),
}
def year(x):
    m=re.match(r'(\d{4})',str(x.get('date','')));return int(m.group(1)) if m else None
out={}
for b,(inc,exc) in K.items():
    r=d[b]; ia=[];seen=set()
    for x in r['ia']:
        t=x.get('title'); t=t if isinstance(t,str) else ' '.join(t)
        i=x['identifier']
        if i in seen or 'gut' in i or not any(k in t for k in inc) or any(e in t or e in i for e in exc): continue
        y=year(x)
        if not (i.endswith('.cn') or (y and y<1930)): continue
        seen.add(i); ia.append({'id':i,'title':t,'year':y,'pub':(x.get('publisher') if isinstance(x.get('publisher'),str) else ' '.join(x.get('publisher') or []))[:60],'dl':x.get('downloads')})
    cm=[]
    for c in r['commons']:
        if c['mime'] not in ('image/jpeg','image/png') or not c['license']: continue
        if not any(k in c['title'] for k in inc) or any(e in c['title'] for e in exc): continue
        if c['title'] in [z['title'] for z in cm]: continue
        cm.append(c)
    out[b]={'ia':ia[:6],'cm':cm[:4]}
    print(f"\n## {b}")
    for x in ia[:6]: print('  IA',x['id'],'|',x['title'][:50],'|',x['year'],'|',x['pub'][:30])
    for c in cm[:4]: print('  CM',c['title'][5:70],'|',c['license'])
json.dump(out,open('picks.json','w'),ensure_ascii=False,indent=1)
