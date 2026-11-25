"""真实性评分（满分 100）：五项，规则见 RUBRIC。
自动部分：底本来源、原文/译本、实物佐证（来自 Sources/editions.json）。
人工部分：完整性备注、作者与成书（依学界通行看法，只写共识，不下新结论）。
"""
import json, glob, os, re
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
texts = {os.path.basename(f)[:-5]: json.load(open(f, encoding='utf-8')) for f in glob.glob(f'{ROOT}/texts/*.json')}
editions = json.load(open(f'{ROOT}/Sources/editions.json', encoding='utf-8'))

RUBRIC = [
    ("底本", 25, "全文据什么本子。有明确版本的古籍数字化（四库全书、四部丛刊、道藏等）得满分；据可考的印本转录（注明版本或译者）次之；转录本未注明底本再次之。"),
    ("原文", 20, "能否读到原文。有原文得满分；只有公有领域译本、译者可考的得 12 分。"),
    ("完整", 20, "收录是否完整。全书得满分；分篇或残缺有已知问题的酌减；只有节选的得 5 分。"),
    ("实物", 20, "有无实物佐证。初版扉页、写本、刊本书影每张 6 分（最多 2 张）；可查阅的扫描本每部 4 分；合计封顶 20。"),
    ("成书", 15, "作者与成书是否清楚。作者亲撰、生前刊行得满分；弟子编录、层累成书、真伪有争议的依学界通行看法递减。"),
]

# 书 → 全文
FT = {"kant-cpr": ["kant-cpr-de", "kant-cpr-en"], "euclid": ["jihe-zh", "euclid-en"], "jiuzhang": ["jiuzhang-zh"], "hegel-logic": ["hegel-logic-1-de", "hegel-logic-2-de"], "hegel-phen": ["hegel-phen-de"],
      "nicomachean": ["ethics-aristotle-en"], "zhuziyulei": ["zhuziyulei-1-zh", "zhuziyulei-36-zh", "zhuziyulei-71-zh", "zhuziyulei-106-zh"],
      "russell-denoting": [], "russell-pm": [], "russell-problems": []}
def fulltexts(b):
    return FT.get(b) or [t for t in texts if re.fullmatch(re.escape(b) + r'-(zh|en|de|la|fr)', t)]

# 原著语言（英文原著的英文本算原文）
ENGLISH_ORIGINAL = {"enquiry", "leviathan", "locke-government", "berkeley-principles", "on-liberty", "utilitarianism", "pragmatism", "russell-denoting", "russell-pm", "russell-problems"}

# 有明确底本说明的 Gutenberg 本（原文印本或可考译者）
NAMED_EDITION = {
    "archimedes": "Heiberg 校订、Robinson 英译本（Open Court，1909）",
    "geometrie": "法文原文，据 Victor Cousin 编《笛卡尔全集》本（部分符号已改为通行写法）",
    "euclid": "利玛窦、徐光启 1607 年译本（四库全书本）；Casey 1885 年英译本",
    "kant-cpr": "德文第二版（B 版，1787）；英译 Meiklejohn（1855）",
    "hegel-phen": "德文原文，据 1807 年初版文本",
    "hegel-logic": "德文原文，两卷",
    "tractatus": "德文原文，据 1921 年《自然哲学年鉴》首刊文本",
    "monadologie": "法文原文，Clodius Piat 校订本（1909）",
    "meditationes": "拉丁文原文，Bibliotheca Philosophorum 本（附德文编者注）",
    "zarathustra": "德文原文；英译 Thomas Common",
    "xunzi": "王先谦《荀子集解》（1891）",
}
# 转录本未注明底本的中文本
UNNAMED_ZH = {"lunyu", "daodejing", "mozi", "chunqiufanlu", "tanjing", "chuanxilu"}

# 完整性：(分数, 说明)
COMPLETE = {
    "hanfeizi": (16, "四库本全文，但原书 55 篇中只识别出 43 个篇题，部分篇目合在一起显示"),
    "mozi": (17, "收 51 篇；今本《墨子》存 53 篇"),
    "meditationes": (17, "正文完整，但夹有德文版编者注释"),
    "lunheng": (18, "全文，按卷分段，篇题未逐一分开"),
    "guanzi": (18, "全文，部分篇目分段较粗"),
    "kant-cpr": (20, "A/B 两版中收 B 版全文，并有英译全文"),
    "archimedes": (17, "重写本残缺，命题 XIV 以后不全；1909 年英译收入全部可辨认的内容"),
    "geometrie": (18, "三卷全文；本应用转录时数学式改为通行写法，图未收"),
    "euclid": (16, "收利玛窦、徐光启译本前六卷与 Casey 英译前六卷；全书十三卷，后七卷未收"),
    "schopenhauer-essays": (14, "英译选本，只收《附录与补遗》中的部分文章"),
    "russell-denoting": (5, "该文仍受版权保护的地区较多，只收节选"),
    "russell-pm": (5, "只收节选"),
    "russell-problems": (5, "只收节选"),
}

