"""《几何原本》卷一命题 1–10：尺规作图动画。同一套作图同时生成英文本（Casey）和中文本（利玛窦、徐光启译）。
用法：python3 tools/anims/euclid.py"""
import sys, os, json, math
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import anim
from anim import *

ZH = dict(zip('ABCDEFGHKL', '甲乙丙丁戊己庚辛壬癸'))
ROMAN = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X']
CN = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十']

def cc(p, r1, q, r2, up=True):
    """两圆交点（y 向下；up=True 取上方那个）"""
    d = math.dist(p, q); a = (r1*r1 - r2*r2 + d*d) / (2*d); h = math.sqrt(max(0, r1*r1 - a*a))
    mx, my = p[0] + a*(q[0]-p[0])/d, p[1] + a*(q[1]-p[1])/d
    s1 = (mx + h*(q[1]-p[1])/d, my - h*(q[0]-p[0])/d); s2 = (mx - h*(q[1]-p[1])/d, my + h*(q[0]-p[0])/d)
    return min(s1, s2, key=lambda s: s[1]) if up else max(s1, s2, key=lambda s: s[1])
def along(p, q, t): return (p[0] + (q[0]-p[0])*t, p[1] + (q[1]-p[1])*t)
def ext(p, q, L):
    """从 p 经 q 延长，使到 q 之外再走 L"""
    d = math.dist(p, q); return (q[0] + (q[0]-p[0])/d*L, q[1] + (q[1]-p[1])/d*L)

PROPS = []
def prop(n, title, build):
    PROPS.append((n, title, build))

# 每个 build(L) 返回 (elements, beats)；L(s) 把字母换成当前语言
def p1(L):
    A, B = (0.34, 0.64), (0.66, 0.64); C = cc(A, 0.32, B, 0.32)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B', color='gold'),
           Circ('c1', 'A', 'B', at=1), Circ('c2', 'B', 'A', at=2), Pt('C', *C, L('C'), at=2),
           Seg('ca', 'C', 'A', at=3), Seg('cb', 'C', 'B', at=3), Poly('t', ['A', 'B', 'C'], color='gold', at=4)]
    return els, [beat(L('已知线段 AB'), 5), beat(L('以 A 为心、AB 为半径作圆'), 6.5),
                 beat(L('以 B 为心、BA 为半径作圆，两圆交于 C'), 7), beat(L('连 CA、CB'), 5.5),
                 beat(L('CA = AB = BC：等边三角形作成'), 7, pulse=['t'])]
prop(1, '在线段上作等边三角形', p1)

def p2(L):
    A, B, C = (0.36, 0.44), (0.56, 0.56), (0.80, 0.44)
    r = math.dist(A, B); D = cc(A, r, B, r)
    G = ext(D, B, math.dist(B, C)); DG = math.dist(D, G); Lp = ext(D, A, DG - r)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Seg('bc', 'B', 'C', color='gold'),
           Seg('ab', 'A', 'B', at=1, dash=True), Pt('D', *D, L('D'), at=1), Seg('da', 'D', 'A', at=1), Seg('db', 'D', 'B', at=1),
           Circ('c1', 'B', 'C', at=2), Hid('Gx', *G, at=2), Pt('G', *G, L('G'), at=2), Seg('bg', 'B', 'G', at=2),
           Circ('c2', 'D', 'G', at=3, dash=True), Pt('L', *Lp, L('L'), at=3), Seg('al', 'A', 'L', color='gold', at=3)]
    return els, [beat(L('要在点 A 作一条线段，与 BC 等长'), 6),
                 beat(L('连 AB，在其上作等边三角形 DAB'), 6.5),
                 beat(L('以 B 为心、BC 为半径作圆，交 DB 延长线于 G'), 7.5),
                 beat(L('以 D 为心、DG 为半径作圆，交 DA 延长线于 L'), 7.5),
                 beat(L('DL = DG，减去相等的 DA、DB，得 AL = BC'), 7.5, pulse=['al', 'bc'])]
