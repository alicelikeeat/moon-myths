import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import anim
from anim import *

def book(tid, fn):
    anim.reset(); fn(); anim.save(tid)

# —— 柏拉图《理想国》（Jowett 英译） ——
def republic():
    scene(878, "古格斯的戒指", [
        N("man", 0.5, 0.5, "古格斯", "silver", 16),
        R("ring", 0.5, 0.5, 26, "隐身戒指", "gold", at=1),
        T("t", 0.5, 0.85, "如果没人看见，人还会正义吗？", "primary", 12, at=2)],
        [beat("牧羊人古格斯找到一枚戒指"), beat("转动它，就能隐身", set={"man": {"opacity": 0.15}}), beat("格劳孔：人行正义只是因为怕被看见", 7.5)], "Ring of Gyges")
    scene(2486, "哲学王", [
        N("ph", 0.3, 0.45, "哲学", "gold", 16), N("po", 0.7, 0.45, "权力", "silver", 16),
        T("t", 0.5, 0.82, "否则城邦的灾难不会停止", "violet", 12, at=2)],
        [beat("除非哲学家成为王"), beat("或者王真正学习哲学", set={"ph": {"x": 0.45}, "po": {"x": 0.55}}), beat("哲学与政治权力合二为一", 7.5, set={"po": {"color": "gold"}})], "Until philosophers are kings")
    scene(2951, "日喻", [
        N("sun", 0.5, 0.22, "太阳（善）", "gold", 20),
        N("eye", 0.25, 0.7, "眼睛（灵魂）", "silver", 12), N("obj", 0.75, 0.7, "可见物（理念）", "silver", 12),
        A("a", "sun", "obj", "光（真理）", "gold", at=1), A("b", "obj", "eye", "", "gold", at=2)],
        [beat("太阳不是视觉，却是视觉的来源"), beat("太阳给可见物以光"), beat("善的理念让灵魂认识理念", 7.5, pulse=["sun"])], "the child of the good")
    ladder(2976, "线喻", ["想象", "信念", "理智", "理性"],
           ["一条线分成不等的两段：可见世界与可知世界", "可见世界：影像与实物", "可知世界：数学推理与辩证法，越往上越清晰"], "divided line")
    scene(2996, "洞穴喻", [
        B("wall", 0.5, 0.25, "洞壁上的影子", 0.6, 0.1, "dim"),
        N("p", 0.5, 0.65, "囚徒", "silver", 12),
        N("fire", 0.85, 0.5, "火", "red", 10, at=1),
        N("sun", 0.85, 0.12, "太阳", "gold", 16, at=2)],
        [beat("囚徒从小被锁住，只能看见墙上的影子"), beat("挣脱后转身，看见火光和投影的器物", set={"p": {"x": 0.7, "y": 0.55}}),
         beat("走出洞穴，看见太阳：善的理念", 7.5, set={"p": {"x": 0.75, "y": 0.3, "color": "gold"}}, pulse=["sun"])], "Allegory of the Cave")
    scene(4433, "厄尔神话", [
        N("er", 0.5, 0.5, "厄尔", "silver", 14),
        N("up", 0.3, 0.2, "天上", "gold", 10, at=1), N("down", 0.7, 0.8, "地下", "violet", 10, at=1),
        T("t", 0.5, 0.88, "灵魂选择来生", "gold", 13, at=2)],
        [beat("战士厄尔死去，十二天后复活"), beat("他看到灵魂的赏罚"), beat("灵魂各自选择下一生：责任在选择者", 7.5, pulse=["er"])], "Myth of Er")
book("republic-en", republic)

# —— 《申辩篇》 ——
def apology():
    scene(34, "神谕：没有人比苏格拉底更智慧", [
        N("s", 0.5, 0.5, "苏格拉底", "silver", 14),
        N("o", 0.5, 0.18, "德尔斐神谕", "gold", 12),
        A("a", "o", "s", "最智慧", "gold", at=1)],
        [beat("凯勒丰去问神谕"), beat("神谕说：没有人比苏格拉底更智慧"), beat("苏格拉底不解，开始四处询问", 7.5, pulse=["s"])], "the oracle")
    versus(35, "自知无知", ["苏格拉底", "知道自己无知"], ["自以为知者", "不知却以为知"],
           "那些被认为有智慧的人", "其实并不知道，却以为自己知道", "我至少知道自己无知：这一点上更智慧", "I neither know nor think that I know")
    scene(85, "牛虻", [
        N("horse", 0.5, 0.55, "雅典（骏马）", "silver", 24),
        N("fly", 0.3, 0.3, "牛虻", "gold", 6, at=1)],
        [beat("雅典像一匹高大却迟钝的骏马"), beat("神派我来，像牛虻一样叮它", set={"fly": {"x": 0.55, "y": 0.4}}), beat("让它清醒", 7.5, pulse=["horse"])], "gadfly")
    scene(96, "未经省察的人生不值得过", [
        N("life", 0.5, 0.5, "人生", "silver", 18),
        R("ex", 0.5, 0.5, 60, "省察", "gold", at=1)],
        [beat("每天讨论德性"), beat("省察自己和他人"), beat("未经省察的人生不值得过", 7.5, set={"life": {"color": "gold"}}, pulse=["life"])], "The unexamined life is not worth living")
    scene(104, "我去死，你们去活", [
        N("s", 0.3, 0.5, "我：死", "dim", 14), N("j", 0.7, 0.5, "你们：生", "silver", 14),
        T("t", 0.5, 0.8, "哪个更好，只有神知道", "gold", 13, at=2)],
        [beat("离开的时候到了"), beat("我去死，你们去活", set={"s": {"x": 0.15}, "j": {"x": 0.85}}), beat("Which is better God only knows", 7.5)], "The hour of departure")
