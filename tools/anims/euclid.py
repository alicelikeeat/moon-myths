"""《几何原本》卷一全部 48 个命题：尺规作图动画。
同一套作图同时生成英文本（Casey）与中文本（利玛窦、徐光启译）：中文本用甲乙丙丁标点、中文标题；英文本用 ABCD、英文标题。
用法：python3 tools/anims/euclid.py"""
import sys, os, json, math
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import anim
from anim import *

ZH = dict(zip('ABCDEFGHKLM', '甲乙丙丁戊己庚辛壬癸子'))
LANG = 'zh'

def cn(n):
    d = '一二三四五六七八九'
    if n <= 10: return (d + '十')[n - 1]
    if n < 20: return '十' + d[n - 11]
    return d[n // 10 - 1] + '十' + (d[n % 10 - 1] if n % 10 else '')
def roman(n):
    out = ''
    for v, r in ((40, 'XL'), (10, 'X'), (9, 'IX'), (5, 'V'), (4, 'IV'), (1, 'I')):
        while n >= v: out += r; n -= v
    return out

def L(s):
    return s if LANG == 'en' else ''.join(ZH.get(c, c) for c in s).replace(' ', '')
def bt(zh, en, dur=6.5, **kw):
    return beat(L(zh) if LANG == 'zh' else en, dur, **kw)

# —— 几何工具（y 向下）
def cc(p, r1, q, r2, up=True):
    d = math.dist(p, q); a = (r1*r1 - r2*r2 + d*d) / (2*d); h = math.sqrt(max(0, r1*r1 - a*a))
    mx, my = p[0] + a*(q[0]-p[0])/d, p[1] + a*(q[1]-p[1])/d
    s1 = (mx + h*(q[1]-p[1])/d, my - h*(q[0]-p[0])/d); s2 = (mx - h*(q[1]-p[1])/d, my + h*(q[0]-p[0])/d)
    return min(s1, s2, key=lambda s: s[1]) if up else max(s1, s2, key=lambda s: s[1])
def along(p, q, t): return (p[0] + (q[0]-p[0])*t, p[1] + (q[1]-p[1])*t)
def mid(p, q): return along(p, q, 0.5)
def ext(p, q, L_):
    d = math.dist(p, q); return (q[0] + (q[0]-p[0])/d*L_, q[1] + (q[1]-p[1])/d*L_)
def add(p, v, k=1): return (p[0] + v[0]*k, p[1] + v[1]*k)
def sub(p, q): return (p[0] - q[0], p[1] - q[1])
def unit(p, q):
    d = math.dist(p, q); return ((q[0]-p[0])/d, (q[1]-p[1])/d)
def foot(p, a, b):
    ux, uy = unit(a, b); t = (p[0]-a[0])*ux + (p[1]-a[1])*uy; return (a[0] + ux*t, a[1] + uy*t)
def inter(p1, p2, p3, p4):
    """直线 p1p2 与 p3p4 的交点"""
    x1, y1 = p1; x2, y2 = p2; x3, y3 = p3; x4, y4 = p4
    den = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4)
    t = ((x1-x3)*(y3-y4) - (y1-y3)*(x3-x4)) / den
    return (x1 + t*(x2-x1), y1 + t*(y2-y1))

_w = [0]
def wedge(id, V, P, Q, r=0.075, color='gold', at=0):
    """角的扇形标记：顶点 V，两边指向 P、Q（取较小的那个角）"""
    a1 = math.atan2(P[1]-V[1], P[0]-V[0]); a2 = math.atan2(Q[1]-V[1], Q[0]-V[0])
    d = (a2 - a1 + math.pi) % (2*math.pi) - math.pi
    pts, els = [f'{id}_v'], [Hid(f'{id}_v', *V, at=at)]
    for k in range(7):
        a = a1 + d*k/6; n = f'{id}_{k}'
        els.append(Hid(n, V[0] + r*math.cos(a), V[1] + r*math.sin(a), at=at)); pts.append(n)
    els.append(Poly(id, pts, color=color, at=at)); return els
def right_mark(id, V, P, Q, s=0.04, at=0, color='gold'):
    u, v = unit(V, P), unit(V, Q)
    a, b, c = add(V, u, s), add(add(V, u, s), v, s), add(V, v, s)
    return [Hid(f'{id}1', *a, at=at), Hid(f'{id}2', *b, at=at), Hid(f'{id}3', *c, at=at),
            Seg(f'{id}s1', f'{id}1', f'{id}2', color=color, at=at), Seg(f'{id}s2', f'{id}2', f'{id}3', color=color, at=at)]
def pts(names, coords, at=0, show=True):
    return [(Pt(n, *coords[n], L(n), at=at) if show else Hid(n, *coords[n], at=at)) for n in names]

PROPS = []
BOOK = [1]
def prop(n, zh, en):
    def deco(f): PROPS.append((BOOK[0], n, zh, en, f)); return f
    return deco

# ———————————————————————————————— 1–10
@prop(1, '在线段上作等边三角形', 'Equilateral triangle on a line')
def _():
    A, B = (0.34, 0.64), (0.66, 0.64); C = cc(A, 0.32, B, 0.32)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B', color='gold'),
           Circ('c1', 'A', 'B', at=1), Circ('c2', 'B', 'A', at=2), Pt('C', *C, L('C'), at=2),
           Seg('ca', 'C', 'A', at=3), Seg('cb', 'C', 'B', at=3), Poly('t', ['A', 'B', 'C'], color='gold', at=4)]
    return els, [bt('已知线段 AB', 'Given the line AB', 5), bt('以 A 为心、AB 为半径作圆', 'Circle with centre A, radius AB'),
                 bt('以 B 为心作圆，两圆交于 C', 'Circle with centre B; they meet at C', 7), bt('连 CA、CB', 'Join CA and CB', 5.5),
                 bt('CA = AB = BC：等边三角形', 'CA = AB = BC: equilateral', 7, pulse=['t'])]

@prop(2, '在一点作线段等于已知线段', 'A line at a point equal to a given line')
def _():
    A, B, C = (0.40, 0.46), (0.54, 0.56), (0.76, 0.46)
    r = math.dist(A, B); D = cc(A, r, B, r)
    G = ext(D, B, math.dist(B, C)); DG = math.dist(D, G); Lp = ext(D, A, DG - r)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Seg('bc', 'B', 'C', color='gold'),
           Seg('ab', 'A', 'B', at=1, dash=True), Pt('D', *D, L('D'), at=1), Seg('da', 'D', 'A', at=1), Seg('db', 'D', 'B', at=1),
           Circ('c1', 'B', 'C', at=2), Pt('G', *G, L('G'), at=2), Seg('bg', 'B', 'G', at=2),
           Circ('c2', 'D', 'G', at=3, dash=True), Pt('L', *Lp, L('L'), at=3), Seg('al', 'A', 'L', color='gold', at=3)]
    return els, [bt('要在点 A 作线段，与 BC 等长', 'At A, place a line equal to BC', 6),
                 bt('连 AB，作等边三角形 DAB', 'Join AB; build equilateral DAB'),
                 bt('以 B 为心、BC 为半径作圆，交于 G', 'Circle B, radius BC, meets DB at G', 7.5),
                 bt('以 D 为心、DG 为半径作圆，交于 L', 'Circle D, radius DG, meets DA at L', 7.5),
                 bt('DL = DG，各减等边，AL = BC', 'DL = DG; take equals away: AL = BC', 7.5, pulse=['al', 'bc'])]

@prop(3, '从长线段上截取一段等于短线段', 'Cut off from the greater a part equal to the less')
def _():
    A, B = (0.16, 0.66), (0.88, 0.66); C1, C2 = (0.30, 0.22), (0.62, 0.22)
    r = math.dist(C1, C2); D = (A[0] + r*math.cos(math.radians(55)), A[1] - r*math.sin(math.radians(55))); E = (A[0] + r, A[1])
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'), Hid('c1', *C1), Hid('c2', *C2),
           Seg('c', 'c1', 'c2', L('C'), color='gold'),
           Pt('D', *D, L('D'), at=1), Seg('ad', 'A', 'D', color='gold', at=1, dash=True),
           Circ('k', 'A', 'D', at=2), Pt('E', *E, L('E'), at=2), Seg('ae', 'A', 'E', color='gold', at=3)]
    return els, [bt('已知较长的 AB 与较短的 C', 'Given AB, the greater, and C, the less', 5.5),
                 bt('用命题 2，在 A 作 AD = C', 'By Prop. 2, place AD equal to C'),
                 bt('以 A 为心、AD 为半径作圆，交 AB 于 E', 'Circle A, radius AD, cuts AB at E'),
                 bt('AE = AD = C', 'AE = AD = C', 6.5, pulse=['ae', 'c'])]

@prop(4, '边角边：两三角形全等', 'Side-angle-side congruence')
def _():
    A, B, C = (0.22, 0.30), (0.08, 0.66), (0.42, 0.62)
    off = 0.48; D, E, F = (A[0]+off, A[1]), (B[0]+off, B[1]), (C[0]+off, C[1])
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t1', ['A', 'B', 'C'], color='silver'),
           Pt('D', *D, L('D')), Pt('E', *E, L('E')), Pt('F', *F, L('F')), Poly('t2', ['D', 'E', 'F'], color='gold'),
           Seg('ab', 'A', 'B', color='blue', at=1), Seg('ac', 'A', 'C', color='green', at=1),
           Seg('de', 'D', 'E', color='blue', at=1), Seg('df', 'D', 'F', color='green', at=1)]
    return els, [bt('两个三角形', 'Two triangles', 5.5),
                 bt('AB = DE，AC = DF，角 A = 角 D', 'AB = DE, AC = DF, angle A = angle D', 6.5, pulse=['ab', 'de', 'ac', 'df']),
                 bt('把 D 放到 A，DE 沿着 AB', 'Lay D on A and DE along AB', 7.5,
                    set={'D': {'x': A[0], 'y': A[1]}, 'E': {'x': B[0], 'y': B[1]}, 'F': {'x': C[0], 'y': C[1]}}),
                 bt('夹角相等，F 落在 C', 'The angles agree, so F falls on C', 6.5, pulse=['t2']),
                 bt('EF 与 BC 重合：两三角形全等', 'EF coincides with BC: congruent', 6.5, pulse=['t1'])]

@prop(5, '等腰三角形两底角相等', 'Base angles of an isosceles triangle')
def _():
    A, B, C = (0.5, 0.14), (0.36, 0.46), (0.64, 0.46)
    D, E = along(A, B, 2.4), along(A, C, 2.4); F, G = along(A, B, 1.8), along(A, C, 1.8)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t', ['A', 'B', 'C'], color='silver'),
           Pt('D', *D, L('D'), at=1), Pt('E', *E, L('E'), at=1), Seg('bd', 'B', 'D', at=1), Seg('ce', 'C', 'E', at=1),
           Pt('F', *F, L('F'), at=2), Pt('G', *G, L('G'), at=2),
           Seg('fc', 'F', 'C', color='gold', at=3), Seg('gb', 'G', 'B', color='gold', at=3),
           Poly('afc', ['A', 'F', 'C'], color='gold', at=3), Poly('agb', ['A', 'G', 'B'], color='blue', at=3)]
    els += wedge('wb', B, A, C, at=4) + wedge('wc', C, A, B, at=4)
    return els, [bt('等腰三角形：AB = AC', 'Isosceles: AB = AC', 5.5),
                 bt('延长 AB、AC 到 D、E', 'Produce AB, AC to D, E', 5.5),
                 bt('在 BD 上取 F，截 AG = AF', 'Take F on BD; cut off AG = AF'),
                 bt('连 FC、GB：AFC 与 AGB 全等', 'Join FC, GB: AFC and AGB congruent', 8, pulse=['afc', 'agb']),
                 bt('相减得：角 ABC = 角 ACB', 'Subtracting: angle ABC = angle ACB', 7, pulse=['wb', 'wc'], hide=['afc', 'agb'])]