prop(2, '在一点作线段等于已知线段', p2)

def p3(L):
    A, B = (0.18, 0.66), (0.86, 0.66); C1, C2 = (0.30, 0.22), (0.62, 0.22)
    r = math.dist(C1, C2); D = (A[0] + r*math.cos(math.radians(55)), A[1] - r*math.sin(math.radians(55))); E = (A[0] + r, A[1])
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'), Hid('c1', *C1), Hid('c2', *C2),
           Seg('c', 'c1', 'c2', L('C'), color='gold'),
           Pt('D', *D, L('D'), at=1), Seg('ad', 'A', 'D', color='gold', at=1, dash=True),
           Circ('k', 'A', 'D', at=2), Pt('E', *E, L('E'), at=2), Seg('ae', 'A', 'E', color='gold', at=3)]
    return els, [beat(L('已知较长的 AB 与较短的 C'), 5.5),
                 beat(L('用上一题的作法，在 A 作 AD 等于 C'), 6.5),
                 beat(L('以 A 为心、AD 为半径作圆，交 AB 于 E'), 6.5),
                 beat(L('AE = AD = C：从长线段上截下了一段'), 6.5, pulse=['ae', 'c'])]
prop(3, '从长线段上截取等于短线段的一段', p3)

def p4(L):
    A, B, C = (0.22, 0.30), (0.08, 0.66), (0.42, 0.62)
    off = 0.48; D, E, F = (A[0]+off, A[1]), (B[0]+off, B[1]), (C[0]+off, C[1])
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t1', ['A', 'B', 'C'], color='silver'),
           Pt('D', *D, L('D')), Pt('E', *E, L('E')), Pt('F', *F, L('F')), Poly('t2', ['D', 'E', 'F'], color='gold'),
           Seg('ab', 'A', 'B', color='blue', at=1), Seg('ac', 'A', 'C', color='green', at=1),
           Seg('de', 'D', 'E', color='blue', at=1), Seg('df', 'D', 'F', color='green', at=1)]
    return els, [beat(L('AB = DE，AC = DF，角 A = 角 D'), 7),
                 beat(L('两边和夹角分别相等'), 6, pulse=['ab', 'de', 'ac', 'df']),
                 beat(L('把三角形 DEF 移过去：D 落在 A，DE 沿着 AB'), 7.5,
                      set={'D': {'x': A[0], 'y': A[1]}, 'E': {'x': B[0], 'y': B[1]}, 'F': {'x': C[0], 'y': C[1]}}),
                 beat(L('夹角相等，DF 沿着 AC，F 落在 C'), 6.5, pulse=['t2']),
                 beat(L('EF 与 BC 重合：两个三角形全等'), 6.5, pulse=['t1'])]
prop(4, '边角边：两三角形全等', p4)

def p5(L):
    A, B, C = (0.5, 0.14), (0.36, 0.46), (0.64, 0.46)
    D, E = along(A, B, 2.4), along(A, C, 2.4); F, G = along(A, B, 1.8), along(A, C, 1.8)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t', ['A', 'B', 'C'], color='silver'),
           Pt('D', *D, L('D'), at=1), Pt('E', *E, L('E'), at=1), Seg('bd', 'B', 'D', at=1), Seg('ce', 'C', 'E', at=1),
           Pt('F', *F, L('F'), at=2), Pt('G', *G, L('G'), at=2),
           Seg('fc', 'F', 'C', color='gold', at=3), Seg('gb', 'G', 'B', color='gold', at=3),
           Poly('afc', ['A', 'F', 'C'], color='gold', at=3), Poly('agb', ['A', 'G', 'B'], color='blue', at=3),
           R('aB', B[0], B[1], 16, color='gold', at=4), R('aC', C[0], C[1], 16, color='gold', at=4)]
    return els, [beat(L('等腰三角形：AB = AC'), 5.5),
                 beat(L('把 AB、AC 延长到 D、E'), 5.5),
                 beat(L('在 BD 上任取 F，在 AE 上截 AG = AF'), 6.5),
                 beat(L('连 FC、GB：AFC 与 AGB 全等'), 8, pulse=['afc', 'agb']),
                 beat(L('层层相减，得底角 ABC = 角 ACB'), 7, pulse=['aB', 'aC'], hide=['afc', 'agb'])]
