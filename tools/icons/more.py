import math, random, subprocess
exec(open('gen.py').read().split("icons={}")[0])
icons={}
# 密涅瓦的猫头鹰：黄昏起飞（黑格尔）
icons['Owl']=bg('#5a3a3a','#120a12')+'''
<rect y="640" width="1024" height="384" fill="#ff9a5a" opacity=".18"/>
<circle cx="512" cy="700" r="260" fill="#ff8a50" opacity=".35" filter="url(#glow)"/>
<path d="M512 250 C330 250 260 400 270 560 C280 760 400 860 512 860 C624 860 744 760 754 560 C764 400 694 250 512 250Z" fill="#1a1216"/>
<path d="M300 300 L360 200 L420 290Z M724 300 L664 200 L604 290Z" fill="#1a1216"/>
<circle cx="415" cy="470" r="105" fill="#f6d28a" opacity=".25" filter="url(#soft)"/>
<circle cx="609" cy="470" r="105" fill="#f6d28a" opacity=".25" filter="url(#soft)"/>
<circle cx="415" cy="470" r="86" fill="#f8dc95"/><circle cx="609" cy="470" r="86" fill="#f8dc95"/>
<circle cx="415" cy="470" r="40" fill="#120a0c"/><circle cx="609" cy="470" r="40" fill="#120a0c"/>
<circle cx="428" cy="455" r="12" fill="#fff"/><circle cx="622" cy="455" r="12" fill="#fff"/>
<path d="M512 545 L482 590 L512 640 L542 590Z" fill="#d9a35a"/>
<path d="M380 700 Q512 760 644 700" stroke="#3a2a2e" stroke-width="10" fill="none"/>
<path d="M400 770 Q512 820 624 770" stroke="#3a2a2e" stroke-width="10" fill="none"/>
<path d="M200 870 L824 870" stroke="#3a2420" stroke-width="22" stroke-linecap="round"/>
<path d="M830 190 A70 70 0 1 0 880 300 A55 55 0 1 1 830 190Z" fill="#ffe9c0" opacity=".9"/>'''
# 庄周梦蝶
def wing(sx):
    return f'''<g transform="translate(512 512) scale({sx} 1)">
<path d="M0 -20 C60 -220 300 -300 330 -170 C350 -70 200 0 0 10Z" fill="url(#wg)" opacity=".92"/>
<path d="M0 20 C80 40 260 70 240 200 C220 300 80 260 0 60Z" fill="url(#wg2)" opacity=".85"/>
<circle cx="230" cy="-160" r="30" fill="#fff" opacity=".55"/></g>'''
icons['Butterfly']=bg('#3b4a6b','#0d1020')+'''<defs><linearGradient id="wg" x1="0" y1="1" x2="1" y2="0"><stop offset="0" stop-color="#9fd8ff"/><stop offset="1" stop-color="#e6c8ff"/></linearGradient>
<linearGradient id="wg2" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#bfe8ff"/><stop offset="1" stop-color="#ffd6f0"/></linearGradient></defs>
<circle cx="512" cy="512" r="330" fill="#b8d8ff" opacity=".22" filter="url(#glow)"/>'''+wing(1)+wing(-1)+'''
<ellipse cx="512" cy="530" rx="16" ry="120" fill="#20243a"/>
<path d="M505 415 Q470 330 440 300 M519 415 Q554 330 584 300" stroke="#20243a" stroke-width="6" fill="none"/>
'''+''.join(f'<circle cx="{x}" cy="{y}" r="{r}" fill="#fff" opacity=".5"/>' for x,y,r in [(200,260,5),(820,300,4),(760,820,6),(250,780,4),(880,620,3),(150,520,3)])
# 我思：黑暗中唯一确定的一点光（笛卡尔）
rings=''.join(f'<circle cx="512" cy="512" r="{r}" fill="none" stroke="#fff" stroke-opacity="{o}" stroke-width="2"/>' for r,o in [(140,.25),(230,.15),(320,.08),(410,.04)])
icons['Cogito']=bg('#16161c','#000')+rings+'''
<circle cx="512" cy="512" r="110" fill="#fff6dc" opacity=".55" filter="url(#glow)"/>
<circle cx="512" cy="512" r="46" fill="#fff"/>
<text x="512" y="860" text-anchor="middle" font-family="Times New Roman, serif" font-style="italic" font-size="64" fill="#fff" opacity=".55" letter-spacing="6">cogito</text>'''
# 西西弗斯：推石上山（加缪）
L='stroke="#2a1612" stroke-linecap="round" stroke-linejoin="round" fill="none"'
icons['Sisyphus']=bg('#f0b27a','#7a3b2a')+f'''
<circle cx="800" cy="200" r="80" fill="#fff1d6" opacity=".9"/>
<path d="M0 1024 L0 900 L1024 300 L1024 1024Z" fill="#2a1612"/>
<circle cx="640" cy="374" r="150" fill="#3a221c"/>
<circle cx="600" cy="330" r="50" fill="#fff" opacity=".08"/>
<path d="M420 570 L492 470" {L} stroke-width="46"/>
<circle cx="520" cy="430" r="30" fill="#2a1612"/>
<path d="M492 470 L545 420 M492 478 L548 470" {L} stroke-width="20"/>
<path d="M420 570 L440 630 L478 618" {L} stroke-width="24"/>
<path d="M420 570 L372 682" {L} stroke-width="24"/>
'''
# 赫拉克利特之河：人不能两次踏入同一条河
river=''
for i in range(9):
    y=330+i*55; a=40+i*6
    river+=f'<path d="M-20 {y} C200 {y-a} 320 {y+a} 512 {y} S820 {y-a} 1044 {y}" stroke="#bfe6ff" stroke-opacity="{.85-i*0.08:.2f}" stroke-width="{14-i}" fill="none" stroke-linecap="round"/>'