# 作者与成书：(分数, 说明) —— 只写学界通行看法
AUTHOR = {
    "kant-cpr": (15, "康德亲撰，生前两版均亲自修订"), "hegel-phen": (15, "黑格尔亲撰，1807 年刊行"), "hegel-logic": (15, "黑格尔亲撰，生前刊行"),
    "russell-denoting": (15, "罗素署名发表于《心灵》"), "russell-pm": (15, "怀特海与罗素合著，生前刊行"), "russell-problems": (15, "罗素亲撰"),
    "lunyu": (12, "孔子弟子及再传弟子编录，非孔子亲撰；主体被普遍视为可靠"),
    "daodejing": (12, "作者与成书年代有争议；郭店楚简、马王堆帛书证明战国时已有传本，各本文字有出入"),
    "zhuangzi": (10, "通常认为内七篇较接近庄子本人，外篇、杂篇多出自后学；今本 33 篇为郭象删定"),
    "mengzi": (13, "孟子与弟子万章、公孙丑等共同编定，学界普遍视为可靠"),
    "hanfeizi": (12, "大部分出自韩非；《初见秦》等少数篇章的作者有争议"),
    "zhuziyulei": (12, "朱熹门人记录、黎靖德 1270 年汇编，记录者不同，文字有出入"),
    "mozi": (11, "墨家各派长期累积而成，并非墨子一人所作；墨辩、城守诸篇年代较晚"),
    "xunzi": (13, "大部分出自荀子；末几篇多认为是弟子所记"),
    "chunqiufanlu": (10, "一般归于董仲舒，但部分篇章的真伪历来有争议"),
    "tanjing": (9, "法海集录；敦煌本与宗宝本等后世通行本差异很大，有层累增补"),
    "chuanxilu": (12, "王阳明弟子徐爱、陆澄、钱德洪等记录编订，部分经王阳明本人审阅"),
    "apology": (14, "柏拉图所作，记述苏格拉底受审；是否忠实于苏格拉底原话无法确证"),
    "republic": (15, "柏拉图真作，无争议"), "phaedo": (15, "柏拉图真作，无争议"), "symposium": (15, "柏拉图真作，无争议"),
    "confessions": (15, "奥古斯丁亲撰"), "discourse": (15, "笛卡尔亲撰，1637 年刊行"), "meditationes": (15, "笛卡尔亲撰，1641 年刊行"),
    "ethics": (14, "斯宾诺莎亲撰，身后由友人编入《遗著集》刊行"), "enquiry": (15, "休谟亲撰"),
    "nicomachean": (12, "一般视为亚里士多德的讲稿，经后人编定，书名据其子尼各马可"), "politics": (12, "亚里士多德讲稿，经后人编定，篇章次序有争议"),
    "summa": (14, "阿奎那亲撰；第三集未完成，由弟子据其旧作补成《补编》（本书只收第一集）"),
    "monadologie": (14, "莱布尼茨亲撰（1714），生前未刊，身后整理出版"),
    "tractatus": (15, "维特根斯坦亲撰，生前刊行"),
    "zhouyi": (10, "卦爻辞与《易传》分属不同年代；《十翼》传为孔子作，学界多不采信"),
    "guanzi": (8, "托名管仲，实为战国至汉代多人所作的汇编"),
    "sunzi": (13, "1972 年银雀山汉简出土，证实战国、汉初已有传本；作者一般归于孙武"),
    "liji": (10, "战国至汉代儒家论礼文章的汇编，西汉戴圣编定"),
    "liezi": (5, "今本多被学者认为是魏晋时人编撰，托名列御寇，真伪争议很大"),
    "gongsunlong": (10, "今存 6 篇；《迹府》为后人所记，其余篇章真伪仍有讨论"),
    "lunheng": (15, "王充亲撰"), "zhouyuangong": (13, "周敦颐著作的后世编集"), "zhangzi": (13, "张载著作的后世编集"),
    "ercheng": (12, "程颢、程颐门人所记语录，朱熹编定"), "xiangshan": (13, "陆九渊文集，其子与门人编定"), "rizhilu": (15, "顾炎武亲撰"),
    "lucretius": (14, "卢克莱修所作；相传由西塞罗整理刊行"), "enchiridion": (12, "爱比克泰德的讲话，由弟子阿里安记录编成"),
    "meditations": (14, "马可·奥勒留自写的札记，原本并非为出版而作"), "prince": (15, "马基雅维利亲撰，身后 1532 年刊行"),
    "leviathan": (15, "霍布斯亲撰，1651 年刊行"), "pensees": (11, "帕斯卡尔身后留下的遗稿片段，编排次序由后人确定，各版不同"),
    "locke-government": (15, "洛克亲撰，1689 年匿名刊行"), "berkeley-principles": (15, "贝克莱亲撰"), "rousseau-inequality": (15, "卢梭亲撰"),
    "schopenhauer-essays": (13, "叔本华《附录与补遗》的英译选本，篇目由译者选编"), "on-liberty": (15, "密尔亲撰"), "utilitarianism": (15, "密尔亲撰"),
    "manifesto": (15, "马克思、恩格斯合著，1848 年刊行"), "pragmatism": (15, "詹姆士的讲演，生前刊行"), "groundwork": (15, "康德亲撰"),
    "bge": (15, "尼采亲撰"), "zarathustra": (15, "尼采亲撰"),
    "euclid": (12, "一般归于欧几里得，但他整理汇编了前人成果；今本经塞翁（4 世纪）等人修订，19 世纪发现的梵蒂冈抄本更接近早期面貌"),
    "archimedes": (14, "阿基米德致埃拉托色尼的信；全文只靠一部 10 世纪抄本传世，部分残缺，1906 年由海伯格辨认出来"),
    "zhoubi": (10, "成书年代与作者不详，一般认为在西汉前后编定，内容层累；附赵爽、甄鸾、李淳风三家注"),
    "geometrie": (15, "笛卡尔亲撰，1637 年作为《谈谈方法》的附录刊行"),
    "jiuzhang": (11, "非一人一时之作，约在东汉编定；今本附刘徽注（263 年）与李淳风等注释（唐），原文与注文分得开"),
}

