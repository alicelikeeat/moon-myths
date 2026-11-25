"""《周髀算经》弦图、阿基米德《方法》抛物线弓形、笛卡尔《几何学》乘法与开方。"""
import sys, os, json, math
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import anim
from anim import *

def paras(tid):
    d = json.load(open(os.path.join(anim.ROOT, 'texts', f'{tid}.json'), encoding='utf-8'))
    return [p for s in d['sections'] for p in s['paragraphs']]

# —————— 周髀算经：赵爽弦图
ps = paras('zhoubi-zh')
k, x0, y0 = 0.12, 0.20, 0.82
U = lambda u, v: (round(x0 + k*u, 4), round(y0 - k*v, 4))
c = 5; cx, cy = 2.5, 2.5
q1 = (3.2, 2.4)
def rot(p, n):
    x, y = p[0] - cx, p[1] - cy
    for _ in range(n): x, y = -y, x
    return (x + cx, y + cy)
tris = [[rot((0, 0), n), rot((5, 0), n), rot(q1, n)] for n in range(4)]
els = [Hid('o1', *U(0, 0)), Hid('o2', *U(5, 0)), Hid('o3', *U(5, 5)), Hid('o4', *U(0, 5)), Poly('xian', ['o1', 'o2', 'o3', 'o4'], color='gold'), T('xl', 0.5, 0.15, '弦实 = 5 × 5 = 25', color='gold', size=12)]
moves = {}
for n, t in enumerate(tris):
    gx = sum(p[0] for p in t) / 3 - cx; gy = sum(p[1] for p in t) / 3 - cy; L_ = math.hypot(gx, gy)
    for j, p in enumerate(t):
        start = (p[0] + gx / L_ * 0.9, p[1] + gy / L_ * 0.9)
        sx, sy = U(*start)
        assert 0 <= sx <= 1 and 0 <= sy <= 1, (sx, sy)
        els.append(Hid(f't{n}{j}', sx, sy, at=1)); moves[f't{n}{j}'] = dict(zip(('x', 'y'), U(*p)))
    els.append(Poly(f'z{n}', [f't{n}0', f't{n}1', f't{n}2'], '朱实' if n == 0 else '', color='red', at=1, size=11))
inner = [q1, rot(q1, 1), rot(q1, 2), rot(q1, 3)]
for j, p in enumerate(inner): els.append(Hid(f'h{j}', *U(*p), at=3))
els.append(Poly('huang', ['h0', 'h1', 'h2', 'h3'], color='gold', at=3))
anchor = next(i for i, p in enumerate(ps) if p.startswith('兩矩共長二十有五'))
scene(anchor, '赵爽弦图 · 勾股圆方图', els, [
    beat('勾三股四，弦五：弦自乘为弦实，二十五', 6.5),
    beat('勾股相乘为朱实二：四块直角三角形', 6),
    beat('四块朱实各就其位，贴着弦方的四边', 8, set=moves),
    beat('中间空出黄实：勾股之差自乘，(4−3)² = 1', 7, pulse=['huang']),
    beat('朱实四 24 + 黄实 1 = 弦实 25', 7, pulse=['xian']),
], caption='赵爽注：案弦图，又可以勾股相乘为朱实二……', geo=True)
save('zhoubi-zh')

# —————— 阿基米德：抛物线弓形 = 4/3 内接三角形
anim.reset()
ps = paras('archimedes-en')
P = lambda x: (round(0.5 + 0.42*x, 4), round(0.84 - 0.62*(1 - x*x), 4))
n = 24
els = [Hid(f'p{i}', *P(-1 + 2*i/n)) for i in range(n + 1)] + [Poly('seg', [f'p{i}' for i in range(n + 1)], color='silver')]
def tri(id, xs, at, color):
    a, m, b = xs
    return [Hid(f'{id}a', *P(a), at=at), Hid(f'{id}m', *P(m), at=at), Hid(f'{id}b', *P(b), at=at), Poly(id, [f'{id}a', f'{id}m', f'{id}b'], color=color, at=at)]
els += tri('T', (-1, 0, 1), 1, 'gold')
els += tri('L1', (-1, -0.5, 0), 2, 'blue') + tri('R1', (0, 0.5, 1), 2, 'blue')
for j, a in enumerate((-1, -0.5, 0, 0.5)):
    els += tri(f'S{j}', (a, a + 0.25, a + 0.5), 3, 'violet')
