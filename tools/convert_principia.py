"""Newton, Philosophiæ Naturalis Principia Mathematica（1687 年初版；PG #28233）→ texts/principia-la.json"""
import re, json
lines = open('/tmp/pr.txt', encoding='utf-8').read().split('\n')
txt = lambda a, b: '\n'.join(lines[a - 1:b - 1])
def find(pat, start=1):
    for i in range(start - 1, len(lines)):
        if re.match(pat, lines[i]): return i + 1
    raise SystemExit(pat)
L_pref = find(r'^LECTOREM'); L_ode = find(r'^OPUS HOCCE'); L_def = find(r'^Definitiones'); L_ax = find(r'^AXIOMATA')
L_b1 = find(r'^Liber PRIMUS'); L_b2 = find(r'^Liber SECUNDUS'); L_b3 = find(r'^LIBER TERTIUS'); L_end = find(r'^_FINIS\._')
chunks = [('Ad Lectorem', L_pref + 1, L_ode - 1), ('In Viri Praestantissimi D. Isaaci Newtoni Opus (Edm. Halley)', L_ode - 1, L_def - 6),
          ('Definitiones', L_def + 1, L_ax), ('Axiomata, sive Leges Motus', L_ax + 1, L_b1 - 8)]
def sects(book, a, b):
    idx = [i + 1 for i in range(a - 1, b - 1) if re.match(r'^SECT\. [IVX]+\.', lines[i])]
    out = []
    if idx and idx[0] > a + 3: out.append((f'{book}', a + 1, idx[0]))
    for k, s in enumerate(idx):
        e = idx[k + 1] if k + 1 < len(idx) else b
        # 节名在下一行的斜体里
        name = ''
        for j in range(s, min(s + 6, e)):
            if lines[j].startswith('_'):
                name = ' '.join(l.strip() for l in lines[j:j + 4]).split('._')[0].strip('_. '); break
        out.append((f'{book} · Sect. {lines[s - 1].split()[1].rstrip(".")}' + (f' · {name}' if name else ''), s + 1, e))
    return out
chunks += sects('Liber I', L_b1, L_b2 - 8) + sects('Liber II', L_b2, L_b3 - 2) + [('Liber III · De Mundi Systemate', L_b3 + 1, L_end)]
sections = []
for title, a, b in chunks:
    paras = []
    for blk in re.split(r'\n\s*\n', txt(a, b)):
        t = ' '.join(l.strip() for l in blk.split('\n')).strip()
        t = t.replace('[Illustration]', '').replace('_', '').strip()
        if not t or set(t) <= set('* ') or len(t) < 3: continue
        paras.append(re.sub(r'\s+', ' ', t))
    if paras: sections.append({'title': title, 'paragraphs': paras})
json.dump({'id': 'principia-la', 'title': 'Philosophiæ Naturalis Principia Mathematica (Londini, 1687)', 'lang': 'la',
           'source': '公有领域文本，据 Project Gutenberg #28233 整理（1687 年伦敦初版）', 'sections': sections},
          open('/home/claude/moon-myths/texts/principia-la.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(sections), sum(len(s['paragraphs']) for s in sections))
for s in sections: print(' ', s['title'][:80], len(s['paragraphs']))
