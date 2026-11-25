import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import anim
from anim import *

# —— 《精神现象学》 ——
scene(24, "花蕾、花朵、果实", [
    N("bud", 0.2, 0.5, "花蕾", "green", 10), N("flower", 0.5, 0.5, "花朵", "violet", 14, at=1), N("fruit", 0.8, 0.5, "果实", "gold", 14, at=2),
    A("a", "bud", "flower", "", "gold", at=1), A("b", "flower", "fruit", "", "gold", at=2)],
    [beat("花朵开放时，花蕾消失了"), beat("看起来，花朵否定了花蕾", set={"bud": {"opacity": 0.3}}),
     beat("其实它们都是同一个有机统一体的必要环节", 7.5, set={"bud": {"opacity": 1}}, pulse=["fruit"])], "Knospe · Blüte · Frucht")
scene(39, "实体即主体", [
    N("sub", 0.5, 0.5, "实体", "silver", 22),
    R("move", 0.5, 0.5, 70, "", "gold", at=1, dash=True),
    N("me", 0.5, 0.5 - 70 / 380, "主体", "gold", 10, at=2)],
    [beat("真理不仅被理解为实体"), beat("还要被理解为自我运动"), beat("同样也是主体", 7.5, pulse=["me"])], "Substanz ebensosehr als Subjekt")
scene(42, "真理是全体", [
    N("p1", 0.25, 0.4, "环节", "silver", 9), N("p2", 0.75, 0.4, "环节", "silver", 9), N("p3", 0.5, 0.72, "环节", "silver", 9),
    R("whole", 0.5, 0.52, 110, "全体", "gold", at=1),
    T("t", 0.5, 0.86, "本质上是结果，只有到终点才是真实的样子", "primary", 11, at=2)],
    [beat("单个环节，都不是真理"), beat("真理是全体"), beat("全体是通过自身发展而完成的本质", 7.5, pulse=["whole"])], "Das Wahre ist das Ganze")
scene(53, "熟知非真知", [
    N("known", 0.5, 0.45, "熟知的", "silver", 18),
    T("t", 0.5, 0.75, "因为熟知，就不去认识", "violet", 13, at=1)],
    [beat("一切都觉得很熟悉"), beat("正因为熟知，所以没有被真正认识", set={"known": {"opacity": 0.4}}),
     beat("哲学要从熟悉的东西里，把概念剥出来", 7.5, set={"known": {"color": "gold", "opacity": 1}})], "Das Bekannte ist nicht erkannt")
chain(90, "怀疑的道路", ["自然意识", "怀疑", "绝望", "真知"],
      ["意识以为自己已有真知", "一次次发现它不是真的", "这是一条怀疑、乃至绝望之路：意识的教化史"], "Weg der Verzweiflung",
      colors={2: "violet"})
scene(106, "感性确定性：这时是夜晚", [
    T("now", 0.5, 0.35, "这时 = 夜晚", "primary", 18),
    T("now2", 0.5, 0.5, "这时 = 中午", "primary", 18, at=1),
    N("u", 0.5, 0.75, "“这时”：普遍者", "gold", 14, at=2)],
    [beat("写下：这时是夜晚"), beat("到中午再看，这个真理已经变馊了", set={"now": {"opacity": 0.3}}),
     beat("留下来的“这时”，其实是普遍者", 7.5, pulse=["u"])], "das Jetzt ist die Nacht")
scene(133, "知觉：物与诸性质", [
    N("thing", 0.5, 0.45, "盐", "silver", 18),
    N("q1", 0.2, 0.3, "白", "silver", 9, at=1), N("q2", 0.8, 0.3, "咸", "silver", 9, at=1), N("q3", 0.5, 0.8, "立方", "silver", 9, at=1),
    A("a", "thing", "q1", "", "dim", at=1), A("b", "thing", "q2", "", "dim", at=1), A("c", "thing", "q3", "", "dim", at=1)],
    [beat("一个物"), beat("它是“也”：白、也咸、也是立方体"), beat("物既是一，又是多：知觉陷入矛盾", 7.5, pulse=["thing"])], "Das Ding")