els += [T('sum', 0.5, 0.96, 'T (1 + 1/4 + 1/16 + …) = 4/3 T', color='gold', size=12, at=4)]
anchor = next(i for i, p in enumerate(ps) if p.startswith('Let αβγ [Fig. 1] be the segment of a parabola'))
scene(anchor, 'Prop. I · The parabolic segment', els, [
    beat('A segment of a parabola cut off by a chord', 6),
    beat('Inscribe the greatest triangle: call it T', 6, pulse=['T']),
    beat('Two more triangles fill the gaps: together T/4', 6.5, pulse=['L1', 'R1']),
    beat('Four more: T/16, and so on without end', 6.5),
    beat('The segment is 4/3 of the triangle', 7, pulse=['seg']),
], caption='Archimedes, The Method, Prop. I', geo=True)
save('archimedes-en')

# —————— 笛卡尔：用作图做乘法、开平方
anim.reset()
ps = paras('geometrie-fr')
u = 0.16; B = (0.08, 0.80); th = math.radians(38); d = (math.cos(th), -math.sin(th))
A = (B[0] + u, B[1]); D = (B[0] + 2.5*u, B[1]); C = (B[0] + 1.6*u*d[0], B[1] + 1.6*u*d[1]); E = (B[0] + 4.0*u*d[0], B[1] + 4.0*u*d[1])
co = {'A': A, 'B': B, 'C': C, 'D': D, 'E': E}
els = [Pt(n, *p, n) for n, p in co.items() if n in 'AB'] + [Seg('ab', 'B', 'A', '1', color='gold', width=3)]
els += [Pt('D', *D, 'D', at=1), Seg('bd', 'A', 'D', at=1), Hid('Lx', min(0.96, B[0] + 0.88), B[1]), Seg('line1', 'D', 'Lx', dash=True, at=1)]
els += [Pt('C', *C, 'C', at=1), Seg('bc', 'B', 'C', color='blue', width=3, at=1), Hid('L2', B[0] + 0.78*d[0], B[1] + 0.78*d[1]), Seg('line2', 'C', 'L2', dash=True, at=1)]
els += [Seg('ac', 'A', 'C', color='violet', at=2), Pt('E', *E, 'E', at=3), Seg('de', 'D', 'E', color='violet', at=3), Seg('be', 'B', 'E', color='red', width=3, at=4)]
anchor = next(i for i, p in enumerate(ps) if p.startswith('Soit, par exemple, AB'))
scene(anchor, 'La multiplication', els, [
    beat("Soit AB l'unité", 5.5),
    beat('Il faut multiplier BD par BC', 6),
    beat('Joindre les points A et C', 5.5),
    beat('Tirer DE parallèle à CA', 6.5),
    beat('BE est le produit : BE = BD × BC', 7, pulse=['be']),
], caption='Descartes, La Géométrie (1637), fig. 1', geo=True)

u = 0.12; F = (0.14, 0.68); G = (F[0] + u, F[1]); H = (G[0] + 4*u, F[1]); K = ((F[0] + H[0]) / 2, F[1]); I = (G[0], F[1] - 2*u)
els = [Pt('G', *G, 'G'), Pt('H', *H, 'H'), Seg('gh', 'G', 'H', 'a', color='blue', width=3)]
els += [Pt('F', *F, 'F', at=1), Seg('fg', 'F', 'G', '1', color='gold', width=3, at=1)]
els += [Pt('K', *K, 'K', at=2), Circ('k', 'K', 'H', dash=True, at=2)]
els += [Pt('I', *I, 'I', at=3), Seg('gi', 'G', 'I', color='red', width=3, at=3)]
anchor = next(i for i, p in enumerate(ps) if p.startswith("Ou s'il faut tirer la racine carrée de GH"))
scene(anchor, 'La racine carrée', els, [
    beat('Tirer la racine carrée de GH', 5.5),
    beat("Lui ajouter FG, qui est l'unité", 6),
    beat('Décrire le cercle FIH sur FH', 6.5),
    beat('Élever GI perpendiculaire : GI = √GH', 7, pulse=['gi']),
], caption='Descartes, La Géométrie (1637), fig. 2', geo=True)
save('geometrie-fr')
