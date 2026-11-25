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
beats = [beat('内接正六边形：周长为直径三倍（周三径一）', 7)]
beats.append(beat('割之：边数加倍成十二边，更贴近圆', 6.5, hide=['g6', 'v6']))
beats.append(beat('割之弥细，所失弥少', 6, hide=['g12', 'v12']))
beats.append(beat('割之又割，以至于不可割，则与圆周合体', 8, hide=['g24', 'v24'], pulse=['g96']))
scene(find('術曰半周半徑相乘得積步'), '圆田术 · 割圆术', els, beats,
      caption='刘徽由九十六边形得 π ≈ 157/50 = 3.14', geo=True)

# —— 方田术：广从相乘
k = 0.05; X0, Y0 = 0.12, 0.10; W_, H_ = 15, 16
co = {'r1': (X0, Y0), 'r2': (X0 + W_*k, Y0), 'r3': (X0 + W_*k, Y0 + H_*k), 'r4': (X0, Y0 + H_*k)}
els = [Hid(n, round(x, 4), round(y, 4)) for n, (x, y) in co.items()] + [Poly('tian', ['r1', 'r2', 'r3', 'r4'], color='green')]
els += [Seg('guang', 'r4', 'r3', color='gold', width=3, at=1), T('gl', X0 + W_*k/2, Y0 + H_*k + 0.05, '广十五步', color='gold', size=12, at=1)]
els += [Seg('cong', 'r1', 'r4', color='blue', width=3, at=2), T('cl', 0.05, Y0 + H_*k/2, '从', color='blue', size=12, at=2)]
for i in range(1, W_):
    els += [Hid(f'v{i}a', round(X0 + i*k, 4), Y0, at=3), Hid(f'v{i}b', round(X0 + i*k, 4), round(Y0 + H_*k, 4), at=3), Seg(f'v{i}', f'v{i}a', f'v{i}b', color='silver', at=3, width=0.6)]
for j in range(1, H_):
    els += [Hid(f'h{j}a', X0, round(Y0 + j*k, 4), at=3), Hid(f'h{j}b', round(X0 + W_*k, 4), round(Y0 + j*k, 4), at=3), Seg(f'h{j}', f'h{j}a', f'h{j}b', color='silver', at=3, width=0.6)]
scene(find('方田術曰'), '方田术 · 广从相乘', els, [
    beat('今有田，广十五步，从十六步', 5.5),
    beat('广：横向十五步', 5, pulse=['guang']),
    beat('从：纵向十六步', 5, pulse=['cong']),
    beat('广从步数相乘：15 × 16 = 240 积步', 7),
    beat('以亩法二百四十步除之：恰为一亩', 6.5, pulse=['tian']),
], caption='卷一 · 方田', geo=True)

# —— 开方术：55225 步，开得 235 步
k = 0.80 / 235; X0, Y0 = 0.10, 0.10
Q = lambda a, b: (round(X0 + a*k, 4), round(Y0 + b*k, 4))
def lshape(id, a, b, color, at, label):
    pts_ = {f'{id}1': Q(a, 0), f'{id}2': Q(b, 0), f'{id}3': Q(b, b), f'{id}4': Q(0, b), f'{id}5': Q(0, a), f'{id}6': Q(a, a)}
    return [Hid(n, *p, at=at) for n, p in pts_.items()] + [Poly(id, list(pts_), label, color=color, at=at, size=11)]
els = [Hid('o', *Q(0, 0)), Hid('a', *Q(235, 0)), Hid('b', *Q(235, 235)), Hid('c', *Q(0, 235)), Poly('ji', ['o', 'a', 'b', 'c'], color='silver')]
els += [Hid('s1', *Q(200, 0), at=1), Hid('s2', *Q(200, 200), at=1), Hid('s3', *Q(0, 200), at=1), Poly('sq', ['o', 's1', 's2', 's3'], '200² = 40000', color='gold', at=1)]
els += lshape('g1', 200, 230, 'blue', 2, '') + [T('t1', 0.5, 0.97, '2×200×30 + 30² = 12900', color='blue', size=12, at=2)]
els += lshape('g2', 230, 235, 'red', 3, '') + [T('t2', 0.5, 0.97, '2×230×5 + 5² = 2325', color='red', size=12, at=3)]
scene(find('開方術曰'), '开方术 · 55225 开方得 235', els, [
    beat('积五万五千二百二十五步，求方边', 6),
    beat('议得二百：先减去 200 的方，余 15225', 7),
    beat('复议得三十：减去一道曲尺，余 2325', 8, hide=[]),
    beat('再议得五：最后一道曲尺恰好减尽', 7, hide=['t1']),
    beat('方边 235 步：200 + 30 + 5', 6.5, pulse=['ji']),
], caption='卷四 · 少广', geo=True)