icons['River']=bg('#1d3b52','#04101a')+'<circle cx="512" cy="200" r="70" fill="#e6f6ff" opacity=".9"/><circle cx="512" cy="200" r="150" fill="#9fd4ff" opacity=".25" filter="url(#glow)"/>'+river+'''
<ellipse cx="400" cy="590" rx="44" ry="20" fill="#ffffff" opacity=".85"/><ellipse cx="640" cy="660" rx="44" ry="20" fill="#ffffff" opacity=".35"/>'''
# 德尔斐：认识你自己（苏格拉底）
cols=''.join(f'<rect x="{x}" y="420" width="64" height="330" rx="6" fill="#f2ece0"/><rect x="{x-12}" y="408" width="88" height="22" fill="#f2ece0"/>' for x in (262,412,562,712))
icons['Delphi']=bg('#3a4f63','#0e1620')+'''
<path d="M200 380 L512 210 L824 380Z" fill="#f2ece0"/><rect x="200" y="380" width="624" height="28" fill="#e0d8c8"/>
'''+cols+'''<rect x="180" y="750" width="664" height="30" fill="#e0d8c8"/><rect x="150" y="780" width="724" height="30" fill="#cfc6b4"/>
<text x="512" y="350" text-anchor="middle" font-family="Times New Roman, serif" font-size="40" fill="#5a6a7a" letter-spacing="4">ΓΝΩΘΙ ΣΑΥΤΟΝ</text>'''
# 芝诺：飞矢不动
ghosts=''.join(f'<g opacity="{o}" transform="translate({dx} 0)"><line x1="160" y1="512" x2="640" y2="512" stroke="#fff" stroke-width="12"/><path d="M640 470 L740 512 L640 554Z" fill="#fff"/><path d="M160 512 L120 470 L200 470 L240 512 L200 554 L120 554Z" fill="#ffb36b"/></g>' for dx,o in [(-120,.08),(-80,.15),(-40,.3),(0,1)])
ticks=''.join(f'<line x1="{x}" y1="640" x2="{x}" y2="{660 if i%4 else 690}" stroke="#fff" stroke-opacity=".45" stroke-width="4"/>' for i,x in enumerate(range(140,900,40)))
icons['Arrow']=bg('#3c2f55','#0b0812')+'<g transform="translate(90 0)">'+ghosts+'</g>'+ticks+'<line x1="140" y1="640" x2="880" y2="640" stroke="#fff" stroke-opacity=".45" stroke-width="4"/>'
# 杏坛：孔子讲学
random.seed(3)
blos=''
for _ in range(26):
    x=random.randint(150,880); y=random.randint(150,520); r=random.randint(18,34)
    blos+=''.join(f'<circle cx="{x+r*0.6*math.cos(a):.0f}" cy="{y+r*0.6*math.sin(a):.0f}" r="{r*0.5:.0f}" fill="#ffd9de" opacity=".9"/>' for a in [k*2*math.pi/5 for k in range(5)])+f'<circle cx="{x}" cy="{y}" r="{r*0.22:.0f}" fill="#d8576a"/>'
icons['Apricot']=bg('#f7efe4','#e2d3c0')+'''
<path d="M512 830 L512 560 Q500 420 380 330 M512 600 Q560 450 700 360 M440 380 Q340 300 260 300 M620 410 Q720 330 820 330" stroke="#4a3328" stroke-width="26" stroke-linecap="round" fill="none"/>
'''+blos+'''<rect x="300" y="820" width="424" height="40" rx="6" fill="#8a5a3a"/><rect x="260" y="860" width="504" height="40" rx="6" fill="#6b4530"/>'''
for k,v in icons.items():
    open(f'{k}.svg','w').write(f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">{v}</svg>')
    subprocess.run(['rsvg-convert','-w','1024','-h','1024','-b','black',f'{k}.svg','-o',f'{k}.png'],check=True)
from PIL import Image
ks=list(icons); im=Image.new('RGB',(4*340,2*340),'white')
for i,k in enumerate(ks):
    t=Image.open(k+'.png').convert('RGB').resize((320,320)); im.paste(t,((i%4)*340+10,(i//4)*340+10))
im.save('sheet2.png'); print(ks)