scene(169, "颠倒的世界", [
    B("up", 0.5, 0.3, "现象世界", 0.5, 0.11, "silver"),
    B("down", 0.5, 0.65, "超感官世界（颠倒）", 0.5, 0.11, "violet", at=1),
    A("a", "up", "down", "", "gold", at=2), A("b", "down", "up", "", "gold", at=2)],
    [beat("规律的静止王国"), beat("第二个超感官世界：甜的是酸的，黑的是白的"), beat("两个世界互相过渡：无限性", 7.5)], "verkehrte Welt")
scene(179, "自我意识是欲望", [
    N("me", 0.35, 0.45, "自我意识", "gold", 16), N("obj", 0.75, 0.45, "对象", "silver", 14),
    A("a", "me", "obj", "欲望", "gold", at=1)],
    [beat("我们进入了真理的故乡"), beat("自我意识通过否定对象来确证自己", set={"obj": {"r": 5}}),
     beat("欲望得到满足，又需要新的对象", 7.5, set={"obj": {"r": 14}})], "Begierde")
scene(191, "承认", [
    N("a", 0.3, 0.45, "自我意识 A", "silver", 15), N("b", 0.7, 0.45, "自我意识 B", "silver", 15),
    A("x", "a", "b", "承认", "gold", at=1), A("y", "b", "a", "承认", "gold", at=1)],
    [beat("自我意识只在另一个自我意识中得到满足"), beat("它们相互承认"), beat("自在自为地存在，是因为为对方而存在", 7.5, set={"a": {"color": "gold"}, "b": {"color": "gold"}})], "Anerkennen")
scene(200, "生死斗争", [
    N("a", 0.3, 0.45, "", "silver", 15), N("b", 0.7, 0.45, "", "silver", 15)],
    [beat("两个自我意识相遇", set={"a": {"x": 0.42}, "b": {"x": 0.58}}),
     beat("为了被承认，冒着生命危险进行斗争", set={"a": {"color": "red"}, "b": {"color": "red"}}),
     beat("一方退缩求生：成为奴隶；另一方成为主人", 7.5, set={"a": {"x": 0.3, "y": 0.3, "color": "gold", "label": "主人", "r": 20}, "b": {"x": 0.7, "y": 0.7, "color": "dim", "label": "奴隶", "r": 11}})],
    "Kampf auf Leben und Tod")
scene(209, "劳动陶冶", [
    N("lord", 0.25, 0.25, "主人", "gold", 18), N("slave", 0.4, 0.7, "奴隶", "silver", 11),
    N("thing", 0.75, 0.7, "物", "dim", 12),
    A("w", "slave", "thing", "劳动", "gold", at=1)],
    [beat("主人享受，奴隶劳动"), beat("奴隶在劳动中改造物，也陶冶了自己", set={"thing": {"color": "gold"}}),
     beat("主奴关系颠倒：奴隶获得了独立意识", 7.5, set={"lord": {"r": 10, "color": "dim"}, "slave": {"r": 20, "color": "gold"}})], "Das Formieren")
chain(212, "斯多葛 → 怀疑主义 → 苦恼意识", ["斯多葛", "怀疑主义", "苦恼意识"],
      ["斯多葛：在思想中自由，不管外在处境", "怀疑主义：否定一切", "苦恼意识：分裂为可变的我与不变的彼岸"], "Stoizismus · Skeptizismus",
      colors={2: "violet"})
scene(247, "理性是成为一切实在的确信", [
    N("me", 0.5, 0.5, "意识", "gold", 14),
    R("world", 0.5, 0.5, 110, "一切实在", "silver", at=1)],
    [beat("意识曾经与世界对立"), beat("理性：确信自己就是一切实在", set={"world": {"color": "gold"}}),
     beat("唯心主义这样说出理性的概念", 7.5, pulse=["me"])], "Gewißheit, alle Realität zu sein")
