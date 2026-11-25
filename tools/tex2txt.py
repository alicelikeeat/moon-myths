"""把 Project Gutenberg 的 LaTeX 版本转成纯文本段落（数学式转为 Unicode 近似写法）。"""
import re
GREEK = {'alpha':'α','beta':'β','gamma':'γ','delta':'δ','epsilon':'ε','varepsilon':'ε','zeta':'ζ','eta':'η','theta':'θ','iota':'ι','kappa':'κ',
         'lambda':'λ','mu':'μ','nu':'ν','xi':'ξ','omicron':'ο','pi':'π','rho':'ρ','sigma':'σ','tau':'τ','upsilon':'υ','phi':'φ','varphi':'φ',
         'chi':'χ','psi':'ψ','omega':'ω','Gamma':'Γ','Delta':'Δ','Theta':'Θ','Lambda':'Λ','Xi':'Ξ','Pi':'Π','Sigma':'Σ','Phi':'Φ','Psi':'Ψ','Omega':'Ω'}
SYM = {'cdot':'·','times':'×','pm':'±','mp':'∓','div':'÷','leq':'≤','geq':'≥','le':'≤','ge':'≥','neq':'≠','infty':'∞','dots':'…','ldots':'…','cdots':'⋯',
       'quad':' ','qquad':'  ',',':' ',';':' ','!':'',' ':' ','colon':':','prime':'′','angle':'∠','perp':'⊥','parallel':'∥','sim':'∼','approx':'≈',
       '|':'∥','therefore':'∴','because':'∵','circ':'°','degree':'°','to':'→','rightarrow':'→','equiv':'≡','propto':'∝'}
SUP = str.maketrans('0123456789+-=()n', '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿ')
SUB = str.maketrans('0123456789+-=()', '₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎')

def group(s, i):
    """s[i] 应为 '{'，返回 (内容, 结束位置)"""
    if i >= len(s) or s[i] != '{':
        # 单个记号
        if i < len(s) and s[i] == '\\':
            m = re.match(r'\\[A-Za-z]+', s[i:]); return s[i:i + m.end()], i + m.end()
        return (s[i] if i < len(s) else ''), i + 1
    d = 0
    for j in range(i, len(s)):
        if s[j] == '{': d += 1
        elif s[j] == '}':
            d -= 1
            if d == 0: return s[i + 1:j], j + 1
    return s[i + 1:], len(s)

def simple(x): return re.fullmatch(r'[\w′.]+', x) is not None

def math(s, extra=None):
    out, i = '', 0
    while i < len(s):
        c = s[i]
        if c == '\\':
            m = re.match(r'\\([A-Za-z]+|.)', s[i:], re.S)
            if not m: i += 1; continue
            name = m.group(1); i += m.end()
            if name in ('\\', '\n'): out += ' '; continue
            if name in ('frac', 'dfrac', 'tfrac'):
                while i < len(s) and s[i] == ' ': i += 1
                a, i = group(s, i)
                while i < len(s) and s[i] == ' ': i += 1
                b, i = group(s, i); a, b = math(a, extra), math(b, extra)
                out += (a if simple(a) else f'({a})') + '/' + (b if simple(b) else f'({b})')
            elif name == 'sqrt':
                root = ''
                if i < len(s) and s[i] == '[':
                    j = s.index(']', i); root = s[i + 1:j]; i = j + 1
                a, i = group(s, i); a = math(a, extra)
                sign = {'3': '∛', '4': '∜'}.get(root.strip(), '√')
                out += sign + (a if simple(a) else f'({a})')
            elif name in ('text', 'textrm', 'mathrm', 'textit', 'mathit', 'textbf', 'mathbf', 'overline', 'mbox', 'hbox', 'emph', 'textsc', 'upshape', 'operatorname'):
                a, i = group(s, i); out += math(a, extra)
            elif name in GREEK: out += GREEK[name]
            elif name in SYM: out += SYM[name]
            elif extra and name in extra: out += extra[name]
            elif name in ('left', 'right', 'big', 'Big', 'bigl', 'bigr', 'displaystyle', 'nonumber', 'label', 'phantom', 'hspace', 'vspace', 'rule'):
                if name in ('label', 'phantom', 'hspace', 'vspace'):
                    _, i = group(s, i)
                elif name == 'rule':
                    _, i = group(s, i); _, i = group(s, i)
            # 其他命令丢弃
        elif c in '^_':
            a, i = group(s, i + 1); a = math(a, extra)
            t = a.translate(SUP if c == '^' else SUB)
            out += t if all(ch in '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿ₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎' for ch in t) else (c + (a if len(a) == 1 else f'({a})'))
        elif c in '{}': i += 1
        elif c == '~': out += ' '; i += 1
        elif c == '&': out += ' '; i += 1
        else: out += c; i += 1
    return re.sub(r'\s+', ' ', out)

def inline(text, extra=None):
    """一段正文：处理 $…$、常见排版命令"""
    text = re.sub(r'(?<!\\)%.*', '', text)
    def rep_math(m): return math(m.group(1) or m.group(2) or m.group(3) or '', extra)
    text = re.sub(r'\$\$(.+?)\$\$|\\\[(.+?)\\\]|\$(.+?)\$', rep_math, text, flags=re.S)
    return math(text, extra)