# 从书目信息里读出的底本（Timeline.swift 中的原名标注）
KR_ED = {}
for m in re.finditer(r'work\("([^"]+)", "[^"]*", "([^"]*)"', open(f'{ROOT}/Sources/Timeline.swift', encoding='utf-8').read()):
    e = re.search(r'（(四庫本|四部丛刊本)）', m.group(2))
    if e: KR_ED[m.group(1)] = {'四庫本': '《四库全书》本', '四部丛刊本': '《四部丛刊》本'}[e.group(1)]
FIRST = re.compile(r'初版|写本|帛书|抄本|刊本|扉页|手稿|纸草|残片|宋刻|书页')
out = {}
for b, (au, aunote) in AUTHOR.items():
    fts = [t for t in fulltexts(b) if t in texts]
    src = ' '.join(texts[t]['source'] for t in fts)
    notes = {}
    # 底本
    if 'Kanseki' in src:
        kr = re.search(r'KR\w+', src).group(0)
        ed_ = next((v for k, v in KR_ED.items() if k == b), None)
        base, notes['底本'] = 25, f"据漢籍リポジトリ（Kanseki Repository）{kr} 整理" + (f"，底本为{ed_}" if ed_ else "，该库收录的古籍均注明所据版本")
    elif b in NAMED_EDITION:
        base, notes['底本'] = 22, NAMED_EDITION[b] + "；据 Project Gutenberg 转录"
    elif not fts:
        base, notes['底本'] = 12, "本应用只收节选，节选依据通行版本"
    elif b in UNNAMED_ZH:
        base, notes['底本'] = 15, "据 Project Gutenberg 转录本，未注明所据底本"
    else:
        title = ' / '.join(texts[t]['title'] for t in fts)
        base, notes['底本'] = 20, f"{title}；据 Project Gutenberg 转录的公有领域印本"
    if b == "euclid":
        base, notes['底本'] = 23, "中译据漢籍リポジトリ KR3f0047 整理，底本为《四库全书》本；英译据 Project Gutenberg #21076（Casey 1885 年版）"
    # 原文
    if b == "euclid":
        orig, notes['原文'] = 12, "原著为古希腊文，本应用只有译本：利玛窦、徐光启 1607 年中译，Casey 1885 年英译"
        langs = set()
    else:
        langs = {texts[t]['lang'] for t in fts}
    if b == "euclid": pass
    elif b in ENGLISH_ORIGINAL or langs & {'zh', 'de', 'la', 'fr'}:
        orig, notes['原文'] = 20, "可读原文" + ("，另附英译" if 'en' in langs and len(langs) > 1 else "")
    else:
        orig, notes['原文'] = 12, "只有公有领域英译本：" + ' / '.join(texts[t]['title'] for t in fts)
    # 完整
    comp, notes['完整'] = COMPLETE.get(b, (20, "全书收录"))
    # 实物
    ed = editions.get(b, {'images': [], 'scans': []})
    ni = min(2, sum(1 for i in ed['images'] if FIRST.search(i['caption'])))
    ns = len(ed['scans'])
    phys = min(20, ni * 6 + ns * 4)
    notes['实物'] = f"书影 {len(ed['images'])} 张、可查阅扫描本 {ns} 部" if (ed['images'] or ns) else "暂未找到公有领域的书影或扫描本"
    notes['成书'] = aunote
    parts = {'底本': base, '原文': orig, '完整': comp, '实物': phys, '成书': au}
    out[b] = {'total': sum(parts.values()), 'parts': parts, 'notes': notes}
json.dump({'rubric': [{'name': n, 'max': m, 'rule': r} for n, m, r in RUBRIC], 'books': out},
          open(f'{ROOT}/Sources/authenticity.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
for b, v in sorted(out.items(), key=lambda x: -x[1]['total']):
    print(f"{v['total']:3d} {b:22s} {v['parts']}")
