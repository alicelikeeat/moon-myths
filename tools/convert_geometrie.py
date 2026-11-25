"""Descartes, La Géométrie（1637；PG #26400，据 Victor Cousin 编《笛卡尔全集》本）→ texts/geometrie-fr.json"""
import re, json, sys
sys.path.insert(0, '/home/claude/tools')
from tex2txt import inline, group
src = open('/tmp/geo.tex', encoding='utf-8').read()
start = src.index('{\\LARGE LIVRE PREMIER}')
end = src.index('TABLE', start + 1000)
end = src.rfind('\\newpage', start, end) if src.rfind('\\newpage', start, end) > 0 else end
body = src[start:end]
body = re.sub(r'(?m)^[ \t]*%.*\n', '', body)
body = re.sub(r'(?<!\\)%.*', '', body)
body = re.sub(r'\n?\\begin\{figure\}.*?\\end\{figure\}', '', body, flags=re.S)
body = re.sub(r'\\(begin|end)\{(center|flushleft|flushright|minipage)\}(\{[^}]*\})?', '', body)
body = re.sub(r'\\label\{[^}]*\}|\\(v|h)space\*?\{[^}]*\}|\\rule\{[^}]*\}\{[^}]*\}|\\newpage|\\bigskip|\\medskip|\\smallskip|\\noindent', '', body)
body = body.replace('\\-', '')
def fn(s):
    out, i = '', 0
    while True:
        j = s.find('\\footnote', i)
        if j < 0: return out + s[i:]
        k = j + len('\\footnote')
        if s.startswith('mark', k): out += s[i:j]; i = k + 4; continue
        if s.startswith('text', k): k += 4
        while s[k] in ' \n': k += 1
        g, e = group(s, k); out += s[i:j] + f' [Note : {g.strip()}]'; i = e
body = fn(body)
EXTRA = {':': '', 'gsp': ' ', 'emph': '', 'textit': '', 'textbf': '', 'c': '', 'raisebox': '', 'Huge': '', 'LARGE': '', 'Large': '', 'large': '', 'small': ''}
# 标记：卷标题、页边小标题
body = re.sub(r'\{\\LARGE (LIVRE [^}]*)\}', r'\n\n@@LIVRE \1@@\n\n', body)
def margin(s):
    out, i = '', 0
    while True:
        j = s.find('\\mymarginpar', i)
        if j < 0: return out + s[i:]
        g, e = group(s, j + len('\\mymarginpar'))
        out += s[i:j] + f'@@M {" ".join(g.split())}@@'; i = e
body = margin(body)
sections, livre = [], ''
def sec(t): sections.append({'title': t, 'paragraphs': []})
NUM = {'LIVRE PREMIER': 'Livre premier', 'LIVRE SECOND': 'Livre second', 'LIVRE TROISIÈME': 'Livre troisième'}
for blk in re.split(r'\n\s*\n', body):
    blk = blk.strip()
    if not blk: continue
    m = re.match(r'@@LIVRE (.+?)@@', blk)
    if m:
        livre = NUM.get(m.group(1).strip(), m.group(1).title()); sec(livre); continue
    # 页边小标题：在它出现处另起一节
    pieces = re.split(r'@@M (.+?)@@', blk)
    for k, piece in enumerate(pieces):
        if k % 2 == 1:
            title = inline(piece, EXTRA).strip().rstrip('.')
            # 小标题前面的半句话留在上一段
            sec(f'{livre} · {title}'); continue
        t = inline(piece, EXTRA).strip()
        t = re.sub(r'\s+([,.;:)])', r'\1', t)
        if not t: continue
        if not sections: sec(livre or 'Livre premier')
        if k > 0 and sections[-1]['paragraphs'] == [] and len(sections) > 1 and pieces[0].strip() and k == 2:
            # 例：“Et@@M…@@ comme toute…”——把前面的“Et”接回本段开头
            t = inline(pieces[0], EXTRA).strip() + ' ' + t
            prev = sections[-2]['paragraphs']
            if prev and prev[-1] == inline(pieces[0], EXTRA).strip(): prev.pop()
        sections[-1]['paragraphs'].append(t)
sections = [s for s in sections if s['paragraphs']]
json.dump({'id': 'geometrie-fr', 'title': 'La Géométrie (1637)', 'lang': 'fr',
           'source': '公有领域文本，据 Project Gutenberg #26400 整理（Victor Cousin 编《笛卡尔全集》本，部分符号已改为通行写法）', 'sections': sections},
          open('/home/claude/moon-myths/texts/geometrie-fr.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print(len(sections), sum(len(s['paragraphs']) for s in sections)); print([s['title'][:50] for s in sections[:8]])
print(sections[1]['paragraphs'][:2]); print(sections[2]['paragraphs'][:1])