# —— 盈不足术：人出八盈三，人出七不足四
H = lambda v: round(v / 56 * 0.40, 4)
els = [N(f'p{i}', 0.16 + 0.113*i, 0.24, r=11, label='8', color='gold') for i in range(7)]
els += [Bar('pay', 0.36, 0.82, H(56), '共出 56', w=0.16, color='gold'), Bar('price', 0.64, 0.82, H(53), '物价 ?', w=0.16, color='silver')]
els += [T('diff', 0.5, 0.36, '盈三', color='green', size=15)]
els += [T('rule', 0.5, 0.36, '人数 = (3 + 4) ÷ (8 − 7) = 7', color='gold', size=14, at=2),
        T('rule2', 0.5, 0.44, '物价 = 7 × 8 − 3 = 53', color='gold', size=14, at=3)]
set7 = {f'p{i}': {'label': '7', 'color': 'blue'} for i in range(7)}
set7.update({'pay': {'h': H(49), 'label': '共出 49', 'color': 'blue'}, 'diff': {'label': '不足四', 'color': 'red'}})
scene(find('今有共買物人出八'), '盈不足术 · 共买物', els, [
    beat('共买一物：每人出八，多出三', 7),
    beat('每人出七，又差四', 7, set=set7),
    beat('每人多出一，前后相差 3 + 4 = 7：所以有七人', 8, hide=['diff']),
    beat('物价：七人各出八，减去盈的三，得五十三', 7, set={'price': {'label': '物价 53', 'color': 'gold'}}, pulse=['price']),
], caption='卷七 · 盈不足')

# —— 方程术：三行算筹，“遍乘直除”
cols = {'R': 0.78, 'M': 0.55, 'L': 0.32}
rows = [0.30, 0.43, 0.56, 0.74]
names = ['上禾', '中禾', '下禾', '实']
init = {'R': [3, 2, 1, 39], 'M': [2, 3, 1, 34], 'L': [1, 2, 3, 26]}
els = [T(f'n{j}', 0.12, y, nm, color='silver', size=13) for j, (nm, y) in enumerate(zip(names, rows))]
els += [T('hR', cols['R'], 0.18, '右行', color='gold', size=13), T('hM', cols['M'], 0.18, '中行', color='blue', size=13), T('hL', cols['L'], 0.18, '左行', color='red', size=13)]
for c, x in cols.items():
    for j, y in enumerate(rows):
        els.append(T(f'{c}{j}', x, y, str(init[c][j]), color='primary', size=17))
def setcol(c, vals, color):
    return {f'{c}{j}': {'label': str(v), 'color': color} for j, v in enumerate(vals)}
scene(find('今有上禾三秉'), '方程术 · 遍乘直除', els, [
    beat('三个条件布成三行，自右向左', 7),
    beat('以右行上禾三遍乘中行：6、9、3、102', 7.5, set=setcol('M', [6, 9, 3, 102], 'blue')),
    beat('中行两次直除右行：上禾消去，余 0、5、1、24', 8, set=setcol('M', [0, 5, 1, 24], 'blue')),
    beat('左行同样遍乘、直除：0、4、8、39', 8, set=setcol('L', [0, 4, 8, 39], 'red')),
    beat('再遍乘直除：下禾 = 99 ÷ 36 = 2¾ 斗', 9, set=setcol('L', [0, 0, 36, 99], 'red'), pulse=['L3', 'L2']),
], caption='卷八 · 方程')

save('jiuzhang-zh')