@prop(6, '两底角相等则两腰相等', 'Equal base angles give equal sides')
def _():
    A, B, C = (0.5, 0.18), (0.24, 0.72), (0.76, 0.72)
    D = along(B, A, math.dist(A, C) * 0.82 / math.dist(A, B))
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t', ['A', 'B', 'C'], color='silver')]
    els += wedge('wb', B, A, C) + wedge('wc', C, A, B)
    els += [Pt('D', *D, L('D'), at=1), Seg('dc', 'D', 'C', color='red', at=2, dash=True), Poly('dbc', ['D', 'B', 'C'], color='red', at=2)]
    return els, [bt('底角 B、C 相等', 'Angles at B and C are equal', 6),
                 bt('假设 AB 较长，截 DB = AC', 'Suppose AB greater; cut off DB = AC', 7),
                 bt('则三角形 DBC 与 ACB 全等', 'Then DBC would equal ACB', 7, pulse=['dbc']),
                 bt('部分等于整体，荒谬：AB = AC', 'The part equals the whole: absurd. AB = AC', 7, pulse=['t'], hide=['D', 'dc', 'dbc'])]

@prop(7, '同底同侧不能另有对应边相等的三角形', 'No second triangle with equal sides on the same base')
def _():
    A, B = (0.30, 0.74), (0.70, 0.74); C = (0.44, 0.40); D = (0.57, 0.43)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'),
           Pt('C', *C, L('C')), Seg('ac', 'A', 'C', color='gold'), Seg('bc', 'B', 'C', color='blue'),
           Pt('D', *D, L('D'), color='red', at=1), Seg('ad', 'A', 'D', color='gold', at=1, dash=True), Seg('bd', 'B', 'D', color='blue', at=1, dash=True),
           Circ('k1', 'A', 'C', at=2, dash=True), Circ('k2', 'B', 'C', at=2, dash=True)]
    return els, [bt('在底边 AB 上作 AC、BC', 'On the base AB stand AC and BC', 6),
                 bt('能否另作 D，使 AD = AC、BD = BC？', 'Could D give AD = AC and BD = BC?', 7),
                 bt('D 必须同时在这两个圆上', 'D would have to lie on both circles', 8),
                 bt('两圆在这一侧只交于 C：D 不存在', 'On this side they meet only at C', 7, hide=['D', 'ad', 'bd'], pulse=['C'])]

@prop(8, '边边边：两三角形全等', 'Side-side-side congruence')
def _():
    A, B, C = (0.22, 0.26), (0.08, 0.64), (0.44, 0.64)
    off = 0.48; D, E, F = (A[0]+off, A[1]), (B[0]+off, B[1]), (C[0]+off, C[1])
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Poly('t1', ['A', 'B', 'C'], color='silver'),
           Pt('D', *D, L('D')), Pt('E', *E, L('E')), Pt('F', *F, L('F')), Poly('t2', ['D', 'E', 'F'], color='gold')]
    return els, [bt('三边分别相等', 'Three sides equal, each to each', 6.5),
                 bt('把 EF 放到 BC 上', 'Lay EF upon BC', 7.5,
                    set={'E': {'x': B[0], 'y': B[1]}, 'F': {'x': C[0], 'y': C[1]}, 'D': {'x': A[0] + 0.05, 'y': A[1] - 0.06}}),
                 bt('若 D 不落在 A，就违背命题 7', 'If D missed A, Prop. 7 would fail', 6.5, pulse=['D']),
                 bt('D 落在 A：两三角形全等', 'D falls on A: the triangles agree', 7, set={'D': {'x': A[0], 'y': A[1]}}, pulse=['t1'])]

@prop(9, '平分一个角', 'Bisect an angle')
def _():
    A = (0.16, 0.80); ang = math.radians(52)
    B = (0.92, 0.80); C = (A[0] + 0.78*math.cos(ang), A[1] - 0.78*math.sin(ang))
    D = (A[0] + 0.42, A[1]); E = (A[0] + 0.42*math.cos(ang), A[1] - 0.42*math.sin(ang))
    m = mid(D, E); d = math.dist(D, E); nx, ny = (E[1]-D[1])/d, -(E[0]-D[0])/d
    F = max((m[0] + nx*d*math.sqrt(3)/2, m[1] + ny*d*math.sqrt(3)/2), (m[0] - nx*d*math.sqrt(3)/2, m[1] - ny*d*math.sqrt(3)/2), key=lambda f: math.dist(f, A))
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Pt('C', *C, L('C')), Seg('ab', 'A', 'B'), Seg('ac', 'A', 'C'),
           Pt('D', *D, L('D'), at=1), Circ('k', 'A', 'D', at=1, dash=True), Pt('E', *E, L('E'), at=1),
           Seg('de', 'D', 'E', at=2), Pt('F', *F, L('F'), at=2), Seg('df', 'D', 'F', at=2), Seg('ef', 'E', 'F', at=2),
           Seg('af', 'A', 'F', color='gold', at=3, width=2.6)]
    return els, [bt('已知角 BAC', 'Given the angle BAC', 5.5),
                 bt('以 A 为心作圆，截 AE = AD', 'Circle about A: cut off AE = AD', 7.5),
                 bt('在 DE 上作等边三角形 DEF', 'On DE build the equilateral DEF'),
                 bt('连 AF：角 BAF = 角 FAC', 'Join AF: angle BAF = angle FAC', 7.5, pulse=['af'])]

@prop(10, '平分一条线段', 'Bisect a line')
def _():
    A, B = (0.18, 0.72), (0.82, 0.72); r = math.dist(A, B); C = cc(A, r, B, r); D = mid(A, B)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'),
           Pt('C', *C, L('C'), at=1), Seg('ca', 'C', 'A', at=1), Seg('cb', 'C', 'B', at=1),
           Pt('D', *D, L('D'), at=2), Seg('cd', 'C', 'D', color='gold', at=2, width=2.4),
           Seg('ad', 'A', 'D', color='gold', at=3), Seg('db', 'D', 'B', color='blue', at=3)]
    return els, [bt('已知线段 AB', 'Given the line AB', 5.5),
                 bt('作等边三角形 ABC（命题 1）', 'Build equilateral ABC (Prop. 1)'),
                 bt('平分角 ACB，交 AB 于 D（命题 9）', 'Bisect angle ACB by CD (Prop. 9)'),
                 bt('边角边全等：AD = DB', 'By side-angle-side, AD = DB', 6.5, pulse=['ad', 'db'])]

# ———————————————————————————————— 11–15 垂线与对顶角
@prop(11, '从线上一点作垂线', 'Perpendicular from a point on a line')
def _():
    A, B, C = (0.08, 0.72), (0.92, 0.72), (0.5, 0.72); D, E = (0.32, 0.72), (0.68, 0.72)
    F = cc(D, 0.36, E, 0.36)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'), Pt('C', *C, L('C')),
           Circ('k', 'C', 'D', at=1, dash=True), Pt('D', *D, L('D'), at=1), Pt('E', *E, L('E'), at=1),
           Pt('F', *F, L('F'), at=2), Seg('df', 'D', 'F', at=2), Seg('ef', 'E', 'F', at=2),
           Seg('cf', 'C', 'F', color='gold', at=3, width=2.6)] + right_mark('rm', C, B, F, at=3)
    return els, [bt('在直线 AB 上有一点 C', 'A point C on the line AB', 5.5),
                 bt('以 C 为心作圆，截 CD = CE', 'Circle about C: CD = CE'),
                 bt('在 DE 上作等边三角形 DEF', 'Build the equilateral DEF on DE'),
                 bt('连 CF：两旁的角相等，都是直角', 'Join CF: the adjacent angles are right', 7, pulse=['cf'])]

@prop(12, '从线外一点作垂线', 'Perpendicular from a point off the line')
def _():
    A, B, C, D = (0.06, 0.70), (0.94, 0.70), (0.56, 0.46), (0.44, 0.84)
    r = math.dist(C, D); dx = math.sqrt(r*r - (0.70-C[1])**2); G, E = (C[0]-dx, 0.70), (C[0]+dx, 0.70); H = mid(G, E)
    els = [Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B'), Pt('C', *C, L('C')),
           Pt('D', *D, L('D'), at=1), Circ('k', 'C', 'D', at=1, dash=True), Pt('G', *G, L('G'), at=1), Pt('E', *E, L('E'), at=1),
           Pt('H', *H, L('H'), at=2), Seg('cg', 'C', 'G', at=2), Seg('ce', 'C', 'E', at=2),
           Seg('ch', 'C', 'H', color='gold', at=3, width=2.6)] + right_mark('rm', H, B, C, at=3)
    return els, [bt('直线 AB 外有一点 C', 'A point C outside the line AB', 5.5),
                 bt('以 C 为心作圆，交 AB 于 G、E', 'Circle about C meets AB at G, E'),
                 bt('平分 GE 于 H（命题 10）', 'Bisect GE at H (Prop. 10)'),
                 bt('连 CH：CH 垂直于 AB', 'Join CH: it is perpendicular', 7, pulse=['ch'])]

@prop(13, '邻角之和等于两直角', 'Adjacent angles make two right angles')
def _():
    C, D, B, A, E = (0.08, 0.70), (0.92, 0.70), (0.5, 0.70), (0.28, 0.26), (0.5, 0.22)
    els = pts('CDBA', {'C': C, 'D': D, 'B': B, 'A': A}) + [Seg('cd', 'C', 'D'), Seg('ab', 'A', 'B', color='gold')]
    els += wedge('w1', B, C, A, r=0.09, color='red', at=1) + wedge('w2', B, A, D, r=0.09, color='blue', at=1)
    els += [Pt('E', *E, L('E'), at=2), Seg('be', 'B', 'E', dash=True, at=2)] + right_mark('rm', B, D, E, at=2)
    return els, [bt('直线 AB 立在 CD 上', 'The line AB stands on CD', 5.5),
                 bt('得到两个邻角 CBA、ABD', 'It makes the angles CBA and ABD'),
                 bt('作 BE 垂直于 CD', 'Draw BE at right angles to CD'),
                 bt('两角之和 = 两个直角', 'Together they equal two right angles', 7, pulse=['w1', 'w2'])]

@prop(14, '两邻角和为两直角，则成一直线', 'Two right angles make a straight line')
def _():
    A, B, C, D, E = (0.5, 0.22), (0.5, 0.66), (0.10, 0.70), (0.90, 0.62), (0.90, 0.70)
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Seg('ab', 'A', 'B'), Seg('cb', 'C', 'B'), Seg('bd', 'B', 'D', color='gold')]
    els += wedge('w1', B, C, A, color='red') + wedge('w2', B, A, D, color='blue')
    els += [Pt('E', *E, L('E'), at=1), Seg('be', 'B', 'E', dash=True, color='red', at=1)]
    return els, [bt('角 CBA + 角 ABD = 两直角', 'Angles CBA + ABD = two right angles', 6.5),
                 bt('假设 BE 才是 CB 的延长线', 'Suppose instead BE continued CB', 6.5),
                 bt('那么角 ABE 就等于角 ABD，部分等于整体', 'Then ABE would equal ABD: absurd', 7.5),
                 bt('所以 CB、BD 在一条直线上', 'So CB and BD are one straight line', 6.5, hide=['E', 'be'], pulse=['bd'])]

