"""利瑪竇、徐光啟譯《幾何原本》（四庫本，KR3f0047）→ texts/jihe-zh.json：每條界說、公論、題各成一段。"""
import re, glob, json
REPO = '/home/claude/krm/KR3f0047'
NUM = '一二三四五六七八九十百〇'
sections = []
def sec(t): sections.append({'title': t, 'paragraphs': []})
def para(t): sections[-1]['paragraphs'].append(t)
def add(t):
    if not sections[-1]['paragraphs']: para('')
    sections[-1]['paragraphs'][-1] += t
juan = ''
for f in sorted(glob.glob(f'{REPO}/KR3f0047_0*.txt')):
    if f.endswith('_000.txt'): continue
    for raw in open(f, encoding='utf-8'):
        if raw.startswith('#'): continue
        line = re.sub(r'<[^>]*>', '', raw).replace('¶', '').rstrip('\n')
        body = line.strip('　 ')
        if not body or body == '欽定四庫全書' or '利瑪竇' in body or '徐光啟' in body or '徐光啓' in body: continue
        body = re.sub(r'\(([^()]*)\)', lambda m: '（' + m.group(1).replace('/', '') + '）', body)
        mj = re.match(r'^幾何原本卷([一二三四五六])(之首|上|下)?', body)
        if mj:
            if juan != mj.group(1) + (mj.group(2) or ''):
                juan = mj.group(1) + (mj.group(2) or '')
                sec(f'卷{mj.group(1)}' + ('' if not mj.group(2) or mj.group(2) == '之首' else mj.group(2)))
            continue
        if not sections: sec('卷一')
        mh = re.match(r'^(界說|求作|公論)\S*則$', body)
        if mh:
            sec(f"卷{juan[0]} · {mh.group(1)}"); continue
        mt = re.match(rf'^第[{NUM}]+(界|題|求|論|增題)\S{{0,6}}$', body)
        if mt and len(body) <= 12:
            if mt.group(1) == '題' and '· 界說' in sections[-1]['title'] or '· 公論' in sections[-1]['title'] or '· 求作' in sections[-1]['title']:
                if mt.group(1) in ('題',): sec(f'卷{juan[0]} · 題')
            para(body + '　'); continue
        lead = len(line) - len(line.lstrip('　'))
        if lead == 0 and sections[-1]['paragraphs'] and sections[-1]['paragraphs'][-1].endswith('　'):
            add(body); continue
        add(('' if lead else '') + body)
for s in sections:
    s['paragraphs'] = [p.strip('　') for p in s['paragraphs'] if p.strip('　')]
sections = [s for s in sections if s['paragraphs']]
merged = []
for s in sections:
    if ' · ' not in s['title']: s['title'] += ' · 题'
    if merged and merged[-1]['title'] == s['title']: merged[-1]['paragraphs'] += s['paragraphs']
    else: merged.append(s)
sections = merged
json.dump({'id': 'jihe-zh', 'title': '幾何原本', 'lang': 'zh', 'source': '公有领域文本，据漢籍リポジトリ（Kanseki Repository）KR3f0047 整理（底本：四库全书本）', 'sections': sections},
          open('/home/claude/moon-myths/texts/jihe-zh.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(sections), [ (s['title'], len(s['paragraphs'])) for s in sections])
print(sections[0]['paragraphs'][:3]); print([p[:60] for p in sections[3]['paragraphs'][:2]])
