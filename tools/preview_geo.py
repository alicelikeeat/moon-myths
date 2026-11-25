"""在本地粗略渲染几何动画每个场景最后一拍的状态，检查作图是否正确。"""
import json, sys, math
from PIL import Image, ImageDraw, ImageFont
tid = sys.argv[1]; out = sys.argv[2]; beat_ix = int(sys.argv[3]) if len(sys.argv) > 3 else -1
d = json.load(open(f'/home/claude/moon-myths/anims/{tid}.json'))
sc = [s for s in d['scenes'] if s.get('geo')]
T = 300; cols = 6; rows = math.ceil(len(sc) / cols)
img = Image.new('RGB', (cols * T, rows * (T + 20)), 'white'); dr = ImageDraw.Draw(img)
try: font = ImageFont.truetype('/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc', 11)
except Exception:
    import glob; f = (glob.glob('/usr/share/fonts/**/*CJK*', recursive=True) + glob.glob('/usr/share/fonts/**/*.ttf', recursive=True))[0]; font = ImageFont.truetype(f, 11)
COL = {'gold': (190, 140, 40), 'blue': (60, 110, 220), 'red': (210, 60, 60), 'green': (60, 160, 80), 'violet': (130, 80, 200), 'silver': (90, 110, 150), 'primary': (20, 20, 20)}
for n, s in enumerate(sc):
    ox, oy = (n % cols) * T, (n // cols) * (T + 20)
    S = T * 0.8; gx, gy = ox + T * 0.1, oy + T * 0.1
    els = {e['id']: dict(e, op=0) for e in s['elements']}
    nb = len(s['beats']) if beat_ix < 0 else beat_ix + 1
    for b in range(nb):
        for e in els.values():
            if e.get('at', 0) == b: e['op'] = 1
        for k, v in (s['beats'][b].get('set') or {}).items(): els[k].update(v)
        for k in s['beats'][b].get('hide') or []: els[k]['op'] = 0
    P = lambda e: (gx + e['x'] * S, gy + e['y'] * S)
    dr.rectangle([ox, oy, ox + T - 1, oy + T - 1], outline=(220, 220, 220))
    for e in els.values():
        if not e['op']: continue
        c = COL.get(e.get('color', 'silver'), (90, 110, 150))
        k = e['kind']
        if k == 'poly':
            pts = [P(els[q]) for q in e['pts']]
            lay = Image.new('RGBA', img.size, (0, 0, 0, 0)); ImageDraw.Draw(lay).polygon(pts, fill=c + (50,), outline=c + (200,))
            img.paste(Image.alpha_composite(img.convert('RGBA'), lay).convert('RGB')); dr = ImageDraw.Draw(img)
        elif k == 'seg':
            dr.line([P(els[e['from']]), P(els[e['to']])], fill=c, width=2)
        elif k == 'circle':
            a, b = P(els[e['from']]), P(els[e['to']]); r = math.dist(a, b)
            dr.ellipse([a[0] - r, a[1] - r, a[0] + r, a[1] + r], outline=c)
        elif k == 'ngon':
            r = e['w'] * S; cx, cy = P(e)
            dr.polygon([(cx + r * math.cos(-math.pi/2 + 2*math.pi*i/e['n']), cy + r * math.sin(-math.pi/2 + 2*math.pi*i/e['n'])) for i in range(e['n'])], outline=c)
    for e in els.values():
        if e['op'] and e['kind'] == 'node' and e.get('r', 1) > 1:
            x, y = P(e); dr.ellipse([x - 2.5, y - 2.5, x + 2.5, y + 2.5], fill=(0, 0, 0))
            if e.get('label'): dr.text((x + 3, y + 2), e['label'], fill=(0, 0, 0), font=font)
        if e['op'] and e['kind'] == 'text': x, y = P(e); dr.text((x - 60, y), e['label'], fill=(150, 100, 0), font=font)
    dr.text((ox + 4, oy + 3), s['beats'][nb - 1]['headline'][:40], fill=(0, 0, 0), font=font)
    dr.text((ox + 4, oy + T + 3), s['title'][:30], fill=(0, 0, 0), font=font)
img.save(out); print(out, len(sc))