@prop(15, '对顶角相等', 'Vertical angles are equal')
def _():
    A, B, C, D = (0.10, 0.28), (0.90, 0.76), (0.10, 0.76), (0.90, 0.28); E = inter(A, B, C, D)
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Seg('ab', 'A', 'B'), Seg('cd', 'C', 'D'), Pt('E', *E, L('E'))]
    els += wedge('w1', E, A, C, r=0.1, color='gold', at=1) + wedge('w3', E, C, B, r=0.1, color='blue', at=2) + wedge('w2', E, D, B, r=0.1, color='gold', at=3)
    return els, [bt('两直线交于 E', 'Two lines cut at E', 5.5),
                 bt('角 AEC', 'The angle AEC'),
                 bt('AEC + CEB = 两直角 = CEB + BED', 'AEC + CEB = two right = CEB + BED', 7.5),
                 bt('减去公共的 CEB：AEC = BED', 'Take away CEB: AEC = BED', 7, pulse=['w1', 'w2'])]

# ———————————————————————————————— 16–21 三角形的不等关系
@prop(16, '外角大于任一不相邻内角', 'Exterior angle exceeds either remote interior angle')
def _():
    B, C, D, A = (0.10, 0.76), (0.60, 0.76), (0.94, 0.76), (0.38, 0.28)
    E = mid(A, C); F = ext(B, E, math.dist(B, E))
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Poly('t', ['A', 'B', 'C'], color='silver'), Seg('cd', 'C', 'D')]
    els += [Pt('E', *E, L('E'), at=1), Pt('F', *F, L('F'), at=1), Seg('bf', 'B', 'F', at=1), Seg('fc', 'F', 'C', color='gold', at=1)]
    els += wedge('wa', A, B, C, color='red', at=2) + wedge('wf', C, A, F, color='red', at=2) + wedge('wx', C, A, D, r=0.11, color='blue', at=3)
    return els, [bt('延长 BC 到 D', 'Produce BC to D', 5.5),
                 bt('平分 AC 于 E，延长 BE 到 F，EF = BE', 'Bisect AC at E; make EF = BE', 7.5),
                 bt('三角形 ABE 与 CFE 全等：角 A = 角 ECF', 'ABE ≅ CFE, so angle A = angle ECF', 7.5, pulse=['wa', 'wf']),
                 bt('角 ACD 大于角 ECF，即大于角 A', 'ACD exceeds ECF, that is, angle A', 7, pulse=['wx'])]

@prop(17, '三角形任两角之和小于两直角', 'Any two angles are less than two right angles')
def _():
    B, C, D, A = (0.14, 0.72), (0.62, 0.72), (0.94, 0.72), (0.40, 0.26)
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Poly('t', ['A', 'B', 'C'], color='silver'), Seg('cd', 'C', 'D', at=1)]
    els += wedge('wb', B, A, C, color='red') + wedge('wc', C, A, B, color='blue') + wedge('wx', C, A, D, color='gold', at=1)
    return els, [bt('三角形 ABC 中的角 B 与角 C', 'Angles B and C of the triangle', 6),
                 bt('延长 BC：外角 ACD 大于角 B（命题 16）', 'Exterior ACD exceeds B (Prop. 16)', 7, pulse=['wx', 'wb']),
                 bt('B + ACB < ACD + ACB', 'B + ACB < ACD + ACB', 6.5),
                 bt('而 ACD + ACB = 两直角', 'and ACD + ACB = two right angles', 6.5, pulse=['wx', 'wc'])]

@prop(18, '大边对大角', 'The greater side subtends the greater angle')
def _():
    A, B, C = (0.30, 0.22), (0.12, 0.72), (0.88, 0.72)
    D = along(A, C, math.dist(A, B) / math.dist(A, C))
    els = pts('ABC', {'A': A, 'B': B, 'C': C}) + [Poly('t', ['A', 'B', 'C'], color='silver')]
    els += [Pt('D', *D, L('D'), at=1), Seg('bd', 'B', 'D', color='gold', at=1)]
    els += wedge('w1', B, A, D, color='blue', at=2) + wedge('w2', D, A, B, color='blue', at=2) + wedge('wc', C, A, B, color='red', at=3)
    return els, [bt('AC 比 AB 长', 'AC is greater than AB', 5.5),
                 bt('截 AD = AB，连 BD', 'Cut off AD = AB and join BD'),
                 bt('角 ABD = 角 ADB（命题 5）', 'Angle ABD = angle ADB (Prop. 5)', 6.5, pulse=['w1', 'w2']),
                 bt('ADB 大于角 C，所以角 B 大于角 C', 'ADB exceeds C, so angle B exceeds C', 7.5, pulse=['wc'])]

@prop(19, '大角对大边', 'The greater angle is subtended by the greater side')
def _():
    A, B, C = (0.30, 0.22), (0.12, 0.72), (0.88, 0.72)
    els = pts('ABC', {'A': A, 'B': B, 'C': C}) + [Poly('t', ['A', 'B', 'C'], color='silver')]
    els += wedge('wb', B, A, C, color='blue') + wedge('wc', C, A, B, color='red')
    els += [Seg('ac', 'A', 'C', color='gold', at=3, width=2.6)]
    return els, [bt('角 B 大于角 C', 'Angle B is greater than angle C', 5.5),
                 bt('若 AC = AB，两角应相等（命题 5）', 'If AC = AB the angles would be equal', 7),
                 bt('若 AC < AB，角 B 应较小（命题 18）', 'If AC < AB, B would be the less', 7),
                 bt('所以 AC 大于 AB', 'Therefore AC is greater than AB', 6, pulse=['ac'])]

@prop(20, '两边之和大于第三边', 'Two sides are greater than the third')
def _():
    B, C, A = (0.12, 0.76), (0.88, 0.76), (0.36, 0.50)
    D = ext(B, A, math.dist(A, C))
    els = pts('ABC', {'A': A, 'B': B, 'C': C}) + [Poly('t', ['A', 'B', 'C'], color='silver')]
    els += [Pt('D', *D, L('D'), at=1), Seg('ad', 'A', 'D', dash=True, at=1), Seg('dc', 'D', 'C', at=1)]
    els += wedge('w1', D, A, C, color='blue', at=2) + wedge('w2', C, D, A, color='blue', at=2) + wedge('w3', C, D, B, r=0.1, color='red', at=3)
    return els, [bt('要证 BA + AC 大于 BC', 'To show BA + AC > BC', 5.5),
                 bt('延长 BA 到 D，AD = AC，连 DC', 'Produce BA to D, AD = AC; join DC'),
                 bt('角 ADC = 角 ACD', 'Angle ADC = angle ACD', 6, pulse=['w1', 'w2']),
                 bt('角 BCD 更大，所以 BD > BC，即 BA + AC > BC', 'BCD is greater, so BD = BA + AC > BC', 8, pulse=['w3'])]

@prop(21, '三角形内一点', 'Two lines drawn to a point within')
def _():
    B, C, A, D = (0.08, 0.80), (0.92, 0.80), (0.44, 0.16), (0.52, 0.58)
    E = inter(B, D, A, C)
    els = pts('ABC', {'A': A, 'B': B, 'C': C}) + [Poly('t', ['A', 'B', 'C'], color='silver')]
    els += [Pt('D', *D, L('D'), at=1), Seg('bd', 'B', 'D', color='gold', at=1), Seg('dc', 'D', 'C', color='gold', at=1)]
    els += [Pt('E', *E, L('E'), at=2), Seg('de', 'D', 'E', dash=True, at=2)]
    els += wedge('wa', A, B, C, color='red', at=3) + wedge('wd', D, B, C, color='blue', at=3)
    return els, [bt('三角形 ABC', 'The triangle ABC', 5),
                 bt('从 B、C 向内一点 D 连线', 'From B and C draw lines to D within'),
                 bt('延长 BD 到 E：BD + DC < BA + AC', 'Produce BD to E: BD + DC < BA + AC', 7.5),
                 bt('而角 BDC 大于角 BAC', 'but the angle BDC exceeds BAC', 7, pulse=['wd'])]

# ———————————————————————————————— 22–26 作三角形、作角、全等
@prop(22, '用三条线段作三角形', 'A triangle from three given lines')
def _():
    a, b, c = 0.30, 0.36, 0.44
    F, G = (0.28, 0.80), (0.28 + c, 0.80); K = cc(F, a, G, b)
    ref = {'a1': (0.06, 0.08), 'a2': (0.06 + a, 0.08), 'b1': (0.06, 0.16), 'b2': (0.06 + b, 0.16), 'c1': (0.06, 0.24), 'c2': (0.06 + c, 0.24)}
    els = [Hid(n, *p) for n, p in ref.items()] + [Seg('sa', 'a1', 'a2', 'a', color='red'), Seg('sb', 'b1', 'b2', 'b', color='blue'), Seg('sc', 'c1', 'c2', 'c', color='gold')]
    els += [Pt('F', *F, L('F'), at=1), Pt('G', *G, L('G'), at=1), Seg('fg', 'F', 'G', color='gold', at=1)]
    els += [Hid('fa', F[0] + a, F[1], at=2), Hid('gb', G[0] - b, G[1], at=2), Circ('k1', 'F', 'fa', dash=True, at=2), Circ('k2', 'G', 'gb', dash=True, at=2),
            Pt('K', *K, L('K'), at=2), Seg('fk', 'F', 'K', color='red', at=3), Seg('gk', 'G', 'K', color='blue', at=3)]
    return els, [bt('三条线段，任两条之和大于第三条', 'Three lines, any two greater than the third', 6.5),
                 bt('取 FG 等于 c', 'Take FG equal to c', 5.5),
                 bt('以 F、G 为心，a、b 为半径作圆，交于 K', 'Circles of radius a and b meet at K', 7.5),
                 bt('三角形 KFG 的三边就是 a、b、c', 'KFG has sides a, b and c', 6.5)]

@prop(23, '在一点作角等于已知角', 'Copy an angle at a point')
def _():
    C, D, E = (0.10, 0.36), (0.40, 0.24), (0.36, 0.52)
    A, B = (0.46, 0.82), (0.94, 0.82)
    F = (A[0] + math.dist(C, D), A[1]); G = cc(A, math.dist(C, E), F, math.dist(D, E))
    els = pts('CDE', {'C': C, 'D': D, 'E': E}) + [Seg('cd', 'C', 'D'), Seg('ce', 'C', 'E'), Pt('A', *A, L('A')), Pt('B', *B, L('B')), Seg('ab', 'A', 'B')]
    els += wedge('w0', C, D, E, color='gold')
    els += [Seg('de', 'D', 'E', dash=True, at=1), Poly('t0', ['C', 'D', 'E'], color='silver', at=1)]
    els += [Pt('F', *F, L('F'), at=2), Pt('G', *G, L('G'), at=2), Seg('ag', 'A', 'G', at=2), Seg('fg', 'F', 'G', dash=True, at=2), Poly('t1', ['A', 'F', 'G'], color='silver', at=2)]
    els += wedge('w1', A, F, G, color='gold', at=3)
    return els, [bt('已知角 DCE 与直线 AB 上的点 A', 'Angle DCE, and the point A on AB', 6.5),
                 bt('连 DE 成三角形 CDE', 'Join DE to make the triangle CDE'),
                 bt('用三边作三角形 AFG（命题 22）', 'Build AFG from the same sides (Prop. 22)', 7),
                 bt('边边边全等：角 FAG = 角 DCE', 'By Prop. 8, angle FAG = angle DCE', 7, pulse=['w0', 'w1'])]