scene(453, "伦理世界：人法与神法", [
    B("human", 0.27, 0.4, "人的法：国家", 0.4, 0.11, "silver"), B("divine", 0.73, 0.4, "神的法：家庭", 0.4, 0.11, "violet"),
    N("ant", 0.5, 0.72, "安提戈涅", "gold", 13, at=1)],
    [beat("伦理世界分为两种法"), beat("安提戈涅埋葬兄长，触犯城邦禁令"), beat("两种正当的伦理力量发生冲突：悲剧", 7.5, pulse=["ant"])], "Antigone")
scene(675, "优美灵魂", [
    N("soul", 0.5, 0.45, "优美灵魂", "gold", 16),
    T("t", 0.5, 0.78, "害怕行动玷污内心的纯洁", "primary", 12, at=1)],
    [beat("良心退回到纯粹的内心"), beat("为了保持纯洁，拒绝行动"), beat("它渐渐消散，像一缕无形的雾", 7.5, set={"soul": {"opacity": 0.2, "r": 30}})], "schöne Seele")
scene(815, "绝对知识", [
    N("s", 0.5, 0.5, "精神", "gold", 16),
    R("r1", 0.5, 0.5, 40, "", "silver"), R("r2", 0.5, 0.5, 70, "", "silver", at=1), R("r3", 0.5, 0.5, 100, "", "silver", at=1),
    T("t", 0.5, 0.88, "在概念形式中认识自己的精神", "gold", 12, at=2)],
    [beat("精神走完了全部形态"), beat("意识、自我意识、理性、精神、宗教"), beat("绝对知识：精神知道自己就是精神", 7.5, pulse=["s"])], "das absolute Wissen")
scene(825, "精神的各各他", [
    N("p1", 0.15, 0.45, "", "silver", 8), N("p2", 0.32, 0.45, "", "silver", 8), N("p3", 0.5, 0.45, "", "silver", 8), N("p4", 0.68, 0.45, "", "silver", 8),
    N("ab", 0.86, 0.45, "绝对精神", "gold", 14, at=1),
    T("t", 0.5, 0.78, "历史 + 概念的科学 = 回忆与各各他", "primary", 12, at=2)],
    [beat("精神的历史：一个个形态的画廊"), beat("被回忆、被概念把握"), beat("构成绝对精神的回忆与骷髅地", 7.5, pulse=["ab"])], "Schädelstätte des absoluten Geistes")
save("hegel-phen-de")

# —— 《逻辑学》上卷 ——
anim.reset()
scene(138, "有：纯有", [
    N("s", 0.5, 0.45, "有", "silver", 22),
    T("t", 0.5, 0.75, "没有任何规定", "dim", 14, at=1)],
    [beat("纯粹的有"), beat("没有任何进一步的规定", set={"s": {"opacity": 0.5}}), beat("纯有，事实上就是无", 7.5, set={"s": {"color": "violet", "label": "有 = 无？"}})], "Seyn, reines Seyn")
scene(141, "有与无的真理：变", [
    N("s", 0.3, 0.45, "有", "silver", 16), N("n", 0.7, 0.45, "无", "violet", 16),
    A("a", "s", "n", "消逝", "gold", at=1), A("b", "n", "s", "生成", "gold", at=1),
    T("t", 0.5, 0.82, "变", "gold", 20, at=2)],
    [beat("纯有和纯无是同一的"), beat("真理是：一方直接消失于另一方"), beat("这个运动就是“变”", 7.5)], "Ihre Wahrheit ist also diese Bewegung")
scene(320, "坏的无限", [
    N("a", 0.15, 0.45, "有限", "silver", 10), N("b", 0.4, 0.45, "有限", "silver", 10, at=1), N("c", 0.65, 0.45, "有限", "silver", 10, at=1),
    T("d", 0.88, 0.45, "……", "dim", 18, at=2)],
    [beat("越过一个界限"), beat("又遇到新的界限"), beat("永无止境的重复：坏的无限", 7.5)], "schlechte Unendlichkeit")
scene(905, "量变到质变：度的关节线", [
    Bar("t", 0.5, 0.78, 0.1, "温度", 0.2, "blue"),
    T("q", 0.5, 0.3, "冰", "blue", 20)],
    [beat("温度一度一度地变化：量变", set={"t": {"h": 0.3}}), beat("到了关节点", set={"t": {"h": 0.4, "color": "gold"}, "q": {"label": "水"}}),
     beat("质突然改变：没有“自然界无飞跃”这回事", 7.5, set={"t": {"h": 0.55, "color": "red"}, "q": {"label": "汽"}})], "Knotenlinie")
