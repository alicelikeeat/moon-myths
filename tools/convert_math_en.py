"""三部英文数学经典（Project Gutenberg LaTeX 版）→ texts/*.json
  hilbert-en  Hilbert, The Foundations of Geometry（Townsend 英译，1902，PG #17384）
  boole-en    Boole, An Investigation of the Laws of Thought（1854，PG #15114）
  dedekind-en Dedekind, Essays on the Theory of Numbers（Beman 英译，1901，PG #21016）"""
import re, json, sys, glob
sys.path.insert(0, '/home/claude/moon-myths/tools')
from tex2txt import inline, group
GB = '/home/claude/gb'; ROOT = '/home/claude/moon-myths'

def clean(body):
    body = re.sub(r'(?m)^[ \t]*%.*\n', '', body)
    body = re.sub(r'(?<!\\)%.*', '', body)
    body = re.sub(r'\\begin\{(figure|table|tabular)\}.*?\\end\{\1\}', '', body, flags=re.S)
    body = re.sub(r'\\(begin|end)\{(center|flushleft|flushright|minipage|small|footnotesize|quote|quotation)\}(\{[^}]*\})?', '', body)
    body = re.sub(r'\\label\{[^}]*\}|\\(v|h)space\*?\{[^}]*\}|\\rule\{[^}]*\}\{[^}]*\}|\\(newpage|clearpage|cleardoublepage|bigskip|medskip|smallskip|noindent|par|indent)\b', '', body)
    body = re.sub(r'\\(addcontentsline|markboth)\{[^}]*\}\{[^}]*\}(\{[^}]*\})?|\\pagestyle\{[^}]*\}|\\thispagestyle\{[^}]*\}|\\pageref\{[^}]*\}|\\ref\{[^}]*\}', '', body)
    body = body.replace('\\-', '').replace('--', '–').replace('``', '“').replace("''", '”')
    # 脚注：放到段尾方括号里
    out, i = '', 0
    while True:
        j = body.find('\\footnote', i)
        if j < 0: out += body[i:]; break
        k = j + len('\\footnote')
        while k < len(body) and body[k] in ' \n': k += 1
        if k < len(body) and body[k] == '[':
            k = body.index(']', k) + 1
        g, e = group(body, k); out += body[i:j] + f' [Note: {" ".join(g.split())}]'; i = e
    return out

EXTRA = {'textit': '', 'textbf': '', 'emph': '', 'textsc': '', 'scshape': '', 'Large': '', 'large': '', 'small': '', 'tiny': '', 'S': '§', 'mbox': '', 'text': '', 'textrm': '', 'mathrm': ''}

def para(blk):
    t = inline(blk, EXTRA)
    t = re.sub(r'\\[A-Za-z]+\*?', '', t)
    t = t.replace('{', '').replace('}', '').replace('~', ' ')
    return ' '.join(t.split()).strip()

def build(id_, title, sections, src):
    sections = [s for s in sections if s['paragraphs']]
    json.dump({'id': id_, 'title': title, 'lang': 'en', 'source': src, 'sections': sections},
              open(f'{ROOT}/texts/{id_}.json', 'w', encoding='utf-8'), ensure_ascii=False, separators=(',', ':'))
    n = sum(len(s['paragraphs']) for s in sections)
    print(id_, len(sections), 'sections', n, 'paras'); print('  ', [s['title'] for s in sections][:30])

def run(body, heads):
    """heads: [(正则, 标题函数)]，在出现处另起一节"""
    sections = [{'title': 'Preface', 'paragraphs': []}]
    for blk in re.split(r'\n\s*\n', body):
        blk = blk.strip()
        if not blk: continue
        while True:
            hit = None
            for rx, f in heads:
                m = re.search(rx, blk, re.S)
                if m and (hit is None or m.start() < hit[0].start()): hit = (m, f)
            if not hit: break
            m, f = hit
            before = para(blk[:m.start()])
            if before and len(before) > 1: sections[-1]['paragraphs'].append(before)
            sections.append({'title': f(m), 'paragraphs': []})
            blk = blk[m.end():]
        p = para(blk)
        if p and len(p) > 1 and not re.fullmatch(r'[\W\d]*', p): sections[-1]['paragraphs'].append(p)
    return sections