@prop(24, '夹角较大则对边较长', 'The greater included angle has the greater base')
def _():
    A = (0.5, 0.14); B = (0.18, 0.72)
    ang = lambda deg, r: (A[0] + r*math.cos(math.radians(deg)), A[1] + r*math.sin(math.radians(deg)))
    C, G = ang(38, 0.56), ang(72, 0.56)
    els = pts('ABC', {'A': A, 'B': B, 'C': C}) + [Seg('ab', 'A', 'B'), Seg('ac', 'A', 'C'), Seg('bc', 'B', 'C', color='gold')]
    els += [Pt('G', *G, L('G'), at=1), Seg('ag', 'A', 'G', at=1, dash=True), Seg('bg', 'B', 'G', color='blue', at=1)]
    els += [Seg('cg', 'C', 'G', dash=True, at=2)] + wedge('wg', G, B, C, color='blue', at=2) + wedge('wc', C, G, B, color='red', at=2)
    return els, [bt('AB、AC 与另一三角形两边相等，角 A 较大', 'Two sides equal, the angle at A greater', 7),
                 bt('把小三角形放进来：AG = AC，BG 是它的底', 'Place the other inside: AG = AC, base BG', 7),
                 bt('连 CG：角 BGC 大于角 BCG', 'Join CG: angle BGC exceeds BCG', 7, pulse=['wg']),
                 bt('所以 BC 大于 BG（命题 19）', 'Hence BC is greater than BG (Prop. 19)', 6.5, pulse=['bc'])]

@prop(25, '对边较长则夹角较大', 'The greater base has the greater included angle')
def _():
    A = (0.5, 0.14); B = (0.18, 0.72)
    ang = lambda deg, r: (A[0] + r*math.cos(math.radians(deg)), A[1] + r*math.sin(math.radians(deg)))
    C, G = ang(38, 0.56), ang(72, 0.56)
    els = pts('ABC', {'A': A, 'B': B, 'C': C}) + [Seg('ab', 'A', 'B'), Seg('ac', 'A', 'C'), Seg('bc', 'B', 'C', color='gold')]
    els += [Pt('G', *G, L('G')), Seg('ag', 'A', 'G', dash=True), Seg('bg', 'B', 'G', color='blue')]
    els += wedge('w1', A, B, C, r=0.12, color='gold', at=3)
    return els, [bt('两边分别相等，BC 大于 BG', 'Two sides equal, and BC greater than BG', 6.5),
                 bt('若两夹角相等，底也相等（命题 4）', 'Equal angles would give equal bases', 6.5),
                 bt('若角 A 较小，底也较小（命题 24）', 'A smaller angle would give a smaller base', 6.5),
                 bt('所以角 BAC 较大', 'So the angle BAC is the greater', 6, pulse=['w1'])]

@prop(26, '角边角：两三角形全等', 'Angle-side-angle congruence')
def _():
    A, B, C = (0.20, 0.30), (0.06, 0.70), (0.44, 0.70)
    off = 0.48; D, E, F = (A[0]+off, A[1]), (B[0]+off, B[1]), (C[0]+off, C[1])
    G = along(B, A, 0.72)
    els = pts('ABCDEF', {'A': A, 'B': B, 'C': C, 'D': D, 'E': E, 'F': F}) + [Poly('t1', ['A', 'B', 'C'], color='silver'), Poly('t2', ['D', 'E', 'F'], color='gold')]
    els += wedge('wb', B, A, C, color='blue') + wedge('wc', C, A, B, color='red') + wedge('we', E, D, F, color='blue') + wedge('wf', F, D, E, color='red')
    els += [Pt('G', *G, L('G'), at=2), Seg('gc', 'G', 'C', dash=True, color='red', at=2)]
    return els, [bt('角 B = 角 E，角 C = 角 F', 'Angle B = E, angle C = F', 6),
                 bt('夹边 BC = EF', 'and the sides between them, BC = EF', 6),
                 bt('若 AB 较长，截 GB = DE', 'If AB were greater, cut off GB = DE', 7),
                 bt('则角 GCB = 角 F = 角 ACB，荒谬：全等', 'Then GCB = ACB, absurd: congruent', 7.5, hide=['G', 'gc'], pulse=['t1', 't2'])]

# ———————————————————————————————— 27–32 平行线
def parallels(at_t=0):
    A, B, C, D = (0.06, 0.30), (0.94, 0.30), (0.06, 0.70), (0.94, 0.70)
    E, F = (0.40, 0.30), (0.62, 0.70)
    G, H = ext(F, E, 0.14), ext(E, F, 0.14)
    co = {'A': A, 'B': B, 'C': C, 'D': D, 'E': E, 'F': F, 'G': G, 'H': H}
    els = pts('ABCDEF', co) + [Seg('ab', 'A', 'B'), Seg('cd', 'C', 'D'), Hid('G', *G), Hid('H', *H), Seg('gh', 'G', 'H', color='gold', at=at_t)]
    return co, els

@prop(27, '内错角相等则两线平行', 'Equal alternate angles: the lines are parallel')
def _():
    co, els = parallels()
    els += wedge('w1', co['E'], co['A'], co['F'], color='blue', at=1) + wedge('w2', co['F'], co['D'], co['E'], color='blue', at=1)
    els += [Hid('X', 0.98, 0.52, at=2), Seg('bx', 'B', 'X', dash=True, color='red', at=2), Seg('dx', 'D', 'X', dash=True, color='red', at=2)]
    return els, [bt('直线 EF 与 AB、CD 相交', 'The line EF falls on AB and CD', 5.5),
                 bt('内错角 AEF = 角 EFD', 'The alternate angles AEF, EFD are equal', 6.5, pulse=['w1', 'w2']),
                 bt('假设两线延长后相交', 'Suppose the lines met when produced', 6.5),
                 bt('外角将等于内对角，违背命题 16：平行', 'Prop. 16 forbids it: they are parallel', 7.5, hide=['X', 'bx', 'dx'])]

@prop(28, '同位角相等或同旁内角互补则平行', 'Equal corresponding angles: the lines are parallel')
def _():
    co, els = parallels()
    els += wedge('w1', co['E'], co['G'], co['B'], color='blue', at=1) + wedge('w2', co['F'], co['E'], co['D'], color='blue', at=1)
    els += wedge('w3', co['E'], co['B'], co['F'], color='red', at=2)
    return els, [bt('EF 与 AB、CD 相交', 'EF cuts AB and CD', 5.5),
                 bt('同位角 GEB = 角 EFD', 'The angles GEB and EFD are equal', 6.5, pulse=['w1', 'w2']),
                 bt('或同旁内角 BEF + EFD = 两直角', 'or BEF + EFD make two right angles', 7),
                 bt('都化为内错角相等：两线平行（命题 27）', 'Alternate angles agree: parallel', 7.5)]

@prop(29, '两线平行则内错角相等（第五公设）', 'Parallels make equal alternate angles (Postulate 5)')
def _():
    co, els = parallels()
    els += wedge('w1', co['E'], co['A'], co['F'], color='blue', at=1) + wedge('w2', co['F'], co['D'], co['E'], color='blue', at=1)
    els += wedge('w3', co['E'], co['B'], co['F'], color='red', at=2) + wedge('w4', co['F'], co['E'], co['D'], color='red', at=2)
    return els, [bt('AB 与 CD 平行，EF 与之相交', 'AB is parallel to CD; EF cuts both', 6),
                 bt('若角 AEF 大于角 EFD……', 'If AEF were greater than EFD...', 6.5),
                 bt('则 BEF + EFD 小于两直角，按第五公设两线必相交', '...then by Postulate 5 they would meet', 8),
                 bt('与平行矛盾：内错角相等', 'So the alternate angles are equal', 7, pulse=['w1', 'w2'])]

@prop(30, '平行于同一直线的两线互相平行', 'Lines parallel to the same line are parallel')
def _():
    A, B, E, F, C, D = (0.06, 0.22), (0.94, 0.22), (0.06, 0.50), (0.94, 0.50), (0.06, 0.78), (0.94, 0.78)
    G, H, K = (0.36, 0.22), (0.50, 0.50), (0.64, 0.78)
    els = pts('ABEFCD', {'A': A, 'B': B, 'E': E, 'F': F, 'C': C, 'D': D}) + [Seg('ab', 'A', 'B', color='gold'), Seg('ef', 'E', 'F'), Seg('cd', 'C', 'D', color='gold')]
    els += [Pt('G', *G, L('G'), at=1), Pt('H', *H, L('H'), at=1), Pt('K', *K, L('K'), at=1), Seg('gk', 'G', 'K', at=1)]
    els += wedge('w1', G, A, K, color='blue', at=2) + wedge('w2', H, F, G, color='blue', at=2) + wedge('w3', K, D, G, color='blue', at=2)
    return els, [bt('AB、CD 都平行于 EF', 'AB and CD are both parallel to EF', 6),
                 bt('作直线 GK 与三线相交', 'Draw GK across all three'),
                 bt('三个角依次相等（命题 29）', 'The angles are equal in turn (Prop. 29)', 7, pulse=['w1', 'w3']),
                 bt('所以 AB 平行于 CD（命题 27）', 'Hence AB is parallel to CD (Prop. 27)', 6.5)]

@prop(31, '过一点作已知直线的平行线', 'A parallel through a given point')
def _():
    B, C, A, D = (0.06, 0.74), (0.94, 0.74), (0.40, 0.28), (0.62, 0.74)
    E, F = (0.06, 0.28), (0.94, 0.28)
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Seg('bc', 'B', 'C'), Seg('ad', 'A', 'D', at=1)]
    els += wedge('w1', D, A, B, color='blue', at=1)
    els += [Pt('E', *E, L('E'), at=2), Pt('F', *F, L('F'), at=2), Seg('ef', 'E', 'F', color='gold', at=2, width=2.6)] + wedge('w2', A, F, D, color='blue', at=2)
    return els, [bt('过点 A 作 BC 的平行线', 'Through A, draw a parallel to BC', 5.5),
                 bt('在 BC 上取 D，连 AD', 'Take D on BC and join AD'),
                 bt('在 A 作角 DAF 等于角 ADB（命题 23）', 'At A make DAF equal to ADB (Prop. 23)', 7),
                 bt('内错角相等：EF 平行于 BC', 'Alternate angles agree: EF ∥ BC', 6.5, pulse=['ef'])]