book("apology-en", apology)

# —— 笛卡尔 ——
def discourse():
    chain(37, "我思故我在", ["怀疑一切", "我在怀疑", "我思", "我在"],
          ["我决定把一切都当作假的", "但正在这样想的我，必须是某种东西", "我思，故我在：哲学的第一原理"], "I think, therefore I am")
book("discourse-en", discourse)
def meditationes():
    scene(40, "邪恶的精灵", [
        N("me", 0.5, 0.6, "我", "silver", 14),
        N("g", 0.5, 0.22, "恶魔", "violet", 18, at=1),
        P("world", 0.5, 0.6, 90, 30, "dim")],
        [beat("天、地、颜色、形状、声音"), beat("假设有个狡猾的恶魔在欺骗我"), beat("这一切可能都是幻觉", 7.5, set={"world": {"opacity": 0.2}})], "genium aliquem malignum")
    scene(44, "我是，我存在", [
        N("g", 0.5, 0.2, "恶魔", "violet", 14), N("me", 0.5, 0.6, "我", "gold", 16),
        A("a", "g", "me", "欺骗", "violet", at=1)],
        [beat("就算有恶魔在欺骗我"), beat("被欺骗的我，必定存在"), beat("ego sum, ego existo：只要我在思想", 7.5, pulse=["me"])], "ego sum, ego existo")
    scene(52, "蜡块", [
        N("wax", 0.5, 0.45, "蜡", "gold", 18),
        T("t", 0.5, 0.78, "颜色、气味、形状、硬度都变了", "primary", 12, at=1)],
        [beat("一块刚取出的蜂蜡"), beat("靠近火，它熔化", set={"wax": {"r": 28, "color": "violet"}}), beat("它仍是同一块蜡：靠心灵而非感官认识", 7.5, pulse=["wax"])], "cera")
book("meditationes-la", meditationes)

# —— 斯宾诺莎《伦理学》 ——
def ethics():
    scene(4, "实体的定义", [
        N("s", 0.5, 0.48, "实体", "gold", 20),
        R("r", 0.5, 0.48, 60, "在自身内、通过自身被认识", "gold", at=1)],
        [beat("什么是实体？"), beat("在自身之内，并通过自身而被认识"), beat("不需要借助别的概念", 7.5, pulse=["s"])], "By substance, I mean")
    scene(44, "神即自然", [
        N("god", 0.5, 0.48, "神 = 实体 = 自然", "gold", 22),
        P("modes", 0.5, 0.48, 110, 40, "silver", at=1)],
        [beat("只有一个实体"), beat("万物都是它的样式"), beat("神或自然", 7.5, pulse=["god"])], "God, or substance")
    scene(194, "观念的秩序与事物的秩序", [
        B("id", 0.27, 0.45, "观念的秩序", 0.38, 0.12, "silver"), B("th", 0.73, 0.45, "事物的秩序", 0.38, 0.12, "silver", at=1),
        T("t", 0.5, 0.75, "≡", "gold", 30, at=2)],
        [beat("思想属性下的观念"), beat("广延属性下的事物"), beat("二者的秩序与联系是同一的", 7.5)], "order and connection")
    scene(404, "努力保存自身", [
        N("t", 0.5, 0.5, "事物", "gold", 16),
        P("f", 0.5, 0.5, 70, 25, "violet", at=1)],
        [beat("每一个事物"), beat("面对外力"), beat("都努力保持自己的存在：这就是它的本质", 7.5, pulse=["t"])], "endeavours to persist")
    scene(1074, "一切高贵的事物都是稀少的", [
        N("peak", 0.5, 0.25, "至福", "gold", 14),
        N("me", 0.5, 0.8, "", "silver", 10)],
        [beat("得救之路看起来极其困难"), beat("但可以找到", set={"me": {"y": 0.5}}), beat("一切高贵的事物，既困难又稀少", 7.5, set={"me": {"y": 0.3, "color": "gold"}})], "excellent things are rare")