def tidy(t):
    t = re.sub(r'\s*\[Note:.*', '', ' '.join(para(t).split())).strip(' .')
    t = t.title()
    t = re.sub(r"'S\b", "'s", t)
    t = re.sub(r'\b(Ii|Iii|Iv|Vi|Vii)\b', lambda m: m.group(1).upper(), t)
    for w in ('Of', 'The', 'And', 'In', 'For', 'By', 'To', 'Upon', 'With', 'Its', 'A', 'On'):
        t = re.sub(rf'(?<=[^\s.:]) {w}\b', ' ' + w.lower(), t)
    return t

# Hilbert
src = open(glob.glob(f'{GB}/The-Foundations-of-Geometry_17384/17384-t/17384-t.tex')[0], encoding='utf-8', errors='replace').read()
body = src[src.index('{\\Large PREFACE.}') - 30: src.index('End of Project Gutenberg')]
body = clean(body)
chap = ['']
def hchap(m): chap[0] = tidy(m.group(1)); return chap[0]
def hsec(m):
    g, _ = group(m.string, m.end() - 1)
    return tidy(g)
secs = []
cur = {'title': 'Preface', 'paragraphs': []}; secs.append(cur)
i = 0
pieces = re.split(r'(\{\\Large [^{}]*?\}|\\rfa\{)', body)
k = 0
text_acc = ''
def flush(t):
    for blk in re.split(r'\n\s*\n', t):
        p = para(blk)
        if p and len(p) > 2 and not re.fullmatch(r'[\W\d]*', p): secs[-1]['paragraphs'].append(p)
while k < len(pieces):
    pc = pieces[k]
    if pc.startswith('{\\Large'):
        flush(text_acc); text_acc = ''
        chap[0] = tidy(pc[len('{\\Large '):-1])
        secs.append({'title': chap[0], 'paragraphs': []})
    elif pc == '\\rfa{':
        flush(text_acc); text_acc = ''
        rest = '{' + pieces[k + 1]
        g, e = group(rest, 0)
        t = tidy(g)
        if t.lower() not in ('contents',):
            secs.append({'title': t if t.startswith('§') else t, 'paragraphs': []})
        pieces[k + 1] = rest[e:]
    else:
        text_acc += pc
    k += 1
flush(text_acc)
secs = [s for s in secs if s['title'].lower() != 'contents']
build('hilbert-en', 'The Foundations of Geometry, by David Hilbert, tr. E. J. Townsend (1902)', secs,
      'Project Gutenberg #17384（公有领域）')

# Boole
src = open(glob.glob(f'{GB}/An-Investigation-of-the-Laws-of-Thought*/15114-t.tex')[0], encoding='utf-8', errors='replace').read()
body = src[src.index('\\mainmatter'): src.index('End of the Project Gutenberg') if 'End of the Project Gutenberg' in src else src.index('End of Project Gutenberg')]
body = clean(body)
body = re.sub(r'\\Proposition\{([^}]*)\}\{[^}]*\}', r'Proposition \1.', body)
n = [0]
def bchap(m):
    n[0] += 1
    return f'Chapter {n[0]}. ' + tidy(m.group(1))
secs = run(body, [(r'\\chapter\[([^\]]*)\](\{(?:[^{}]|\{[^{}]*\})*\})?', bchap)])
secs = [s for s in secs if s['title'] != 'Preface' or s['paragraphs']]
build('boole-en', 'An Investigation of the Laws of Thought, by George Boole (1854)', secs, 'Project Gutenberg #15114（公有领域）')

# Dedekind
src = open(glob.glob(f'{GB}/Essays-on-the-Theory-of-Numbers_21016/21016-t/21016-t.tex')[0], encoding='utf-8', errors='replace').read()
body = src[src.index('\\mainmatter'): src.index('End of Project Gutenberg')]
body = clean(body)
part = ['']
def dchap(m):
    part[0] = 'I' if m.group(1) == 'I' else 'II'
    return f'{m.group(1)}. ' + tidy(m.group(2))
def dsect(m):
    return f'{part[0]}.{m.group(2)} ' + m.group(3)
body = re.sub(r'\\mypara\{([^{}]*)\}', r'\1 ', body)
secs = run(body, [(r'\\mychap\{([^{}]*)\}\{([^{}]*)\}', dchap), (r'\\mysect\{[^{}]*\}\{([^{}]*)\}\{([^{}]*)\}', lambda m: f'{part[0]} · §{m.group(1)} {m.group(2)}')])
build('dedekind-en', 'Essays on the Theory of Numbers, by Richard Dedekind, tr. W. W. Beman (1901)', secs, 'Project Gutenberg #21016（公有领域）')