@prop(32, '三角形内角和等于两直角', 'The angles of a triangle make two right angles')
def _():
    A, B, C, D = (0.36, 0.24), (0.08, 0.74), (0.62, 0.74), (0.94, 0.74)
    E = add(C, unit(B, A), 0.42)
    els = pts('ABC', {'A': A, 'B': B, 'C': C}) + [Poly('t', ['A', 'B', 'C'], color='silver')]
    els += wedge('wa', A, B, C, color='red') + wedge('wb', B, A, C, color='blue') + wedge('wc', C, A, B, color='gold')
    els += [Pt('D', *D, L('D'), at=1), Seg('cd', 'C', 'D', at=1), Pt('E', *E, L('E'), at=1), Seg('ce', 'C', 'E', dash=True, at=1)]
    els += wedge('wa2', C, A, E, color='red', at=2) + wedge('wb2', C, E, D, color='blue', at=3)
    return els, [bt('三角形的三个角', 'The three angles of a triangle', 5.5),
                 bt('延长 BC 到 D，作 CE 平行于 AB', 'Produce BC; draw CE parallel to AB'),
                 bt('内错角：角 ACE = 角 A', 'Alternate angles: ACE = A', 6.5, pulse=['wa', 'wa2']),
                 bt('同位角：角 ECD = 角 B', 'Corresponding angles: ECD = B', 6.5, pulse=['wb', 'wb2']),
                 bt('三角拼成一条直线：和为两直角', 'Together on one line: two right angles', 7.5, pulse=['wa2', 'wb2', 'wc'])]

# ———————————————————————————————— 33–34 平行四边形
@prop(33, '连接等长平行线段的两端', 'Joining equal and parallel lines')
def _():
    A, B, C, D = (0.24, 0.26), (0.72, 0.26), (0.14, 0.74), (0.62, 0.74)
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Seg('ab', 'A', 'B', color='gold'), Seg('cd', 'C', 'D', color='gold')]
    els += [Seg('ac', 'A', 'C', at=1), Seg('bd', 'B', 'D', at=1), Seg('bc', 'B', 'C', dash=True, at=2)]
    els += [Poly('t1', ['A', 'B', 'C'], color='blue', at=2), Poly('t2', ['B', 'C', 'D'], color='red', at=2)]
    return els, [bt('AB 与 CD 相等且平行', 'AB and CD are equal and parallel', 6),
                 bt('连 AC、BD', 'Join AC and BD', 5.5),
                 bt('连 BC：两三角形边角边全等', 'Join BC: the triangles are congruent', 7, pulse=['t1', 't2']),
                 bt('所以 AC、BD 也相等且平行', 'So AC and BD are equal and parallel too', 7)]

@prop(34, '平行四边形对边对角相等', 'Opposite sides and angles of a parallelogram')
def _():
    A, B, C, D = (0.26, 0.26), (0.86, 0.26), (0.14, 0.74), (0.74, 0.74)
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Poly('p', ['A', 'B', 'D', 'C'], color='silver')]
    els += [Seg('bc', 'B', 'C', color='gold', at=1), Poly('t1', ['A', 'B', 'C'], color='blue', at=2), Poly('t2', ['B', 'D', 'C'], color='red', at=2)]
    return els, [bt('平行四边形 ABDC', 'The parallelogram ABDC', 5.5),
                 bt('作对角线 BC', 'Draw the diameter BC', 5.5),
                 bt('两个三角形角边角全等', 'The two triangles agree (Prop. 26)', 6.5, pulse=['t1', 't2']),
                 bt('对边相等、对角相等，对角线平分面积', 'Opposite sides, angles equal; BC halves it', 7.5)]

# ———————————————————————————————— 35–41 等积：平行线间的推移
@prop(35, '同底、同平行线间的平行四边形相等', 'Parallelograms on the same base between the same parallels')
def _():
    B, C = (0.12, 0.76), (0.48, 0.76); A, D = (0.20, 0.30), (0.56, 0.30); E, F = (0.48, 0.30), (0.84, 0.30)
    els = [Hid('l1', 0.04, 0.30), Hid('l2', 0.96, 0.30), Hid('l3', 0.04, 0.76), Hid('l4', 0.96, 0.76),
           Seg('top', 'l1', 'l2', dash=True), Seg('bot', 'l3', 'l4', dash=True)]
    els += pts('BC', {'B': B, 'C': C}) + [Hid('A', *A), Hid('D', *D), Poly('p', ['A', 'D', 'C', 'B'], color='gold')]
    els += [Pt('E', *E, L('E'), at=2), Pt('F', *F, L('F'), at=2), Hid('A0', *A, at=2), Hid('D0', *D, at=2)]
    els += [Poly('ta', ['A0', 'E', 'B'], color='red', at=2), Poly('td', ['D0', 'F', 'C'], color='red', at=2)]
    return els, [bt('平行四边形 ABCD 立在底 BC 上', 'Parallelogram ABCD on the base BC', 6),
                 bt('上边沿着平行线滑动', 'Slide the top along the parallel', 7.5, set={'A': {'x': E[0], 'y': E[1]}, 'D': {'x': F[0], 'y': F[1]}}),
                 bt('得 EBCF：左边少的三角形 = 右边多的', 'The triangle lost equals the one gained', 8, pulse=['ta', 'td']),
                 bt('面积不变：两平行四边形相等', 'The area is unchanged: they are equal', 6.5, pulse=['p'])]

@prop(36, '等底、同平行线间的平行四边形相等', 'Parallelograms on equal bases between the same parallels')
def _():
    B, C, F, G = (0.06, 0.76), (0.36, 0.76), (0.58, 0.76), (0.88, 0.76)
    A, D, E, H = (0.14, 0.30), (0.44, 0.30), (0.50, 0.30), (0.80, 0.30)
    els = [Hid('l1', 0.02, 0.30), Hid('l2', 0.98, 0.30), Hid('l3', 0.02, 0.76), Hid('l4', 0.98, 0.76), Seg('top', 'l1', 'l2', dash=True), Seg('bot', 'l3', 'l4', dash=True)]
    els += pts('ABCDEFGH', {'A': A, 'B': B, 'C': C, 'D': D, 'E': E, 'F': F, 'G': G, 'H': H})
    els += [Poly('p1', ['A', 'D', 'C', 'B'], color='gold'), Poly('p2', ['E', 'H', 'G', 'F'], color='blue')]
    els += [Seg('be', 'B', 'E', dash=True, at=1), Seg('ch', 'C', 'H', dash=True, at=1), Poly('mid', ['E', 'H', 'C', 'B'], color='silver', at=1)]
    return els, [bt('底 BC = FG，都在同一对平行线间', 'BC = FG, between the same parallels', 6.5),
                 bt('连 BE、CH，得平行四边形 EBCH', 'Join BE, CH: the parallelogram EBCH', 7),
                 bt('ABCD = EBCH（命题 35）', 'ABCD = EBCH (Prop. 35)', 6, pulse=['p1', 'mid']),
                 bt('EBCH = EFGH，所以 ABCD = EFGH', 'EBCH = EFGH, so ABCD = EFGH', 6.5, pulse=['p2', 'mid'])]

@prop(37, '同底、同平行线间的三角形相等', 'Triangles on the same base between the same parallels')
def _():
    B, C = (0.20, 0.76), (0.60, 0.76); A, D = (0.30, 0.28), (0.82, 0.28)
    els = [Hid('l1', 0.04, 0.28), Hid('l2', 0.96, 0.28), Seg('top', 'l1', 'l2', dash=True)]
    els += pts('BC', {'B': B, 'C': C}) + [Pt('A', *A, L('A')), Poly('t', ['A', 'B', 'C'], color='gold'), Pt('D', *D, L('D'), at=2)]
    return els, [bt('三角形 ABC，顶点 A 在平行线上', 'Triangle ABC, its vertex on the parallel', 6),
                 bt('顶点沿平行线移动……', 'Move the vertex along the parallel...', 8, set={'A': {'x': D[0], 'y': D[1]}}),
                 bt('……到 D：三角形 DBC', '...to D: the triangle DBC', 6),
                 bt('同底同高，面积不变（各为平行四边形之半）', 'Same base and height: equal areas', 7.5, pulse=['t'])]

@prop(38, '等底、同平行线间的三角形相等', 'Triangles on equal bases between the same parallels')
def _():
    B, C, E, F = (0.06, 0.76), (0.40, 0.76), (0.56, 0.76), (0.90, 0.76); A, D = (0.30, 0.28), (0.62, 0.28)
    els = [Hid('l1', 0.02, 0.28), Hid('l2', 0.98, 0.28), Seg('top', 'l1', 'l2', dash=True)]
    els += pts('ABCDEF', {'A': A, 'B': B, 'C': C, 'D': D, 'E': E, 'F': F}) + [Poly('t1', ['A', 'B', 'C'], color='gold'), Poly('t2', ['D', 'E', 'F'], color='blue')]
    els += [Seg('bc', 'B', 'C', color='red', at=1, width=3), Seg('ef', 'E', 'F', color='red', at=1, width=3)]
    return els, [bt('两个三角形在同一对平行线间', 'Two triangles between the same parallels', 6),
                 bt('底 BC = EF', 'with equal bases BC and EF', 5.5),
                 bt('各是等底平行四边形的一半（命题 36）', 'Each is half a parallelogram (Prop. 36)', 7),
                 bt('所以两三角形相等', 'So the triangles are equal', 5.5, pulse=['t1', 't2'])]

@prop(39, '同底的等积三角形在同一对平行线间', 'Equal triangles on the same base are between parallels')
def _():
    B, C, A, D = (0.20, 0.76), (0.62, 0.76), (0.30, 0.30), (0.78, 0.30)
    E = (0.78, 0.44)
    els = pts('ABCD', {'A': A, 'B': B, 'C': C, 'D': D}) + [Poly('t1', ['A', 'B', 'C'], color='gold'), Poly('t2', ['D', 'B', 'C'], color='blue')]
    els += [Seg('ad', 'A', 'D', color='gold', at=1, width=2.4), Pt('E', *E, L('E'), color='red', at=2), Seg('ae', 'A', 'E', dash=True, color='red', at=2)]
    return els, [bt('三角形 ABC = DBC，底边相同', 'ABC = DBC on the same base', 6),
                 bt('要证 AD 平行于 BC', 'To show AD is parallel to BC', 5.5),
                 bt('若不平行，过 A 的平行线交 BD 于 E', 'Else the parallel meets BD at E', 7.5),
                 bt('则 EBC = ABC = DBC，部分等于整体，荒谬', 'Then EBC = DBC, the part equal to the whole', 7.5, hide=['E', 'ae'], pulse=['ad'])]

@prop(40, '等底的等积三角形在同一对平行线间', 'Equal triangles on equal bases are between parallels')
def _():
    B, C, E, F = (0.06, 0.76), (0.40, 0.76), (0.56, 0.76), (0.90, 0.76); A, D = (0.24, 0.30), (0.70, 0.30)
    els = pts('ABCDEF', {'A': A, 'B': B, 'C': C, 'D': D, 'E': E, 'F': F}) + [Poly('t1', ['A', 'B', 'C'], color='gold'), Poly('t2', ['D', 'E', 'F'], color='blue')]
    els += [Seg('ad', 'A', 'D', color='gold', at=2, width=2.4)]
    return els, [bt('等底 BC = EF，三角形面积相等', 'Equal triangles on equal bases', 6),
                 bt('同上一题，用反证法', 'Argue as in the previous proposition', 6),
                 bt('所以 AD 平行于 BF', 'So AD is parallel to BF', 6, pulse=['ad'])]

