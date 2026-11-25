"""《九章算术》精讲：句股术（刘徽“出入相补”）与圆田术（刘徽“割圆术”）。"""
import sys, os, json, math
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import anim
from anim import *

doc = json.load(open(os.path.join(anim.ROOT, 'texts', 'jiuzhang-zh.json'), encoding='utf-8'))
paras = [p for s in doc['sections'] for p in s['paragraphs']]
def find(prefix): return next(i for i, p in enumerate(paras) if p.startswith(prefix))

# —— 句股术：两个正方形（朱方 = 句²，青方 = 股²）切下两个直角三角形，平移后拼成弦方
a, b = 3, 4
k, x0, y0 = 0.115, 0.10, 0.90          # 1 单位 = k；(x0, y0) 是左下角
def P(x, y): return (round(x0 + x * k, 4), round(y0 - y * k, 4))
pts = {
    'O': P(0, 0), 'Q': P(a, 0), 'Bb': P(b, 0), 'R0': P(b + a, 0), 'R': P(b + a, a), 'Ba': P(b, a), 'Bt': P(b, b), 'V': P(0, b),
    # 两块会移动的三角形，各用自己的三个顶点
    't1a': P(0, 0), 't1b': P(a, 0), 't1c': P(0, b),
    't2a': P(a, 0), 't2b': P(b + a, 0), 't2c': P(b + a, a),
}
def mv(name, dx, dy):
    x, y = pts[name]; return {'x': round(x + dx * k, 4), 'y': round(y - dy * k, 4)}
els = [Hid(n, *xy) for n, xy in pts.items()]
els += [Poly('qing', ['O', 'Bb', 'Bt', 'V'], '青方 股²=16', color='blue'),
        Poly('zhu', ['Bb', 'R0', 'R', 'Ba'], '朱方 句²=9', color='red', size=11),
        Seg('cut1', 'V', 'Q', color='gold', at=1, dash=True), Seg('cut2', 'Q', 'R', color='gold', at=1, dash=True),
        Poly('rest', ['V', 'Q', 'R', 'Ba', 'Bt'], color='silver', at=2),
        Poly('t1', ['t1a', 't1b', 't1c'], color='gold', at=2), Poly('t2', ['t2a', 't2b', 't2c'], color='violet', at=2),
        Hid('U', *P(b, b + a), at=4), Poly('xian', ['Q', 'R', 'U', 'V'], '弦方 弦²=25', color='gold', at=4)]
scene(find('句股術曰'), '句股术 · 出入相补', els, [
    beat('句三、股四：句自乘为朱方，股自乘为青方', 7),
    beat('从两方的公共边上取一点，沿弦的方向切两刀', 6.5),
    beat('切下的两块直角三角形“出”……', 6, hide=['qing', 'zhu']),
    beat('……再“入”到上方：形状不变，只是移动', 8,
         set={'t1a': mv('t1a', b, a), 't1b': mv('t1b', b, a), 't1c': mv('t1c', b, a),
              't2a': mv('t2a', -a, b), 't2b': mv('t2b', -a, b), 't2c': mv('t2c', -a, b)}),
    beat('合成弦方：句² + 股² = 弦²，9 + 16 = 25', 7.5, pulse=['xian']),
], caption='刘徽注：令出入相补，各从其类', geo=True)

# —— 圆田术：割圆术
ns = [6, 12, 24, 96]
els = [Hid('O', 0.5, 0.52), Hid('T', 0.5, 0.14), Circ('c', 'O', 'T', color='silver')]
for i, n in enumerate(ns):
    els.append(Ngon(f'g{n}', 0.5, 0.52, 0.38, n, color='gold' if i < 3 else 'violet', at=i))
    els.append(T(f'v{n}', 0.5, 0.04, f'正{n}边形：周长 ÷ 直径 ≈ {n * math.sin(math.pi / n):.4f}', color='gold', size=12, at=i))
beats = [beat('圆内接正六边形：周长恰为直径的三倍（“周三径一”）', 7)]
beats.append(beat('割之：边数加倍成十二边，更贴近圆', 6.5, hide=['g6', 'v6']))
beats.append(beat('割之弥细，所失弥少', 6, hide=['g12', 'v12']))
beats.append(beat('割之又割，以至于不可割，则与圆周合体', 8, hide=['g24', 'v24'], pulse=['g96']))
scene(find('術曰半周半徑相乘得積步'), '圆田术 · 割圆术', els, beats,
      caption='刘徽由九十六边形得 π ≈ 157/50 = 3.14', geo=True)

save('jiuzhang-zh')