book("ethics-en", ethics)

# —— 休谟《人类理解研究》 ——
def enquiry():
    versus(28, "印象与观念", ["印象", "强烈、生动"], ["观念", "较弱的摹本"],
           "直接的知觉：印象", "回忆或想象：观念", "一切观念都摹写自印象", "less forcible and lively", win="left")
    versus(50, "休谟之叉", ["观念的关系", "数学：否定即矛盾"], ["实际的事情", "经验：反面也可设想"],
           "人类理性的一切对象分两类", "实际的事情，反面永远可能", "两种知识，各有来源", "Relations of Ideas · Matters of Fact", win="both")
    scene(94, "台球", [
        N("a", 0.2, 0.5, "", "silver", 12), N("b", 0.6, 0.5, "", "silver", 12),
        T("t", 0.5, 0.8, "看到的只是相继，看不到“力”", "gold", 12, at=2)],
        [beat("一个台球撞向另一个", set={"a": {"x": 0.5}}), beat("第二个球滚开", set={"b": {"x": 0.85}}), beat("因果的必然联系，经验里看不到", 7.5)], "billiard")
    chain(57, "习惯是人生的伟大指南", ["A 后 B", "又一次", "期待 B"],
          ["看到 A 后面跟着 B", "重复多次", "心灵习惯性地期待：这就是因果观念的来源"], "custom")
    scene(353, "付之一炬", [
        B("book", 0.5, 0.45, "一本书", 0.3, 0.14, "silver"),
        T("q", 0.5, 0.72, "有数量推理？有事实推理？", "primary", 12, at=1),
        N("fire", 0.5, 0.45, "", "red", 30, at=2)],
        [beat("拿起一本神学或形而上学的书"), beat("问：有关于数量的推理吗？有关于事实的经验推理吗？"), beat("都没有？那就投入火中", 7.5, set={"book": {"opacity": 0}})], "Commit it then to the flames")
book("enquiry-en", enquiry)

# —— 尼采《查拉图斯特拉》 ——
def zarathustra():
    scene(34, "上帝死了", [
        N("g", 0.5, 0.3, "上帝", "gold", 18),
        N("z", 0.5, 0.75, "查拉图斯特拉", "silver", 12)],
        [beat("查拉图斯特拉下山"), beat("林中老人还不知道", pulse=["g"]), beat("上帝已经死了", 7.5, set={"g": {"opacity": 0.1}})], "Gott ist todt")
    scene(37, "我教你们超人", [
        N("man", 0.35, 0.55, "人", "silver", 14), N("ub", 0.7, 0.3, "超人", "gold", 18, at=1),
        A("a", "man", "ub", "超越", "gold", at=1)],
        [beat("人是应当被超越的东西"), beat("我教你们超人"), beat("超人是大地的意义", 7.5, pulse=["ub"])], "Ich lehre euch den Übermenschen")
    chain(64, "人是一根绳索", ["动物", "人", "超人"],
          ["人是一根绳索", "系在动物与超人之间", "一根悬在深渊上的绳索：人的伟大在于他是桥梁"], "Der Mensch ist ein Seil")
    scene(101, "末人", [
        N("l", 0.5, 0.5, "末人", "dim", 12),
        T("t", 0.5, 0.78, "“我们发明了幸福”，他们眨眨眼", "primary", 12, at=1)],
        [beat("最可鄙的人"), beat("不再有渴望，不再有创造"), beat("人人都想要一样，人人都一样", 7.5, set={"l": {"r": 6}})], "die letzten Menschen")
    chain(171, "精神三变", ["骆驼", "狮子", "孩子"],
          ["骆驼：负重，“你应当”", "狮子：“我要”，夺取自由", "孩子：天真、遗忘、新的开始、神圣的肯定"], "Drei Verwandlungen")
    scene(1253, "权力意志", [
        N("w", 0.5, 0.5, "意志", "gold", 16),
        P("life", 0.5, 0.5, 90, 35, "violet", at=1)],
        [beat("凡有生命之处"), beat("就有意志"), beat("不是求生存的意志，而是权力意志", 7.5, pulse=["w"])], "Wille zur Macht")
    scene(2533, "永恒轮回", [
        R("ring", 0.5, 0.5, 90, "", "gold", dash=True),
        N("m", 0.5, 0.5 - 90 / 380, "此刻", "silver", 10)],
        [beat("一切都在回来"), beat("同样的生命，无数次", set={"m": {"x": 0.5 + 90 / 350, "y": 0.5}}), beat("你能对它说“再来一次”吗？", 7.5, set={"m": {"x": 0.5, "y": 0.5 + 90 / 380}}, pulse=["ring"])], "ewige Wiederkunft")