prop(5, '等腰三角形的两个底角相等', p5)

def p6(L):
    A, B, C = (0.5, 0.18), (0.24, 0.72), (0.76, 0.72)
    D = along(B, A, math.dist(A, C) * 0.82 / math.dist(A, B))
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t', ['A', 'B', 'C'], color='silver'),
           R('aB', B[0], B[1], 18, color='gold'), R('aC', C[0], C[1], 18, color='gold'),
           Pt('D', *D, L('D'), at=1), Seg('dc', 'D', 'C', color='red', at=2, dash=True),
           Poly('dbc', ['D', 'B', 'C'], color='red', at=2)]
    return els, [beat(L('三角形中两个底角 B、C 相等'), 6),
                 beat(L('假设 AB 比 AC 长，在 AB 上截 DB = AC'), 7),
                 beat(L('则三角形 DBC 与 ACB 全等（边角边）'), 7, pulse=['dbc']),
                 beat(L('部分等于整体，荒谬；所以 AB = AC'), 7, pulse=['t'], hide=['D', 'dc', 'dbc'])]
prop(6, '两底角相等的三角形是等腰三角形', p6)

def p7(L):
    A, B = (0.24, 0.72), (0.76, 0.72); C = (0.42, 0.26)
    rA, rB = math.dist(A, C), math.dist(B, C); D = (0.58, 0.30)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'),
           Pt('C', *C, L('C')), Seg('ac', 'A', 'C', color='gold'), Seg('bc', 'B', 'C', color='blue'),
           Pt('D', *D, L('D'), color='red', at=1), Seg('ad', 'A', 'D', color='gold', at=1, dash=True), Seg('bd', 'B', 'D', color='blue', at=1, dash=True),
           Circ('k1', 'A', 'C', at=2, dash=True), Circ('k2', 'B', 'C', at=2, dash=True)]
    return els, [beat(L('在同一底边 AB 上作 AC、BC'), 6),
                 beat(L('能否在同侧另作 D，使 AD = AC、BD = BC？'), 7),
                 beat(L('D 必须同时在这两个圆上'), 8.5),
                 beat(L('两圆在这一侧只交于一点 C：D 不存在'), 7, hide=['D', 'ad', 'bd'], pulse=['C'])]
prop(7, '同底同侧不能有两个对应边相等的三角形', p7)

def p8(L):
    A, B, C = (0.22, 0.26), (0.08, 0.64), (0.44, 0.64)
    off = 0.48; D, E, F = (A[0]+off, A[1]), (B[0]+off, B[1]), (C[0]+off, C[1])
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t1', ['A', 'B', 'C'], color='silver'),
           Pt('D', *D, L('D')), Pt('E', *E, L('E')), Pt('F', *F, L('F')), Poly('t2', ['D', 'E', 'F'], color='gold')]
    return els, [beat(L('三边分别相等：AB = DE，AC = DF，BC = EF'), 7),
                 beat(L('把 EF 放到 BC 上，E 落在 B，F 落在 C'), 7.5,
                      set={'E': {'x': B[0], 'y': B[1]}, 'F': {'x': C[0], 'y': C[1]}, 'D': {'x': A[0] + 0.05, 'y': A[1] - 0.06}}),
                 beat(L('若 D 不落在 A，就违背了上一题'), 6.5, pulse=['D']),
                 beat(L('所以 D 落在 A，夹角相等：两三角形全等'), 7, set={'D': {'x': A[0], 'y': A[1]}}, pulse=['t1'])]
prop(8, '边边边：两三角形全等', p8)

