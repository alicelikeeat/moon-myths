import subprocess
W=1024
def bg(c1,c2):
    return f'''<defs><radialGradient id="bg" cx="50%" cy="38%" r="75%"><stop offset="0" stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></radialGradient>
<linearGradient id="rim" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity=".85"/><stop offset=".5" stop-color="#fff" stop-opacity=".08"/><stop offset="1" stop-color="#fff" stop-opacity=".45"/></linearGradient>
<linearGradient id="sheen" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity=".35"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient>
<filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="18"/></filter>
<filter id="soft" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="6"/></filter>
<filter id="shadow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="28"/></filter>
</defs><rect width="1024" height="1024" fill="url(#bg)"/>'''
def glass(cx,cy,r):  # 玻璃圆片
    return f'''<circle cx="{cx}" cy="{cy+30}" r="{r}" fill="#000" opacity=".35" filter="url(#shadow)"/>
<circle cx="{cx}" cy="{cy}" r="{r}" fill="#fff" fill-opacity=".07"/>
<ellipse cx="{cx}" cy="{cy-r*0.55}" rx="{r*0.72}" ry="{r*0.32}" fill="url(#sheen)"/>
<circle cx="{cx}" cy="{cy}" r="{r-3}" fill="none" stroke="url(#rim)" stroke-width="6"/>'''
icons={}

# 1 道：太极，玻璃里的阴阳
r=300
icons['Tao']=bg('#2a2f3a','#07080c')+glass(512,512,330)+f'''
<g transform="rotate(-30 512 512)">
<path d="M512 {512-r} A{r} {r} 0 0 1 512 {512+r} A{r/2} {r/2} 0 0 1 512 512 A{r/2} {r/2} 0 0 0 512 {512-r}Z" fill="#f4f1ea" opacity=".93"/>
<path d="M512 {512-r} A{r} {r} 0 0 0 512 {512+r} A{r/2} {r/2} 0 0 1 512 512 A{r/2} {r/2} 0 0 0 512 {512-r}Z" fill="#0c0d11" opacity=".9"/>
<circle cx="512" cy="{512-r/2}" r="42" fill="#f4f1ea"/><circle cx="512" cy="{512+r/2}" r="42" fill="#0c0d11"/>
<circle cx="512" cy="512" r="{r}" fill="none" stroke="#fff" stroke-opacity=".5" stroke-width="3"/>
</g>'''

# 2 洞穴：火光、墙上的影子、洞口的太阳
icons['Cave']=bg('#3a2a1e','#0a0604')+f'''
<path d="M0 1024 L0 330 Q120 120 512 110 Q904 120 1024 330 L1024 1024Z" fill="#000" opacity=".35"/>
<circle cx="512" cy="250" r="120" fill="#ffe7b0" opacity=".25" filter="url(#glow)"/>
<circle cx="512" cy="250" r="62" fill="#fff4d6"/>
<path d="M150 820 Q512 760 874 820" stroke="#ffb35c" stroke-opacity=".35" stroke-width="4" fill="none"/>
<g fill="#000" opacity=".75">
<ellipse cx="350" cy="560" rx="58" ry="66"/><rect x="292" y="610" width="116" height="160" rx="50"/>
<ellipse cx="512" cy="540" rx="58" ry="66"/><rect x="454" y="590" width="116" height="180" rx="50"/>
<ellipse cx="674" cy="560" rx="58" ry="66"/><rect x="616" y="610" width="116" height="160" rx="50"/>
</g>
<circle cx="512" cy="900" r="130" fill="#ff8a2a" opacity=".55" filter="url(#glow)"/>
<path d="M512 800 C560 860 580 900 512 960 C444 900 464 860 512 800Z" fill="#ffd08a"/>
<path d="M512 860 C534 890 540 915 512 945 C484 915 490 890 512 860Z" fill="#fff6dc"/>'''+glass(512,512,0)

# 3 永恒轮回：莫比乌斯环（双色带）
import math
def mobius(n=240):
    pts=[]
    out=[]
    for k in range(n+1):
        t=2*math.pi*k/n
        for s in (-1,1):
            pass
    segs=[]
    for k in range(n):
        t0=2*math.pi*k/n; t1=2*math.pi*(k+1)/n
        def P(t,s):
            w=70*s
            R=230+w*math.cos(t/2)
            x=512+R*math.cos(t)*1.18; y=512+R*math.sin(t)*0.62+ w*math.sin(t/2)*1.1
            return x,y
        a=P(t0,-1);b=P(t0,1);c=P(t1,1);d=P(t1,-1)
        depth=math.sin(t0)  # 前后
        shade=0.5+0.5*math.cos(t0/2)
        col=f'rgb({int(150+105*shade)},{int(170+85*shade)},{int(200+55*shade)})'
        segs.append((depth,f'<path d="M{a[0]:.1f} {a[1]:.1f}L{b[0]:.1f} {b[1]:.1f}L{c[0]:.1f} {c[1]:.1f}L{d[0]:.1f} {d[1]:.1f}Z" fill="{col}" stroke="{col}" stroke-width="1.2" opacity=".92"/>'))
    segs.sort()
    return ''.join(s for _,s in segs)
