"""Archimedes, The Method (Robinson 英译, 1909, PG #7825) → texts/archimedes-en.json"""
import re, json, sys
sys.path.insert(0, '/home/claude/tools')
from tex2txt import inline, group
src = open('/home/claude/gb/Geometrical-Solutions-Derived-from-Mechanics-a-Treatise-of-Archimedes_7825/7825-t/7825-t.tex', encoding='utf-8', errors='replace').read()
body = src[src.index('\\Section{Introduction.}'):src.index('\\PGLicense\n', src.index('\\begin{document}'))]
EXTRA = {'cone': 'cone', 'cones': 'cones', 'cylinder': 'cylinder', 'segment': 'segment', 'segm': 'segm.', 'spheroid': 'spheroid',
         'spheres': 'spheres', 'Tri': '△', 'SameMark': '', 'ie': 'i.e.', 'eg': 'e.g.', 'dotfill': '', 'noindent': '', 'vfill': '', 'Figures': '',
         'First': '', 'Title': '', 'Fig': 'Fig. ', 'textsc': '', 'centering': '', 'par': ''}
# 去掉图、页码、脚注改为方括号
body = re.sub(r'\\PageSep\{[^}]*\}', '', body)
body = re.sub(r'\\Figures?(\[[^\]]*\])?\{[^}]*\}\{[^}]*\}', '', body)
def footnotes(s):
    out, i = '', 0
    while True:
        j = s.find('\\footnote', i)
        if j < 0: return out + s[i:]
        k = j + len('\\footnote')
        while s[k] in ' \n': k += 1
        g, e = group(s, k); out += s[i:j] + f' [Note: {g.strip()}]'; i = e
body = footnotes(body)
body = re.sub(r'\\Signature\{([^}]*)\}\{([^}]*)\}', r'— \1, \2', body)
sections = []
for chunk in re.split(r'\\(Section|Subsection)\{([^}]*)\}', body):
    pass
parts = re.split(r'\\(?:Section|Subsection)\{([^}]*)\}', body)
for k in range(1, len(parts), 2):
    title = parts[k].strip().rstrip('.')
    if re.fullmatch(r'[IVX]+a?', title): title = f'Proposition {title}'
    paras = []
    for blk in re.split(r'\n\s*\n', parts[k + 1]):
        t = inline(blk, EXTRA).strip()
        t = re.sub(r'\s+([,.;:)])', r'\1', t)
        if len(t) > 2 and re.search(r'[A-Za-z]{3}', t): paras.append(t)
    if paras: sections.append({'title': title, 'paragraphs': paras})
json.dump({'id': 'archimedes-en', 'title': 'Geometrical Solutions Derived from Mechanics (The Method), tr. J. L. Heiberg & L. G. Robinson, 1909', 'lang': 'en',
           'source': '公有领域文本，据 Project Gutenberg #7825 整理（Open Court 1909 年版）', 'sections': sections},
          open('/home/claude/moon-myths/texts/archimedes-en.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
print([ (s['title'], len(s['paragraphs'])) for s in sections])
print(sections[2]['paragraphs'][0][:400])