@prop(41, '平行四边形是同底三角形的两倍', 'A parallelogram is double the triangle')
def _():
    B, C, A, D, E = (0.14, 0.76), (0.56, 0.76), (0.24, 0.30), (0.66, 0.30), (0.86, 0.30)
    els = pts('ABCDE', {'A': A, 'B': B, 'C': C, 'D': D, 'E': E}) + [Poly('p', ['A', 'D', 'C', 'B'], color='silver'), Poly('t', ['E', 'B', 'C'], color='gold')]
    els += [Seg('ac', 'A', 'C', dash=True, at=1), Poly('half', ['A', 'B', 'C'], color='blue', at=1)]
    return els, [bt('平行四边形 ABCD 与三角形 EBC 同底同平行线', 'Parallelogram ABCD and triangle EBC', 6.5),
                 bt('连 AC：三角形 ABC 是平行四边形的一半', 'Join AC: ABC is half the parallelogram', 7),
                 bt('ABC = EBC（命题 37）', 'ABC = EBC (Prop. 37)', 6, pulse=['half', 't']),
                 bt('所以平行四边形是三角形的两倍', 'So the parallelogram is double the triangle', 6.5, pulse=['p'])]

# ———————————————————————————————— 42–45 面积的作图
@prop(42, '作平行四边形等于已知三角形', 'A parallelogram equal to a triangle')
def _():
    B, C, A = (0.06, 0.78), (0.70, 0.78), (0.26, 0.28); E = mid(B, C)
    th = math.radians(64); h = C[1] - A[1]; v = (math.cos(th), -math.sin(th)); s_ = h / math.sin(th)
    F = add(E, v, s_); G = add(C, v, s_)
    els = pts('ABCE', {'A': A, 'B': B, 'C': C, 'E': E}) + [Poly('t', ['A', 'B', 'C'], color='silver')]
    els += [Seg('ae', 'A', 'E', dash=True, at=1), Poly('half', ['A', 'E', 'C'], color='blue', at=1)]
    els += [Pt('F', *F, L('F'), at=2), Pt('G', *G, L('G'), at=2), Poly('p', ['F', 'G', 'C', 'E'], color='gold', at=2)]
    return els, [bt('已知三角形 ABC 与一个角', 'Given the triangle ABC and an angle', 6),
                 bt('平分 BC 于 E', 'Bisect BC at E', 5.5),
                 bt('在 E 作给定的角，过 A 作平行线，得 FECG', 'Angle at E, parallel through A: FECG', 8),
                 bt('FECG = 2 × AEC = ABC', 'FECG = twice AEC = ABC', 6.5, pulse=['p', 't'])]

@prop(43, '对角线两旁的补形相等', 'The complements about the diameter are equal')
def _():
    A, B, C, D = (0.10, 0.18), (0.90, 0.18), (0.90, 0.82), (0.10, 0.82); K = along(A, C, 0.38)
    E, F, G, H = (K[0], A[1]), (C[0], K[1]), (K[0], D[1]), (A[0], K[1])
    co = {'A': A, 'B': B, 'C': C, 'D': D, 'K': K, 'E': E, 'F': F, 'G': G, 'H': H}
    els = pts('ABCDK', co) + [Poly('p', ['A', 'B', 'C', 'D'], color='silver'), Seg('ac', 'A', 'C', color='gold')]
    els += pts('EFGH', co, at=1) + [Seg('eg', 'E', 'G', at=1), Seg('hf', 'H', 'F', at=1)]
    els += [Poly('c1', ['E', 'B', 'F', 'K'], color='blue', at=2), Poly('c2', ['H', 'K', 'G', 'D'], color='red', at=2)]
    return els, [bt('平行四边形 ABCD 与对角线 AC', 'The parallelogram and its diameter AC', 6),
                 bt('过 AC 上一点 K 作两边的平行线', 'Through K on AC draw parallels to the sides'),
                 bt('对角线两旁各有一块补形', 'Two complements lie on either side of AC', 6.5, pulse=['c1', 'c2']),
                 bt('大三角形相等，减去相等的小三角形：两补形相等', 'Equal halves minus equal halves: equal', 8)]

@prop(44, '在已知线段上作等积的平行四边形', 'Apply a parallelogram to a given line')
def _():
    A, B = (0.16, 0.42), (0.44, 0.42); e, g = 0.26, 0.20; th = math.radians(62); v = (math.cos(th), -math.sin(th))
    E = (B[0] + e, B[1]); G = add(B, v, g); F = add(E, v, g); H = add(A, v, g)
    K = inter(H, B, E, add(E, v))
    t = (K[1] - E[1]) / v[1]; Lp, M = add(A, v, t), add(B, v, t)
    co = {'A': A, 'B': B, 'E': E, 'F': F, 'G': G, 'H': H, 'K': K, 'L': Lp, 'M': M}
    els = pts('AB', co) + [Seg('ab', 'A', 'B', color='gold', width=2.6)]
    els += pts('EFG', co, at=1) + [Poly('p1', ['B', 'E', 'F', 'G'], color='blue', at=1)]
    els += pts('HKLM', co, at=2) + [Seg('hf', 'H', 'G', dash=True, at=2), Seg('hl', 'H', 'L', dash=True, at=2), Seg('fk', 'F', 'K', dash=True, at=2),
                                    Seg('lk', 'L', 'K', dash=True, at=2), Seg('hk', 'H', 'K', color='silver', at=2)]
    els += [Poly('p2', ['A', 'B', 'M', 'L'], color='gold', at=3)]
    return els, [bt('已知线段 AB、一个三角形和一个角', 'Given AB, a triangle and an angle', 6),
                 bt('先作等于三角形的平行四边形 BEFG（命题 42）', 'First BEFG equal to the triangle (Prop. 42)', 7.5),
                 bt('补成大平行四边形，画对角线 HK', 'Complete the figure; draw the diameter HK', 7),
                 bt('补形 ABML = BEFG（命题 43）', 'The complement ABML = BEFG (Prop. 43)', 7, pulse=['p1', 'p2'])]

@prop(45, '作平行四边形等于任意直线形', 'A parallelogram equal to any rectilineal figure')
def _():
    A, B, C, D = (0.08, 0.30), (0.40, 0.18), (0.46, 0.58), (0.14, 0.70)
    area = lambda P, Q, R: abs((Q[0]-P[0])*(R[1]-P[1]) - (R[0]-P[0])*(Q[1]-P[1])) / 2
    s1, s2 = area(A, B, D), area(B, C, D); w = 0.36; h1, h2 = s1 / w, s2 / w
    x0, y0 = 0.56, 0.82
    co = {'A': A, 'B': B, 'C': C, 'D': D}
    els = pts('ABCD', co) + [Poly('q', ['A', 'B', 'C', 'D'], color='silver'), Seg('bd', 'B', 'D', dash=True, at=1),
                             Poly('t1', ['A', 'B', 'D'], color='blue', at=1), Poly('t2', ['B', 'C', 'D'], color='red', at=1)]
    for n, (x, y) in {'r1': (x0, y0), 'r2': (x0 + w, y0), 'r3': (x0 + w, y0 - h1), 'r4': (x0, y0 - h1), 'r5': (x0 + w, y0 - h1 - h2), 'r6': (x0, y0 - h1 - h2)}.items():
        els.append(Hid(n, x, y, at=2))
    els += [Poly('p1', ['r1', 'r2', 'r3', 'r4'], color='blue', at=2), Poly('p2', ['r4', 'r3', 'r5', 'r6'], color='red', at=3)]
    return els, [bt('任意一个直线形 ABCD', 'Any rectilineal figure ABCD', 5.5),
                 bt('用对角线把它分成三角形', 'Divide it into triangles'),
                 bt('第一块化为平行四边形（命题 42）', 'The first becomes a parallelogram', 7),
                 bt('第二块贴在上面（命题 44）：合成一个', 'Apply the second above it (Prop. 44)', 7.5, pulse=['p1', 'p2'])]

# ———————————————————————————————— 46–48 正方形与勾股定理
@prop(46, '在线段上作正方形', 'Describe a square on a line')
def _():
    A, B = (0.26, 0.80), (0.74, 0.80); D = (A[0], A[1] - 0.48); E = (B[0], D[1])
    co = {'A': A, 'B': B, 'D': D, 'E': E}
    els = pts('AB', co) + [Seg('ab', 'A', 'B', color='gold')] + right_mark('rm', A, B, D, at=1)
    els += [Hid('C', A[0], 0.14, at=1), Seg('ac', 'A', 'C', dash=True, at=1), Pt('D', *D, L('D'), at=1), Seg('ad', 'A', 'D', color='gold', at=1)]
    els += [Pt('E', *E, L('E'), at=2), Seg('de', 'D', 'E', at=2), Seg('be', 'B', 'E', at=2), Poly('sq', ['A', 'B', 'E', 'D'], color='gold', at=3)]
    return els, [bt('已知线段 AB', 'Given the line AB', 5),
                 bt('在 A 作垂线，截 AD = AB', 'Erect a perpendicular at A; cut off AD = AB', 7),
                 bt('过 D、B 作平行线，交于 E', 'Parallels through D and B meet at E'),
                 bt('四边相等、四角皆直：正方形 ADEB', 'Equal sides, right angles: the square ADEB', 7, pulse=['sq'])]

@prop(47, '勾股定理', 'The square on the hypotenuse')
def _():
    B, C = (0.30, 0.52), (0.70, 0.52); A = (0.40, 0.52 - math.sqrt(0.10 * 0.30))
    D, E = (0.30, 0.92), (0.70, 0.92)
    nAB = (-(A[1]-B[1]), (A[0]-B[0])); nAB = (nAB[0] if nAB[0] < 0 else -nAB[0], nAB[1] if nAB[0] < 0 else -nAB[1])
    G, F = add(A, nAB), add(B, nAB)
    nAC = ((C[1]-A[1]), -(C[0]-A[0])); H, K = add(A, nAC), add(C, nAC)
    M, Lp = (A[0], B[1]), (A[0], D[1])
    co = {'A': A, 'B': B, 'C': C, 'D': D, 'E': E, 'F': F, 'G': G, 'H': H, 'K': K, 'L': Lp, 'M': M}
    els = pts('ABCDEFGHK', co) + [Poly('tri', ['A', 'B', 'C'], color='silver'),
                                  Poly('s1', ['B', 'A', 'G', 'F'], color='red'), Poly('s2', ['A', 'C', 'K', 'H'], color='blue'), Poly('s3', ['B', 'C', 'E', 'D'], color='gold')]
    els += right_mark('ra', A, B, C)
    els += pts('ML', co, at=1) + [Seg('al', 'A', 'L', dash=True, at=1), Poly('r1', ['B', 'M', 'L', 'D'], color='red', at=1), Poly('r2', ['M', 'C', 'E', 'L'], color='blue', at=1)]
    # 三角形 FBC 绕 B 转成 ABD
    els += [Hid('m1', *F, at=2), Hid('m2', *B, at=2), Hid('m3', *C, at=2), Poly('mv', ['m1', 'm2', 'm3'], color='violet', at=2)]
    return els, [bt('直角三角形 ABC 与三边上的正方形', 'A right triangle and its three squares', 6.5),
                 bt('过 A 作 AL 平行于 BD，把大正方形分成两块', 'AL parallel to BD splits the great square', 7),
                 bt('三角形 FBC……', 'The triangle FBC...', 5.5, hide=['r2']),
                 bt('……绕 B 转成 ABD：两者全等（命题 4）', '...turns about B into ABD (Prop. 4)', 8,
                    set={'m1': {'x': A[0], 'y': A[1]}, 'm3': {'x': D[0], 'y': D[1]}}),
                 bt('BG = BL，CH = CL：两方之和 = 弦方', 'Square BG = BL, CH = CL: sum = BE', 8.5,
                    hide=['mv'], pulse=['s1', 'r1', 's2', 'r2'])]

