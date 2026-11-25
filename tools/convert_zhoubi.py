"""周髀算經（四部叢刊本，KR3f0001）→ texts/zhoubi-zh.json + comments/zhoubi-zh.json
頂格為經文，縮進為注：趙爽注；「臣鸞」起為甄鸞重述；「臣淳風」起為李淳風等注釋。括號內為明人校記，略去。"""
import re, glob, json
REPO = '/home/claude/krm/KR3f0001'; ROOT = '/home/claude/moon-myths'
sections, notes = [], {'zhao': {}, 'zhen': {}, 'li': {}}
pidx, last, who = -1, 'none', 'zhao'
prevlen = 0
def put(c):
    global who
    if pidx < 0 or not c: return
    k = str(pidx)
    parts = re.split(r'(臣鸞|臣淳風)', c)
    for p in parts:
        if p == '臣鸞': who = 'zhen'; cur = '臣鸞'; continue
        if p == '臣淳風': who = 'li'; continue
        if not p: continue
        if who == 'li' and not notes['li'].get(k, '').endswith(p) and (parts[parts.index(p) - 1] if parts.index(p) > 0 else '') == '臣淳風':
            p = '臣淳風' + p
        if who == 'zhen' and (parts[parts.index(p) - 1] if parts.index(p) > 0 else '') == '臣鸞':
            p = '臣鸞' + p
        d = notes[who]; d[k] = d.get(k, '') + (' ○ ' if d.get(k) and p.startswith('臣') else '') + p
for f in sorted(glob.glob(f'{REPO}/KR3f0001_00[12].txt')):
    for raw in open(f, encoding='utf-8'):
        if raw.startswith('#'): continue
        line = re.sub(r'<[^>]*>', '', raw).replace('¶', '').rstrip('\n')
        body = re.sub(r'\([^()]*\)', '', line).strip('　 ')
        if not body: continue
        m = re.match(r'^周髀算經卷([上下])', body)
        if m:
            if not sections or sections[-1]['title'] != f'卷{m.group(1)}': sections.append({'title': f'卷{m.group(1)}', 'paragraphs': []}); last = 'none'
            continue
        if re.search(r'注$|重述$|注釋$|校$', body) and len(body) < 40 and ('趙' in body or '臣' in body or '明' in body): continue
        lead = len(line) - len(line.lstrip('　'))
        if lead == 0 and (body.startswith('勾股圓方圖') or (last == 'note' and prevlen >= 17)):
            lead = 1          # 注文換行後頂格，或圖題
        prevlen = len(body)
        if lead == 0:
            if last != 'text':
                sections[-1]['paragraphs'].append(''); pidx += 1; who = 'zhao'
            sections[-1]['paragraphs'][-1] += body; last = 'text'
        else:
            put(body); last = 'note'
json.dump({'id': 'zhoubi-zh', 'title': '周髀算經', 'lang': 'zh', 'source': '公有领域文本，据漢籍リポジトリ（Kanseki Repository）KR3f0001 整理（底本：四部叢刊本）', 'sections': sections},
          open(f'{ROOT}/texts/zhoubi-zh.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
json.dump({'id': 'zhoubi-zh', 'sources': [{'name': '汉·赵爽注', 'items': notes['zhao']}, {'name': '北周·甄鸾重述', 'items': notes['zhen']}, {'name': '唐·李淳风等注释', 'items': notes['li']}]},
          open(f'{ROOT}/comments/zhoubi-zh.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
ps = [p for s in sections for p in s['paragraphs']]
print([(s['title'], len(s['paragraphs'])) for s in sections], {k: len(v) for k, v in notes.items()})
for i in (0, 3, 9, 10, 11): print(i, ps[i][:40], '| 赵:', notes['zhao'].get(str(i), '')[:40], '| 甄:', notes['zhen'].get(str(i), '')[:20])
