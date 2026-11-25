"""九章算術（四部叢刊本，KR3f0032）→ texts/jiuzhang-zh.json + comments/jiuzhang-zh.json
正文按“今有/又有…問…荅曰”和“…術曰…”分段；括號內注文按「臣淳風等謹按」分給李淳風，其餘歸劉徽。"""
import re, glob, json, os
REPO = '/home/claude/krm/KR3f0032'; ROOT = '/home/claude/moon-myths'
CN = '一二三四五六七八九'
sections, liu, li = [], {}, {}
pidx = -1
def new_para(text=''):
    global pidx
    sections[-1]['paragraphs'].append(text); pidx += 1
def add_text(t):
    if not sections[-1]['paragraphs']: new_para()
    sections[-1]['paragraphs'][-1] += t
in_li = False
pending = []
carry = ['']
def add_comm(c):
    global in_li
    c = c.replace('/', '').replace('　', '')
    if not c: return
    if pidx < 0: return
    k = str(pidx)
    if '臣淳風' in c:
        a, b = c.split('臣淳風', 1)
        if a and not in_li: liu[k] = liu.get(k, '') + a
        li[k] = li.get(k, '') + ('臣淳風' + b if not li.get(k) else ' ○ 臣淳風' + b)
        in_li = True
    elif in_li:
        li[k] += c
    else:
        liu[k] = liu.get(k, '') + c
# 劉徽序
pre = ''
for raw in open(f'{REPO}/KR3f0032_000.txt', encoding='utf-8'):
    if raw.startswith('#'): continue
    pre += re.sub(r'<[^>]*>', '', raw).replace('¶', '').strip().strip('　')
pre = pre.replace('劉徽九章算術注原序', '', 1)
sections.append({'title': '刘徽《九章算术注》原序', 'paragraphs': []})
for chunk in re.split(r'(?<=[也矣焉])(?=[^也矣焉]{30,})', re.sub(r'\([^()]*\)', '', pre)):
    if chunk: new_para(chunk)
juan, mode = 0, 'skip'
for f in sorted(glob.glob(f'{REPO}/KR3f0032_0*.txt')):
    n = int(f[-7:-4])
    if n == 0 or n == 10: continue
    label = None
    for raw in open(f, encoding='utf-8'):
        if raw.startswith('#'): continue
        line = re.sub(r'<[^>]*>', '', raw).replace('¶', '').rstrip('\n')
        body = line.strip('　 ')
        if not body: continue
        h = re.match(r'^九章算術卷(?:第|之)?([一二三四五六七八九])', body)
        if h:
            if '訂訛' in body or '終' in body or '(' not in body: mode = 'skip'
            else: juan, mode = CN.index(h.group(1)) + 1, 'head'
            continue
        if mode == 'skip': continue
        if '劉　徽' in line or ('李淳風' in body and '奉勅' in body): continue
        lead = len(line) - len(line.lstrip('　'))
        plain = re.sub(r'\([^()]*\)', '', body)
        if mode == 'head' and lead == 0 and len(plain) <= 4:
            sections.append({'title': f'卷{CN[juan-1]} · {plain}', 'paragraphs': []}); in_li = False; mode = 'main'
            for c in re.findall(r'\(([^()]*)\)', body): pass   # 篇名下的小注（以御田疇界域）略去
            continue
        if lead >= 2 and len(plain) <= 6 and not plain.startswith(('術曰', '荅曰', '今有', '又有')) and not re.search(r'[曰之以而問]', plain[1:]):
            label = plain; pending.extend(c for c in re.findall(r'\(([^()]*)\)', body)); continue          # 術名，如「方田」「里田」，接到下一個「術曰」前
        # 分段
        parts = re.split(r'(\([^()]*\))', body)
        for part in parts:
            if not part: continue
            if part.startswith('('):
                add_comm(part[1:-1]); continue
            t = carry[0] + part.replace('　', ''); carry[0] = ''
            if t and t[-1] in '今又術' and not t.endswith(('今有', '又有', '術曰')):
                carry[0] = t[-1]; t = t[:-1]
            while t:
                m = re.search(r'(今有|又有|又術曰|術曰)', t)
                if m and (m.start() > 0 or True):
                    before, t2 = t[:m.start()], t[m.start():]
                    if before: add_text(before)
                    key = m.group(1)
                    if key == '術曰' and label:
                        new_para(label); in_li = False; label = None; add_text('術曰')
                        for c in pending: add_comm(c)
                        pending.clear()
                    else:
                        new_para(key); in_li = False
                        if key.endswith('術曰'): label = None
                    t = t2[len(key):]
                    continue
                add_text(t); t = ''
paras = [p for s in sections for p in s['paragraphs']]
assert all(paras), 'empty para'
for s in sections:
    s['paragraphs'] = [re.sub(r'(荅曰)', r' \1', p).strip() for p in s['paragraphs']]
src = '公有领域文本，据漢籍リポジトリ（Kanseki Repository）KR3f0032 整理（底本：四部叢刊本）'
json.dump({'id': 'jiuzhang-zh', 'title': '九章算術', 'lang': 'zh', 'source': src, 'sections': sections},
          open(f'{ROOT}/texts/jiuzhang-zh.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
json.dump({'id': 'jiuzhang-zh', 'sources': [{'name': '魏·刘徽注', 'items': liu}, {'name': '唐·李淳风等注释', 'items': li}]},
          open(f'{ROOT}/comments/jiuzhang-zh.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(sections), [s['title'] for s in sections]); print(len(paras), 'paras', len(liu), 'liu', len(li), 'li')
for i in (0, 1, 2, 3, 30, 31): print(i, paras[i][:70], '| 刘:', liu.get(str(i), '')[:40], '| 李:', li.get(str(i), '')[:30])