def p9(L):
    A = (0.16, 0.80); ang = math.radians(52)
    B = (0.92, 0.80); C = (A[0] + 0.78*math.cos(ang), A[1] - 0.78*math.sin(ang))
    D = (A[0] + 0.42, A[1]); E = (A[0] + 0.42*math.cos(ang), A[1] - 0.42*math.sin(ang))
    m = along(D, E, 0.5); d = math.dist(D, E); nx, ny = (E[1]-D[1])/d, -(E[0]-D[0])/d
    # 等边三角形的第三点，取远离 A 的一侧
    F1 = (m[0] + nx*d*math.sqrt(3)/2, m[1] + ny*d*math.sqrt(3)/2); F2 = (m[0] - nx*d*math.sqrt(3)/2, m[1] - ny*d*math.sqrt(3)/2)
    F = max(F1, F2, key=lambda f: math.dist(f, A))
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Seg('ab', 'A', 'B'), Seg('ac', 'A', 'C'),
           Pt('D', *D, L('D'), at=1), Circ('k', 'A', 'D', at=1, dash=True), Pt('E', *E, L('E'), at=1),
           Seg('de', 'D', 'E', at=2), Pt('F', *F, L('F'), at=2), Seg('df', 'D', 'F', at=2), Seg('ef', 'E', 'F', at=2),
           Seg('af', 'A', 'F', color='gold', at=3, width=2.6)]
    return els, [beat(L('已知角 BAC，要把它平分'), 5.5),
                 beat(L('以 A 为心作圆，截 AE = AD'), 7.5),
                 beat(L('连 DE，在其上作等边三角形 DEF'), 6.5),
                 beat(L('连 AF：三边对应相等，角 BAF = 角 FAC'), 7.5, pulse=['af'])]
prop(9, '平分一个角', p9)

def p10(L):
    A, B = (0.18, 0.72), (0.82, 0.72); r = math.dist(A, B); C = cc(A, r, B, r); D = along(A, B, 0.5)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'),
           Pt('C', *C, L('C'), at=1), Seg('ca', 'C', 'A', at=1), Seg('cb', 'C', 'B', at=1),
           Pt('D', *D, L('D'), at=2), Seg('cd', 'C', 'D', color='gold', at=2, width=2.4),
           Seg('ad', 'A', 'D', color='gold', at=3), Seg('db', 'D', 'B', color='blue', at=3)]
    return els, [beat(L('已知线段 AB，要找它的中点'), 5.5),
                 beat(L('在 AB 上作等边三角形 ABC（命题 1）'), 6.5),
                 beat(L('平分角 ACB，交 AB 于 D（命题 9）'), 6.5),
                 beat(L('两三角形边角边全等，AD = DB'), 6.5, pulse=['ad', 'db'])]
prop(10, '平分一条线段', p10)

def labeler(lang):
    if lang == 'en': return lambda s: s
    return lambda s: ''.join(ZH.get(c, c) for c in s).replace(' ', '')

def emit(text_id, lang):
    anim.reset()
    doc = json.load(open(os.path.join(anim.ROOT, 'texts', f'{text_id}.json'), encoding='utf-8'))
    secs = doc['sections']; flat = [p for s in secs for p in s['paragraphs']]
    def index_of(pred):
        k = 0
        for s in secs:
            for j, p in enumerate(s['paragraphs']):
                if pred(s['title'], j, p): return k
                k += 1
        raise SystemExit(f'找不到段落 {text_id}')
    L = labeler(lang)
    for n, title, build in PROPS:
        if lang == 'en':
            i = index_of(lambda t, j, p: t.startswith(f'Book I · Prop. {ROMAN[n-1]} (') and j == 0)
            cap = f'Euclid I.{n}'
        else:
            i = index_of(lambda t, j, p: t == '卷一 · 题' and p.startswith(f'第{CN[n-1]}題'))
            cap = f'卷一 · 第{CN[n-1]}题'
        els, beats = build(L)
        scene(i, f'命题 {n} · {title}', els, beats, caption=cap, geo=True)
    return anim._scenes

if __name__ == '__main__':
    for tid, lang in (('euclid-en', 'en'), ('jihe-zh', 'zh')):
        emit(tid, lang); save(tid)