pts=[]
for k in range(721):
    t=2*math.pi*k/720
    d=1+math.sin(t)**2
    pts.append((512+330*math.cos(t)/d, 512+330*math.sin(t)*math.cos(t)/d))
P='M'+' L'.join(f'{x:.1f} {y:.1f}' for x,y in pts)+'Z'
icons['Return']=bg('#1d2440','#05060d')+f'''
<defs><linearGradient id="band" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#9ec5ff"/><stop offset=".5" stop-color="#ffffff"/><stop offset="1" stop-color="#ffcf9e"/></linearGradient></defs>
<path d="{P}" fill="none" stroke="#8fb4ff" stroke-width="90" opacity=".35" filter="url(#glow)"/>
<path d="{P}" fill="none" stroke="url(#band)" stroke-width="54" stroke-linejoin="round"/>
<path d="{P}" fill="none" stroke="#fff" stroke-width="10" opacity=".7" transform="translate(0 -12)"/>
<circle cx="{pts[60][0]:.0f}" cy="{pts[60][1]:.0f}" r="16" fill="#fff"/>
'''

# 4 星空：头上的星空，心中的道德律
import random; random.seed(7)
stars=''.join(f'<circle cx="{random.randint(80,944)}" cy="{random.randint(80,560)}" r="{random.choice([2,2,3,3,4,5])}" fill="#fff" opacity="{random.uniform(.4,1):.2f}"/>' for _ in range(90))
def star4(x,y,s): return f'<path d="M{x} {y-s} Q{x} {y} {x+s} {y} Q{x} {y} {x} {y+s} Q{x} {y} {x-s} {y} Q{x} {y} {x} {y-s}Z" fill="#fff"/>'
icons['Stars']=bg('#1b2a55','#03050c')+stars+f'''
<circle cx="512" cy="300" r="90" fill="#9fc0ff" opacity=".35" filter="url(#glow)"/>{star4(512,300,70)}
<path d="M0 1024 L0 820 Q512 700 1024 820 L1024 1024Z" fill="#000" opacity=".5"/>
<circle cx="512" cy="760" r="120" fill="#ffd27a" opacity=".3" filter="url(#glow)"/>
<path d="M512 840 C430 780 420 700 470 690 C495 685 510 705 512 720 C514 705 529 685 554 690 C604 700 594 780 512 840Z" fill="#ffe3a8"/>
<line x1="512" y1="390" x2="512" y2="680" stroke="#fff" stroke-opacity=".35" stroke-width="3" stroke-dasharray="6 14"/>'''

# 5 维特根斯坦的梯子：登上之后就扔掉
rungs=''.join(f'<line x1="{430+i*6}" y1="{880-i*95}" x2="{594-i*6}" y2="{880-i*95}" stroke="#fff" stroke-width="16" stroke-linecap="round" opacity="{max(.12,1-i*0.16):.2f}"/>' for i in range(7))
icons['Ladder']=bg('#2c3d3a','#060a09')+f'''
<circle cx="512" cy="150" r="160" fill="#e8fff6" opacity=".35" filter="url(#glow)"/>
<circle cx="512" cy="150" r="44" fill="#fff"/>
<line x1="420" y1="940" x2="470" y2="300" stroke="url(#fade)" stroke-width="18" stroke-linecap="round"/>
<line x1="604" y1="940" x2="554" y2="300" stroke="url(#fade)" stroke-width="18" stroke-linecap="round"/>
<defs><linearGradient id="fade" x1="0" y1="1" x2="0" y2="0"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#fff" stop-opacity=".05"/></linearGradient></defs>
'''+rungs

# 6 圆相：禅，一笔画圆，留一缺口
ring=''
N=260
for k in range(N):
    t0=math.radians(-60+ 330*k/N); t1=math.radians(-60+330*(k+1)/N)
    w=20+50*math.sin(math.pi*min(1,k/N*1.15))**0.6
    op=.92 if k<N*0.85 else .92-(k-N*0.85)/(N*0.15)*0.6
    x0,y0=512+290*math.cos(t0),512+290*math.sin(t0); x1,y1=512+290*math.cos(t1),512+290*math.sin(t1)
    ring+=f'<line x1="{x0:.1f}" y1="{y0:.1f}" x2="{x1:.1f}" y2="{y1:.1f}" stroke="#151515" stroke-width="{w:.1f}" stroke-linecap="round" opacity="{op:.2f}"/>'
icons['Enso']=bg('#f6f2ea','#d8d0be')+'<g transform="rotate(-20 512 512)">'+ring+'</g><circle cx="800" cy="840" r="26" fill="#b3261e" opacity=".85"/>'

for k,v in icons.items():
    open(f'{k}.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">{v}</svg>')
    subprocess.run(['rsvg-convert','-w','1024','-h','1024','-b','black' if k!='Enso' else '#eee',f'{k}.svg','-o',f'{k}.png'],check=True)
print(list(icons))