book("zarathustra-de", zarathustra)

# —— 亚里士多德 ——
def nico():
    balance(161, "德性是中道", "怯懦", "鲁莽", "情感与行为中有过度", "也有不及", "德性瞄准中间", "a mean state", mid="勇敢")
    scene(90, "一燕不成春", [
        N("b", 0.3, 0.4, "燕", "silver", 8),
        B("life", 0.5, 0.75, "完整的一生", 0.8, 0.03, "gold", at=1)],
        [beat("一只燕子、一个晴天"), beat("不能成为春天"), beat("一天的善不使人幸福：要贯穿一生", 7.5)], "one swallow")
    scene(457, "友爱", [
        N("a", 0.3, 0.45, "", "silver", 14), N("b", 0.7, 0.45, "", "silver", 14),
        A("x", "a", "b", "", "gold", at=1), A("y", "b", "a", "", "gold", at=1)],
        [beat("有用的友爱、快乐的友爱"), beat("因对方本身而爱"), beat("德性之间的友爱最持久", 7.5, set={"a": {"color": "gold"}, "b": {"color": "gold"}})], "Friendship")
book("ethics-aristotle-en", nico)

# —— 阿奎那 ——
def summa():
    hub(119, "五路", ["运动", "动力因", "偶然与必然", "完满等级", "目的"], "上帝",
        ["上帝的存在可以用五种方式证明", "五条路都从经验出发", "都推到同一个第一者"], "five ways")
    chain(120, "第一推动者", ["石", "杖", "手", "第一推动者"],
          ["凡运动者都被他物推动", "推动的链条不能无限回溯", "必有不被推动的第一推动者"], "first mover")
    chain(121, "第一因", ["结果", "中间因", "第一因"], ["动力因有其秩序", "不能无限回溯", "必有第一动力因"], "efficient cause")
    ladder(123, "完满的等级", ["较好", "更好", "最好", "至善"], ["事物有好坏、真假、高贵的等级", "越接近最高者越好", "必有最真、最好、最高贵者"], "gradation")
    scene(124, "世界的治理", [
        N("arrow", 0.2, 0.6, "箭", "silver", 8), N("target", 0.85, 0.35, "目标", "gold", 12),
        N("archer", 0.2, 0.25, "射手", "gold", 12, at=1)],
        [beat("无知的自然物也朝着目的运动", set={"arrow": {"x": 0.7, "y": 0.4}}), beat("就像箭被射手指向目标"), beat("必有智慧的存在者安排万物", 7.5, pulse=["archer"])], "governance of the world")
book("summa-en", summa)

# —— 莱布尼茨 ——
def monad():
    scene(366, "单子：单纯实体", [
        N("m", 0.5, 0.45, "单子", "gold", 16),
        P("c", 0.5, 0.45, 80, 30, "silver", at=1, label="")],
        [beat("单子是单纯的实体"), beat("复合物由单子组成"), beat("单纯：没有部分", 7.5, pulse=["m"])], "§1")
    scene(384, "单子没有窗户", [
        N("m", 0.5, 0.45, "单子", "gold", 18),
        N("x", 0.15, 0.45, "", "red", 6, at=1)],
        [beat("单子"), beat("外物能进入它吗？", set={"x": {"x": 0.38}}), beat("没有可供出入的窗户", 7.5, set={"x": {"x": 0.12}})], "§7")
    scene(414, "磨坊论证", [
        B("mill", 0.5, 0.45, "像磨坊一样大的机器", 0.6, 0.2, "silver"),
        T("t", 0.5, 0.78, "只看到零件互相推动，找不到知觉", "primary", 12, at=1)],
        [beat("设想一台会思想的机器"), beat("放大到磨坊那么大，走进去看"), beat("知觉不能用机械来解释", 7.5)], "§17 moulin")
    scene(504, "活的镜子", [
        N("m", 0.5, 0.5, "单子", "gold", 14),
        P("u", 0.5, 0.5, 100, 40, "silver", at=1)],
        [beat("每个单子"), beat("从自己的视点表象整个宇宙"), beat("宇宙永恒的活镜子", 7.5, pulse=["m"])], "§56 miroir vivant")
    scene(547, "前定和谐", [
        N("soul", 0.3, 0.45, "灵魂", "gold", 14), N("body", 0.7, 0.45, "身体", "silver", 14),
        R("h", 0.5, 0.45, 110, "前定和谐", "gold", at=2, dash=True)],
        [beat("灵魂遵循自己的法则"), beat("身体遵循自己的法则"), beat("它们像两只校准好的钟，彼此一致", 7.5)], "§78 harmonie préétablie")
book("monadologie-fr", monad)