@prop(48, '勾股定理的逆定理', 'Converse of the Pythagorean theorem')
def _():
    B, C = (0.14, 0.78), (0.74, 0.78); A = (0.32, 0.78 - math.sqrt(0.30**2 - 0.12**2))
    u = unit(A, C); n = (u[1], -u[0])
    if n[0]*(B[0]-A[0]) + n[1]*(B[1]-A[1]) > 0: n = (-n[0], -n[1])
    D = add(A, n, math.dist(A, B))
    co = {'A': A, 'B': B, 'C': C, 'D': D}
    els = pts('ABC', co) + [Poly('t', ['A', 'B', 'C'], color='silver')]
    els += [Pt('D', *D, L('D'), at=1), Seg('ad', 'A', 'D', color='gold', at=1), Seg('dc', 'D', 'C', dash=True, at=1)] + right_mark('rm', A, C, D, at=1)
    els += [Poly('t2', ['A', 'D', 'C'], color='gold', at=2)] + right_mark('rm2', A, B, C, at=3)
    return els, [bt('BC 上的正方形 = AB、AC 上的正方形之和', 'Square on BC = squares on AB and AC', 7),
                 bt('作 AD 垂直于 AC，AD = AB', 'Draw AD at right angles to AC, equal to AB', 7),
                 bt('则 DC² = AD² + AC² = BC²，DC = BC', 'Then DC² = AD² + AC² = BC², so DC = BC', 7.5),
                 bt('边边边全等：角 BAC 是直角', 'By Prop. 8, the angle BAC is right', 6.5)]

# ———————————————————————————————— 卷二：几何代数
BOOK[0] = 2
def rect(id, x, y, w, h, color='gold', at=0, label='', size=None):
    """矩形（左上角 x, y；宽 w、高 h），顶点为 id1..id4，可单独移动"""
    c = {f'{id}1': (x, y), f'{id}2': (x + w, y), f'{id}3': (x + w, y + h), f'{id}4': (x, y + h)}
    return [Hid(n, round(a, 4), round(b, 4), at=at) for n, (a, b) in c.items()] + [Poly(id, list(c), label, color=color, at=at, size=size)]
def move_rect(id, x, y, w, h):
    return {f'{id}1': {'x': round(x, 4), 'y': round(y, 4)}, f'{id}2': {'x': round(x + w, 4), 'y': round(y, 4)},
            f'{id}3': {'x': round(x + w, 4), 'y': round(y + h, 4)}, f'{id}4': {'x': round(x, 4), 'y': round(y + h, 4)}}
def line_pts(y, xs, names, at=0):
    return [Pt(n, x, y, L(n), at=at) for n, x in zip(names, xs)]

@prop(1, '矩形可按一边的分段拆开', 'A rectangle splits along a divided side')
def _():
    xs = [0.08, 0.36, 0.62, 0.92]; y, h = 0.34, 0.40
    els = line_pts(y, [xs[0], xs[1], xs[2], xs[3]], 'BDEC') + [Seg('bc', 'B', 'C', color='gold')]
    els += [Hid('a1', 0.08, 0.10), Hid('a2', 0.08 + h, 0.10), Seg('a', 'a1', 'a2', 'A', color='blue', width=3)]
    els += rect('R', xs[0], y, xs[3] - xs[0], h, 'silver', at=1)
    els += rect('r1', xs[0], y, xs[1] - xs[0], h, 'blue', at=2) + rect('r2', xs[1], y, xs[2] - xs[1], h, 'red', at=2) + rect('r3', xs[2], y, xs[3] - xs[2], h, 'green', at=2)
    return els, [bt('线段 A，与被 D、E 分开的 BC', 'A line A, and BC cut at D and E', 6),
                 bt('以 A 为高、BC 为底作矩形', 'The rectangle under A and BC', 6),
                 bt('竖着切开，正好是三块', 'Cut it at D and E: three rectangles', 6.5),
                 bt('A·BC = A·BD + A·DE + A·EC', 'A·BC = A·BD + A·DE + A·EC', 7, pulse=['r1', 'r2', 'r3'])]

@prop(2, '整段的平方等于两个矩形之和', 'The square equals the two rectangles')
def _():
    A, C, B = 0.14, 0.52, 0.86; y = 0.12; s_ = B - A
    els = line_pts(y, [A, C, B], 'ACB') + [Seg('ab', 'A', 'B', color='gold')]
    els += rect('sq', A, y, s_, s_, 'silver', at=1) + rect('r1', A, y, C - A, s_, 'blue', at=2) + rect('r2', C, y, B - C, s_, 'red', at=2)
    return els, [bt('线段 AB 在 C 点分开', 'The line AB cut at C', 5.5),
                 bt('在 AB 上作正方形', 'Describe the square on AB', 5.5),
                 bt('过 C 作竖线，分成两块', 'A line through C divides it', 6),
                 bt('AB² = AB·AC + AB·CB', 'AB² = AB·AC + AB·CB', 6.5, pulse=['r1', 'r2'])]

@prop(3, '矩形等于小矩形加正方形', 'The rectangle equals a rectangle and a square')
def _():
    A, C, B = 0.08, 0.56, 0.92; y = 0.30; h = B - C
    els = line_pts(y, [A, C, B], 'ACB') + [Seg('ab', 'A', 'B', color='gold')]
    els += rect('R', A, y, B - A, h, 'silver', at=1) + rect('r1', A, y, C - A, h, 'blue', at=2) + rect('sq', C, y, h, h, 'red', at=2)
    return els, [bt('线段 AB 在 C 点分开', 'The line AB cut at C', 5.5),
                 bt('以 AB 为长、CB 为宽作矩形', 'The rectangle under AB and BC', 6),
                 bt('过 C 切开：左边矩形，右边正方形', 'Cut at C: a rectangle and a square', 6.5),
                 bt('AB·BC = AC·CB + CB²', 'AB·BC = AC·CB + CB²', 6.5, pulse=['r1', 'sq'])]

@prop(4, '(a + b)² = a² + b² + 2ab', '(a + b)² = a² + b² + 2ab')
def _():
    A, C, B = 0.12, 0.60, 0.88; y = 0.10; a, b = C - A, B - C
    els = line_pts(y, [A, C, B], 'ACB') + [Seg('ab', 'A', 'B', color='gold')]
    els += rect('sq', A, y, a + b, a + b, 'silver', at=1)
    els += rect('s1', A, y, a, a, 'blue', at=2) + rect('s2', C, y + a, b, b, 'red', at=2)
    els += rect('k1', C, y, b, a, 'gold', at=3) + rect('k2', A, y + a, a, b, 'gold', at=3)
    return els, [bt('线段 AB 在 C 点分开', 'The line AB cut at C', 5.5),
                 bt('在 AB 上作正方形', 'The square on AB', 5.5),
                 bt('对角上是 AC、CB 上的两个正方形', 'On the diagonal: squares on AC and CB', 6.5, pulse=['s1', 's2']),
                 bt('另两块各为 AC·CB：两倍的矩形', 'Two rectangles AC·CB remain: the whole', 8, pulse=['k1', 'k2'])]

@prop(5, '平分与不等分：AD·DB + CD² = CB²', 'Equal and unequal segments: AD·DB + CD² = CB²')
def _():
    A, C, D, B = 0.06, 0.50, 0.66, 0.94; y = 0.32; db = B - D; cb = B - C; cd = D - C
    els = line_pts(y, [A, C, D, B], 'ACDB') + [Seg('ab', 'A', 'B', color='gold')]
    els += rect('p1', A, y - db, C - A, db, 'blue', at=1) + rect('p2', C, y - db, cd, db, 'blue', at=1)
    els += rect('big', C, y, cb, cb, 'silver', at=2)
    els += rect('small', C, y + db, cd, cd, 'red', at=3)
    mv = move_rect('p2', C, y, cd, db); mv.update({'p11': {'x': D, 'y': y}, 'p12': {'x': B, 'y': y}, 'p13': {'x': B, 'y': y + cb}, 'p14': {'x': D, 'y': y + cb}})
    return els, [bt('AB 在 C 平分，又在 D 不等分', 'AB bisected at C and cut unequally at D', 6.5),
                 bt('作矩形 AD·DB', 'The rectangle AD·DB', 6),
                 bt('两块移进 CB 上的正方形，成一个曲尺形', 'Move its parts into the square on CB', 8, set=mv),
                 bt('缺的一角是 CD²：AD·DB + CD² = CB²', 'The corner left is CD²: AD·DB + CD² = CB²', 8, pulse=['small'])]

@prop(6, '平分后延长：AD·DB + CB² = CD²', 'Bisected and produced: AD·DB + CB² = CD²')
def _():
    A, C, B, D = 0.06, 0.32, 0.58, 0.86; y = 0.32; bd = D - B; cb = B - C; cd = D - C
    els = line_pts(y, [A, C, B, D], 'ACBD') + [Seg('ad', 'A', 'D', color='gold')]
    els += rect('p1', A, y - bd, C - A, bd, 'blue', at=1) + rect('p2', C, y - bd, cd, bd, 'blue', at=1)
    els += rect('big', C, y, cd, cd, 'silver', at=2) + rect('small', C, y, cb, cb, 'red', at=3)
    mv = move_rect('p1', C, y + cb, cb, bd)
    mv.update({'p21': {'x': D, 'y': y}, 'p22': {'x': D, 'y': y + cd}, 'p23': {'x': B, 'y': y + cd}, 'p24': {'x': B, 'y': y}})
    return els, [bt('AB 在 C 平分，延长到 D', 'AB bisected at C and produced to D', 6.5),
                 bt('作矩形 AD·DB', 'The rectangle AD·DB', 6),
                 bt('两块移进 CD 上的正方形', 'Move its parts into the square on CD', 8, set=mv),
                 bt('补上 CB²：AD·DB + CB² = CD²', 'Add CB²: AD·DB + CB² = CD²', 7.5, pulse=['small'])]

@prop(7, 'AB² + BC² = 2·AB·BC + AC²', 'AB² + BC² = 2·AB·BC + AC²')
def _():
    A, C, B = 0.12, 0.56, 0.88; y = 0.10; ab, bc, ac = B - A, B - C, C - A
    els = line_pts(y, [A, C, B], 'ACB') + [Seg('ab', 'A', 'B', color='gold')]
    els += rect('sq', A, y, ab, ab, 'silver', at=1) + rect('s2', C, y, bc, bc, 'red', at=1)
    els += rect('k1', A, y + bc, ab, bc, 'blue', at=2) + rect('k2', C, y, bc, ab, 'gold', at=2)
    els += rect('s1', A, y + bc, ac, ac, 'green', at=3)
    return els, [bt('线段 AB 在 C 点分开', 'The line AB cut at C', 5.5),
                 bt('AB² 与 BC²（BC² 算了两次）', 'AB² and BC² (BC² counted twice)', 6.5),
                 bt('两个 AB·BC 矩形，盖住了 BC² 两次', 'Two rectangles AB·BC cover BC² twice', 7),
                 bt('剩下的是 AC²：AB² + BC² = 2AB·BC + AC²', 'What remains is AC²', 7.5, pulse=['s1'])]

