"""牛顿《原理》（1687 初版，拉丁文）：运动定律推论一（力的平行四边形）、第一卷命题一（等面积定律）。"""
import sys, os, json, math
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import anim
from anim import *
d = json.load(open(os.path.join(anim.ROOT, 'texts', 'principia-la.json'), encoding='utf-8'))
ps = [p for s in d['sections'] for p in s['paragraphs']]
find = lambda pre: next(i for i, p in enumerate(ps) if p.startswith(pre))

# 推论一：力的平行四边形
A, B, C = (0.18, 0.78), (0.70, 0.70), (0.34, 0.24); D = (B[0] + C[0] - A[0], B[1] + C[1] - A[1])
els = [Pt('A', *A, 'A'), Pt('B', *B, 'B', at=1), Seg('ab', 'A', 'B', 'M', color='blue', width=2.6, at=1),
       Pt('C', *C, 'C', at=2), Seg('ac', 'A', 'C', 'N', color='red', width=2.6, at=2),
       Pt('D', *D, 'D', at=3), Seg('bd', 'B', 'D', dash=True, at=3), Seg('cd', 'C', 'D', dash=True, at=3),
       Seg('ad', 'A', 'D', color='gold', width=3, at=3), N('body', A[0], A[1], r=7, color='gold')]
scene(find('Corpus viribus conjunctis diagonalem'), 'Lex · Corollarium I', els, [
    beat('Corpus in loco A', 5),
    beat('Vi M sola: eodem tempore ab A ad B', 6),
    beat('Vi N sola: ab A ad C', 6),
    beat('Viribus conjunctis: per diagonalem AD', 7.5, set={'body': {'x': D[0], 'y': D[1]}}),
], caption='Newton, Principia (1687), Axiomata, Corol. I', geo=True)

# 第一卷命题一：等时间扫过等面积
S = (0.46, 0.52); P = [(0.12, 0.86), (0.36, 0.90)]
for n in range(4):
    a, b = P[-2], P[-1]; P.append((b[0] + (b[0] - a[0]) + 0.30 * (S[0] - b[0]), b[1] + (b[1] - a[1]) + 0.30 * (S[1] - b[1])))
names = 'ABCDEF'
c_ = (2 * P[1][0] - P[0][0], 2 * P[1][1] - P[0][1])
els = [Pt('S', *S, 'S', color='gold', r=5)] + [Pt(names[i], *P[i], names[i], at=(0 if i < 2 else 2 if i == 2 else 3)) for i in range(6)]
els += [Seg('ab', 'A', 'B', color='silver', width=2.4), Poly('t0', ['S', 'A', 'B'], color='blue')]
els += [Pt('c', *c_, 'c', at=1), Seg('bc0', 'B', 'c', dash=True, at=1), Poly('t1', ['S', 'B', 'c'], color='violet', at=1)]
els += [Seg('bC', 'B', 'C', width=2.4, at=2), Seg('cC', 'c', 'C', dash=True, color='red', at=2), Poly('t2', ['S', 'B', 'C'], color='blue', at=2)]
for i in range(2, 5):
    els += [Seg(f's{i}', names[i], names[i + 1], width=2.4, at=3), Poly(f't{i+1}', ['S', names[i], names[i + 1]], color='blue', at=3)]
scene(find('Dividatur tempus in partes æquales'), 'Liber I · Prop. I', els, [
    beat('Prima temporis parte: rectam AB', 6),
    beat('Si nil impediret, pergeret ad c: Bc = AB', 6.5, pulse=['t0', 't1']),
    beat('Impulsus in B: pergit in BC, cC ∥ BS', 7.5, hide=['t1'], pulse=['t2']),
    beat('Simili argumento: D, E, F …', 6.5),
    beat('Æqualibus temporibus æquales areæ', 7.5, pulse=['t0', 't2', 't3', 't4', 't5']),
], caption='Newton, Principia (1687), Lib. I, Prop. I', geo=True)
save('principia-la')