scene(943, "本质是存在的真理", [
    N("sein", 0.5, 0.7, "存在", "silver", 16),
    N("wesen", 0.5, 0.3, "本质", "gold", 16, at=1),
    A("a", "sein", "wesen", "向内深入", "gold", at=1)],
    [beat("存在：直接的"), beat("知识深入到存在背后"), beat("存在的真理是本质", 7.5, pulse=["wesen"])], "Wesen")
scene(1027, "同一律", [
    T("a", 0.5, 0.4, "A = A", "primary", 24),
    T("t", 0.5, 0.7, "空洞的同语反复", "violet", 13, at=1)],
    [beat("同一律：A 就是 A"), beat("抽象的同一，什么也没说"), beat("真正的同一包含差异", 7.5, set={"a": {"color": "gold", "label": "A = A ≠ 抽象"}})], "Satz der Identität")
scene(1098, "矛盾是一切运动的根源", [
    N("p", 0.3, 0.45, "肯定", "silver", 14), N("n", 0.7, 0.45, "否定", "violet", 14),
    A("a", "p", "n", "", "gold", at=1), A("b", "n", "p", "", "gold", at=1),
    N("m", 0.5, 0.78, "运动 · 生命", "gold", 14, at=2)],
    [beat("对立面互相排斥"), beat("又互相包含：矛盾"), beat("某物只有包含矛盾，才会运动、才有生命", 7.5, pulse=["m"])], "Widerspruch")
save("hegel-logic-1-de")

# —— 《逻辑学》下卷：概念论 ——
anim.reset()
hub(31, "概念的三个环节", ["普遍", "特殊", "个别"], "概念",
    ["普遍性", "特殊性与个别性", "三者在概念中统一"], "Allgemeinheit · Besonderheit · Einzelnheit")
scene(131, "判断：概念的分化", [
    N("c", 0.5, 0.3, "概念", "gold", 16),
    N("s", 0.3, 0.7, "主词（个别）", "silver", 12, at=1), N("p", 0.7, 0.7, "谓词（普遍）", "silver", 12, at=1),
    A("a", "c", "s", "", "gold", at=1), A("b", "c", "p", "", "gold", at=1)],
    [beat("概念"), beat("把自己分为主词和谓词：判断"), beat("“个别就是普遍”", 7.5, set={"s": {"x": 0.38}, "p": {"x": 0.62}})], "Urtheil · Ur-Theilung")
chain(243, "推理：概念的恢复", ["个别", "特殊", "普遍"],
      ["判断把概念分开", "推理通过中项把它们重新联结", "一切事物都是推理"], "Schluß")
scene(497, "生命", [
    N("life", 0.5, 0.45, "生命", "gold", 18),
    P("body", 0.5, 0.45, 70, 30, "green", at=1),
    T("t", 0.5, 0.84, "个体 → 生命过程 → 类", "primary", 13, at=2)],
    [beat("理念最初的直接形态"), beat("灵魂贯穿于身体的每一部分"), beat("个体死去，类在延续", 7.5, pulse=["life"])], "Das Leben")
scene(544, "绝对理念", [
    N("idea", 0.5, 0.5, "绝对理念", "gold", 18),
    R("r", 0.5, 0.5, 100, "", "gold", at=1, dash=True),
    T("t", 0.5, 0.86, "唯一的对象和内容是它自身", "primary", 12, at=2)],
    [beat("概念与实在的统一"), beat("它以自身为对象"), beat("逻辑学的终点，又回到开端", 7.5, pulse=["idea"])], "absolute Idee")
chain(598, "方法：辩证的推进", ["开端", "否定", "否定之否定"],
      ["从直接的开端出发", "开端否定自身", "否定之否定：更丰富的新开端"], "Methode", colors={2: "gold"})
save("hegel-logic-2-de")