@prop(8, '4·AB·BC + AC² = (AB + BC)²', '4·AB·BC + AC² = (AB + BC)²')
def _():
    a, b = 0.52, 0.30; x0, y0 = 0.09, 0.10; s_ = a + b
    els = [Hid('o1', x0, y0), Hid('o2', x0 + s_, y0), Hid('o3', x0 + s_, y0 + s_), Hid('o4', x0, y0 + s_), Poly('big', ['o1', 'o2', 'o3', 'o4'], color='silver')]
    els += rect('r1', x0, y0, a, b, 'blue', at=1) + rect('r2', x0 + a, y0, b, a, 'blue', at=1) + rect('r3', x0 + b, y0 + a, a, b, 'blue', at=1) + rect('r4', x0, y0 + b, b, a, 'blue', at=1)
    els += rect('mid', x0 + b, y0 + b, a - b, a - b, 'red', at=2)
    return els, [bt('以 AB + BC 为边的正方形', 'The square on AB + BC', 6),
                 bt('四个 AB·BC 矩形绕成一圈', 'Four rectangles AB·BC wind around it', 7, pulse=['r1', 'r2', 'r3', 'r4']),
                 bt('中间空出的是 AC²（AC = AB − BC）', 'The hole in the middle is AC²', 7, pulse=['mid']),
                 bt('4AB·BC + AC² = (AB + BC)²', '4AB·BC + AC² = (AB + BC)²', 6.5)]

@prop(9, 'AD² + DB² = 2(AC² + CD²)', 'AD² + DB² = 2(AC² + CD²)')
def _():
    A, C, D, B = 0.06, 0.40, 0.54, 0.74; y = 0.18
    els = line_pts(y, [A, C, D, B], 'ACDB') + [Seg('ab', 'A', 'B', color='gold')]
    E = (C, y - (C - A)); F = (D, y - (D - A) + (D - C) * 0)  # 示意
    els += rect('s1', A, y + 0.02, D - A, D - A, 'blue', at=1) + rect('s2', D, y + 0.02, B - D, B - D, 'blue', at=1)
    els += rect('t1', 0.06, 0.70, C - A, (C - A) / 2, 'red', at=2) + rect('t2', 0.06 + (C - A) + 0.02, 0.70, C - A, (C - A) / 2, 'red', at=2)
    els += rect('u1', 0.78, 0.70, D - C, D - C, 'gold', at=2) + rect('u2', 0.78, 0.70 + (D - C) + 0.02, D - C, D - C, 'gold', at=2)
    return els, [bt('AB 在 C 平分，在 D 不等分', 'AB bisected at C and cut unequally at D', 6.5),
                 bt('两段上的正方形：AD² + DB²', 'The squares on AD and DB', 6),
                 bt('等于两个 AC² 加两个 CD²（面积示意）', 'equal twice AC² and twice CD² (areas shown)', 7.5),
                 bt('欧几里得借等腰直角三角形证明', 'Proved with isosceles right triangles', 7)]

@prop(10, '延长线上的同一关系', 'The same, with the line produced')
def _():
    A, C, B, D = 0.06, 0.28, 0.50, 0.66; y = 0.14
    els = line_pts(y, [A, C, B, D], 'ACBD') + [Seg('ad', 'A', 'D', color='gold')]
    els += rect('s1', A, y + 0.02, D - A, D - A, 'blue', at=1) + rect('s2', 0.72, y + 0.02, D - B, D - B, 'blue', at=1)
    return els, [bt('AB 在 C 平分，延长到 D', 'AB bisected at C and produced to D', 6.5),
                 bt('AD² + DB²', 'The squares on AD and DB', 6),
                 bt('= 2(AC² + CD²)', 'equal twice the squares on AC and CD', 6.5)]

@prop(11, '黄金分割', 'The golden section')
def _():
    A, B = (0.30, 0.66), (0.66, 0.66); s_ = B[0] - A[0]
    C, D = (A[0], A[1] + s_), (B[0], B[1] + s_)
    C = (A[0], A[1] - s_); D = (B[0], B[1] - s_)
    E = mid(A, C); EB = math.dist(E, B); F = (A[0], E[1] + EB)
    af = F[1] - A[1]; H = (A[0] + af, A[1]); G = (A[0] + af, F[1])
    co = {'A': A, 'B': B, 'C': C, 'D': D, 'E': E, 'F': F, 'G': G, 'H': H}
    els = pts('AB', co) + [Seg('ab', 'A', 'B', color='gold', width=2.6)]
    els += pts('CD', co, at=1) + [Poly('sq', ['A', 'B', 'D', 'C'], color='silver', at=1)]
    els += pts('E', co, at=2) + [Seg('eb', 'E', 'B', at=2), Circ('k', 'E', 'B', dash=True, at=2), Pt('F', *F, L('F'), at=2), Seg('af', 'A', 'F', at=2)]
    els += pts('GH', co, at=3) + [Poly('sq2', ['A', 'F', 'G', 'H'], color='gold', at=3)]
    return els, [bt('要把 AB 分成两段，使 AB·HB = AH²', 'Cut AB at H so that AB·BH = AH²', 6.5),
                 bt('在 AB 上作正方形 ABDC', 'Describe the square ABDC', 5.5),
                 bt('平分 AC 于 E，以 EB 为半径截得 F', 'Bisect AC at E; make EF = EB', 7),
                 bt('作正方形 AFGH：H 就是分点', 'The square AFGH gives the point H', 7, pulse=['sq2'])]

@prop(12, '钝角三角形：对边平方较大', 'Obtuse triangle: the square on the opposite side')
def _():
    C, A, B = (0.10, 0.80), (0.52, 0.80), (0.80, 0.30)
    D = (B[0], A[1])
    co = {'A': A, 'B': B, 'C': C, 'D': D}
    els = pts('ABC', co) + [Poly('t', ['A', 'B', 'C'], color='silver')] + wedge('wa', A, B, C, color='red')
    els += pts('D', co, at=1) + [Seg('ad', 'A', 'D', dash=True, at=1), Seg('bd', 'B', 'D', dash=True, at=1)] + right_mark('rm', D, A, B, at=1)
    els += [Seg('cad', 'C', 'D', color='gold', at=2), Seg('bc', 'B', 'C', color='blue', width=2.6, at=3)]
    return els, [bt('角 BAC 是钝角', 'The angle BAC is obtuse', 5.5),
                 bt('延长 CA，作垂线 BD', 'Produce CA and draw BD perpendicular', 6.5),
                 bt('用命题 4 与命题 47 展开 CD²', 'Expand by Props. II.4 and I.47', 6.5),
                 bt('BC² = BA² + AC² + 2·CA·AD', 'BC² = BA² + AC² + 2·CA·AD', 7.5, pulse=['bc'])]

@prop(13, '锐角三角形：对边平方较小', 'Acute angle: the square on the opposite side')
def _():
    B, C, A = (0.10, 0.80), (0.90, 0.80), (0.36, 0.26)
    D = (A[0], B[1])
    co = {'A': A, 'B': B, 'C': C, 'D': D}
    els = pts('ABC', co) + [Poly('t', ['A', 'B', 'C'], color='silver')] + wedge('wb', B, A, C, color='blue')
    els += pts('D', co, at=1) + [Seg('ad', 'A', 'D', dash=True, at=1)] + right_mark('rm', D, C, A, at=1)
    els += [Seg('ac', 'A', 'C', color='red', width=2.6, at=3)]
    return els, [bt('角 B 是锐角', 'The angle at B is acute', 5.5),
                 bt('作 AD 垂直于 BC', 'Draw AD perpendicular to BC', 6),
                 bt('用命题 7 与命题 I.47 展开', 'Expand by Props. II.7 and I.47', 6.5),
                 bt('AC² = CB² + BA² − 2·CB·BD', 'AC² = CB² + BA² − 2·CB·BD', 7.5, pulse=['ac'])]

@prop(14, '作正方形等于已知直线形', 'A square equal to a rectilineal figure')
def _():
    B, E = (0.06, 0.62), (0.42, 0.62); h = 0.20
    C, D = (B[0], B[1] - h), (E[0], E[1] - h)
    F = (E[0] + h, E[1]); G = mid(B, F); r = math.dist(G, F)
    Hy = E[1] - math.sqrt(r*r - (E[0] - G[0])**2); H = (E[0], Hy); eh = E[1] - Hy
    co = {'B': B, 'C': C, 'D': D, 'E': E, 'F': F, 'G': G, 'H': H}
    els = pts('BCDE', co) + [Poly('R', ['B', 'E', 'D', 'C'], color='blue')]
    els += pts('FG', co, at=1) + [Seg('ef', 'E', 'F', color='gold', at=1), Circ('k', 'G', 'F', dash=True, at=1)]
    els += pts('H', co, at=2) + [Seg('eh', 'E', 'H', color='red', width=2.6, at=2)]
    els += rect('sq', E[0], Hy, eh, eh, 'red', at=3)
    return els, [bt('先作矩形 BCDE 等于已知图形（命题 I.45）', 'First a rectangle BCDE equal to the figure', 7),
                 bt('延长 BE 到 F，EF = ED；以 BF 为径作圆', 'Make EF = ED; a circle on BF', 7),
                 bt('延长 DE 交圆于 H', 'Produce DE to meet the circle at H', 6),
                 bt('EH² = BE·EF：正方形与矩形等积', 'EH² = BE·EF: the square equals the figure', 7.5, pulse=['sq', 'R'])]

# ————————————————————————————————
def emit(text_id, lang):
    global LANG
    LANG = lang
    anim.reset()
    doc = json.load(open(os.path.join(anim.ROOT, 'texts', f'{text_id}.json'), encoding='utf-8'))
    secs = doc['sections']
    def index_of(pred):
        k = 0
        for s in secs:
            for j, p in enumerate(s['paragraphs']):
                if pred(s['title'], j, p): return k
                k += 1
        raise SystemExit(f'找不到段落 {text_id}')
    for bk, n, zh, en, build in sorted(PROPS, key=lambda x: (x[0], x[1])):
        if lang == 'en':
            i = index_of(lambda t, j, p: t.startswith(f'Book {roman(bk)} · Prop. {roman(n)} (') and j == 0)
            title, cap = f'{roman(bk)}.{n} · {en}', f'Euclid, Elements {roman(bk)}.{n}'
        else:
            i = index_of(lambda t, j, p: t == f'卷{cn(bk)} · 题' and p.startswith(f'第{cn(n)}題'))
            title, cap = (f'命题 {n} · {zh}' if bk == 1 else f'卷{cn(bk)} · 命题 {n} · {zh}'), f'卷{cn(bk)} · 第{cn(n)}题'
        els, beats = build()
        for e in els:
            for k in ('x', 'y'):
                if k in e and not -0.02 <= e[k] <= 1.02: raise SystemExit(f'{n} {e["id"]}.{k}={e[k]:.3f} 出界')
        scene(i, title, els, beats, caption=cap, geo=True)

def check_widths(text_id):
    d = json.load(open(os.path.join(anim.ROOT, 'anims', f'{text_id}.json'), encoding='utf-8'))
    for s in d['scenes']:
        if not s.get('geo'): continue
        for b in s['beats']:
            w = sum(14 if ord(c) > 0x2E80 else 7.6 for c in b['headline'])
            if w > 330: print('  过长', text_id, round(w), b['headline'])

if __name__ == '__main__':
    for tid, lang in (('euclid-en', 'en'), ('jihe-zh', 'zh')):
        emit(tid, lang); save(tid); check_widths(tid)
