"""四库本算经（漢籍リポジトリ WYG 底本）→ texts/<id>.json + comments/<id>.json
  haidao-zh   海島算經（晉·劉徽撰，唐·李淳風注）  KR3f0035
  shuxue-zh   數學九章（宋·秦九韶撰）            KR3f0041
  ceyuan-zh   測圓海鏡（元·李冶撰）              KR3f0042
分段：按版面行宽判断——上一行没有写满就是段落结束；“答曰/法曰/草曰/術曰”等另起一段。
注文：「淳風等按」段落归李淳风注；行首缩进三格的「按」段与括号里的「按/案」小注归四库馆臣；其余括号小注是原书自注，留在正文里。"""
import re, glob, json, sys
ROOT = '/home/claude/moon-myths'
KEYS = ('答曰', '荅曰', '法曰', '草曰', '術曰', '又術曰', '又法', '或問', '假令', '今有', '求')
CN = '〇一二三四五六七八九十'

def juan_name(s):
    m = re.search(r'卷([一二三四五六七八九十]+)([上下]?)', s)
    return f'卷{m.group(1)}{m.group(2)}' if m else None

def convert(repo, id_, title, src_note, comment_names):
    files = sorted(f for f in glob.glob(f'/home/claude/krm/{repo}/{repo}_*.txt'))
    sections, comm = [], {k: {} for k in comment_names}
    def sec(t): sections.append({'title': t, 'paragraphs': []})
    def cur_index(): return sum(len(s['paragraphs']) for s in sections) - 1
    def add_comment(kind, text):
        i = cur_index()
        if i < 0 or not text: return
        d = comm[kind]; d[str(i)] = (d.get(str(i), '') + ('　' if d.get(str(i)) else '') + text)
    for f in files:
        n = int(f[-7:-4])
        lines = []
        for raw in open(f, encoding='utf-8'):
            if raw.startswith('#') or raw.startswith('<pb'): continue
            line = re.sub(r'<[^>]*>', '', raw).replace('¶', '').rstrip('\n')
            if not line.strip('　 '): continue
            lines.append(line)
        if not lines: continue
        from collections import Counter
        width = Counter(len(l) for l in lines if '(' not in l).most_common(1)[0][0]
        if n == 0:
            # 卷首：四库提要等，整体作为一节
            sec('提要')
        elif n == 1:
            sec('卷首')
        prev_full, block, block_lead, after_head = False, [], 0, False
        def flush():
            nonlocal block
            if not block: return
            text = ''.join(block)
            lead = block_lead
            block = []
            # 括号小注：按/案 → 四库；其余保留
            def paren(m):
                inner = m.group(1).replace('/', '')
                if inner.startswith(('按', '案')) and 'siku' in comm:
                    add_comment('siku', inner); return ''
                return f'（{inner}）'
            body = re.sub(r'\(([^()]*)\)', paren, text)
            body = body.replace(')(', '').replace('(', '').replace(')', '')
            if 'li' in comm and body.startswith(('淳風等按', '臣淳風等', '淳風等謹按')):
                add_comment('li', body); return
            if 'siku' in comm and lead >= 3 and body.startswith(('按', '謹按', '臣等謹按')):
                add_comment('siku', body); return
            if not sections: sec(title)
            sections[-1]['paragraphs'].append(body)
        for line in lines:
            body = line.strip('　 ')
            lead = len(line) - len(line.lstrip('　'))
            if body.startswith('欽定四庫全書'): flush(); prev_full = False; continue
            j = juan_name(body.split('　')[0]) if re.match(re.escape(title) + r'卷', body) else None
            if j:
                flush(); sec(j); prev_full = False; after_head = True; continue
            if '官' in body and '(臣' in body and len(body) < 50: flush(); prev_full = False; continue
            if re.search(r'[撰注]$', body) and '　' in body: flush(); prev_full = False; continue
            if re.fullmatch(r'(唐|晉|宋|元)?[　\s]*[\w　]{2,10}[　\s]*(注|撰|釋)', body): flush(); prev_full = False; continue
            plain = re.sub(r'\([^()]*\)', '', body)
            if n > 0 and not prev_full and (lead == 2 or (lead == 1 and after_head)) and 2 <= len(plain) <= 9 \
                    and '　' not in plain and not re.search(r'[曰為之以得]', plain) and not plain.startswith(('按', '合問')):
                flush(); sec(f'{sections[-1]["title"].split(" · ")[0] if sections else "卷一"} · {plain}'); prev_full = False; after_head = False; continue
            after_head = False
            starts_key = body.startswith(KEYS) or body.startswith(('淳風等按', '按'))
            if not prev_full or starts_key or (block and lead != block_lead and (lead >= 3 or block_lead >= 3)):
                flush(); block_lead = lead
            block.append(body)
            prev_full = len(line) >= width - 1
        flush()
    sections = [s for s in sections if s['paragraphs']]
    if len(sections) == 1: sections[0]['title'] = title
    json.dump({'id': id_, 'title': title, 'lang': 'zh', 'source': src_note, 'sections': sections},
              open(f'{ROOT}/texts/{id_}.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    srcs = [{'name': comment_names[k], 'items': v} for k, v in comm.items() if v]
    if srcs:
        json.dump({'id': id_, 'sources': srcs}, open(f'{ROOT}/comments/{id_}.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    paras = [p for s in sections for p in s['paragraphs']]
    print(id_, len(sections), 'sections', len(paras), 'paras', {k: len(v) for k, v in comm.items()})
    print('  ', [s['title'] for s in sections][:14])
    for p in paras[1:4]: print('   >', p[:80])

convert('KR3f0035', 'haidao-zh', '海島算經', '公有领域文本，据漢籍リポジトリ（Kanseki Repository）KR3f0035 整理（底本：文渊阁四库全书本）',
        {'li': '唐·李淳风等注', 'siku': '清·四库馆臣按语'})
convert('KR3f0041', 'shuxue-zh', '數學九章', '公有领域文本，据漢籍リポジトリ（Kanseki Repository）KR3f0041 整理（底本：文渊阁四库全书本）',
        {'siku': '清·四库馆臣按语'})
convert('KR3f0042', 'ceyuan-zh', '測圓海鏡', '公有领域文本，据漢籍リポジトリ（Kanseki Repository）KR3f0042 整理（底本：文渊阁四库全书本）',
        {'siku': '清·四库馆臣按语'})
