import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from anim import *

# 《逻辑哲学论》：主要命题与关键命题，每条一段动画
_ps = [p for s in json.load(open(os.path.join(ROOT, "texts", "tractatus-de.json"), encoding="utf-8"))["sections"] for p in s["paragraphs"]]
def P_(num):
    return next(i for i, p in enumerate(_ps) if p.split()[0] == num)

def S(num, title, els, beats, cap=None):
    scene(P_(num), f"{num} {title}", els, beats, cap)

S("1", "世界是一切发生的事情", [
    R("w", 0.5, 0.5, 110, "世界", "gold", dash=True),
    N("f1", 0.35, 0.4, "事实", "silver", 12, at=1), N("f2", 0.62, 0.38, "事实", "silver", 12, at=1),
    N("f3", 0.45, 0.65, "事实", "silver", 12, at=1), N("f4", 0.68, 0.62, "事实", "silver", 12, at=2)],
    [beat("世界"), beat("由发生的事情组成"), beat("一切发生的事情，就是世界", 7.5, pulse=["w"])],
    "Die Welt ist alles, was der Fall ist.")
S("1.1", "事实的总和，不是物的总和", [
    N("a", 0.3, 0.4, "物", "dim", 11), N("b", 0.55, 0.32, "物", "dim", 11), N("c", 0.7, 0.55, "物", "dim", 11), N("d", 0.38, 0.65, "物", "dim", 11),
    A("ab", "a", "b", "", "gold", at=1), A("cd", "c", "d", "", "gold", at=1),
    T("t", 0.5, 0.86, "世界 = Σ 事实 ≠ Σ 物", "gold", 13, at=2)],
    [beat("散放的物，还不是世界"), beat("物在关系中联结：成为事实", set={"a": {"color": "silver"}, "b": {"color": "silver"}, "c": {"color": "silver"}, "d": {"color": "silver"}}),
     beat("世界是事实的总和", 7.5)], "Gesamtheit der Tatsachen")
S("1.13", "逻辑空间中的事实", [
    B("space", 0.5, 0.48, "", 0.8, 0.55, "dim"),
    N("f1", 0.3, 0.4, "", "gold", 9, at=1), N("f2", 0.55, 0.55, "", "gold", 9, at=1), N("f3", 0.7, 0.35, "", "gold", 9, at=1),
    N("p1", 0.25, 0.6, "", "dim", 6, at=2), N("p2", 0.45, 0.32, "", "dim", 6, at=2), N("p3", 0.78, 0.6, "", "dim", 6, at=2)],
    [beat("逻辑空间：一切可能性"), beat("其中实际发生的事实，构成世界"), beat("没发生的可能性也在逻辑空间里", 7.5)],
    "Die Tatsachen im logischen Raum sind die Welt.")
S("1.2", "世界分解为事实", [
    R("w", 0.5, 0.48, 90, "世界", "gold"),
    N("a", 0.5, 0.48, "", "gold", 10, at=1),
    T("t", 0.5, 0.86, "每个事实可以单独成立或不成立，其余不变", "primary", 11, at=2)],
    [beat("一个世界"), beat("可以分解成一个个事实", set={"w": {"r": 30, "x": 0.25}, "a": {"x": 0.75}}),
     beat("事实彼此独立", 7.5, set={"a": {"opacity": 0.3}})], "Die Welt zerfällt in Tatsachen.")
S("2", "事实是事态的存在", [
    N("x", 0.3, 0.45, "对象", "silver", 12), N("y", 0.7, 0.45, "对象", "silver", 12),
    A("r", "x", "y", "事态", "gold", at=1),
    T("t", 0.5, 0.8, "事态存在 = 事实", "gold", 13, at=2)],
    [beat("两个对象"), beat("按一定方式结合：事态"), beat("事态存在，就是事实", 7.5, pulse=["x", "y"])], "Bestehen von Sachverhalten")
S("2.01", "事态是对象的结合", [
    N("a", 0.25, 0.5, "", "silver", 12), N("b", 0.5, 0.35, "", "silver", 12), N("c", 0.75, 0.5, "", "silver", 12),
    A("ab", "a", "b", "", "gold", at=1), A("bc", "b", "c", "", "gold", at=1),
    T("t", 0.5, 0.8, "像链条中的环节一样相互勾连", "primary", 12, at=2)],
    [beat("对象（物）"), beat("结合起来就是事态"), beat("对象在事态中像链环一样相扣", 7.5)], "Verbindung von Gegenständen")
S("2.012", "逻辑中没有偶然", [
    N("o", 0.5, 0.45, "对象", "gold", 14),
    R("pos", 0.5, 0.45, 70, "它能进入的一切事态", "silver", at=1, dash=True),
    T("t", 0.5, 0.85, "可能性已经写在物里面", "gold", 12, at=2)],
    [beat("一个对象"), beat("它能出现在哪些事态中，是预先决定的"), beat("逻辑里没有偶然", 7.5, pulse=["o"])], "In der Logik ist nichts zufällig")
S("2.1", "我们为事实制作图像", [
    N("f", 0.25, 0.45, "事实", "silver", 16),
    B("pic", 0.72, 0.45, "图像", 0.3, 0.16, "gold", at=1),
    A("a", "f", "pic", "描绘", "gold", at=1)],
    [beat("事实"), beat("我们为它制作图像"), beat("思想就是在做这件事", 7.5, pulse=["pic"])], "Wir machen uns Bilder der Tatsachen.")
S("2.12", "图像是现实的模型", [
    N("a", 0.2, 0.35, "", "silver", 10), N("b", 0.35, 0.6, "", "silver", 10), A("ab", "a", "b", "", "silver"),
    N("a2", 0.65, 0.35, "", "gold", 10, at=1), N("b2", 0.8, 0.6, "", "gold", 10, at=1), A("ab2", "a2", "b2", "", "gold", at=1)],
    [beat("现实中的结构"), beat("图像以同样的结构摆放元素"), beat("图像是现实的模型", 7.5)], "Das Bild ist ein Modell der Wirklichkeit.")
S("2.17", "图像与现实共有的形式", [
    B("pic", 0.27, 0.45, "图像", 0.3, 0.16, "gold"), B("real", 0.73, 0.45, "现实", 0.3, 0.16, "silver"),
    T("form", 0.5, 0.7, "描绘形式", "gold", 14, at=1),
    A("x", "pic", "real", "", "gold", at=1), A("y", "real", "pic", "", "dim", at=1)],
    [beat("图像和现实"), beat("要能描绘，必须共有一种形式"), beat("这种形式本身不能再被描绘", 7.5)], "Form der Abbildung")
S("2.21", "图像有真有假", [
    B("pic", 0.5, 0.3, "图像", 0.3, 0.14, "silver"),
    N("w1", 0.3, 0.68, "相符 → 真", "gold", 13, at=1), N("w2", 0.7, 0.68, "不符 → 假", "violet", 13, at=1)],
    [beat("一幅图像"), beat("与现实对照：符合或不符合"), beat("不看现实，无法知道图像真假", 7.5)], "wahr oder falsch")
S("3", "思想是事实的逻辑图像", [
    N("f", 0.25, 0.45, "事实", "silver", 14), N("g", 0.75, 0.45, "思想", "gold", 16, at=1),
    A("a", "f", "g", "逻辑图像", "gold", at=1)],
    [beat("事实"), beat("思想是它的逻辑图像"), beat("能思想的，就是可能的", 7.5, pulse=["g"])], "Das logische Bild der Tatsachen ist der Gedanke.")
S("3.1", "命题让思想可感知", [
    N("g", 0.3, 0.45, "思想", "gold", 14),
    B("s", 0.72, 0.45, "命题（声音 / 文字）", 0.38, 0.12, "silver", at=1),
    A("a", "g", "s", "表达", "gold", at=1)],
    [beat("思想"), beat("在命题中以感官可见的方式表达出来"), beat("命题是思想的外衣", 7.5)], "sinnlich wahrnehmbar")
S("3.144", "名字像点，命题像箭头", [
    N("a", 0.25, 0.4, "名字", "silver", 8), N("b", 0.75, 0.4, "名字", "silver", 8),
    A("s", "a", "b", "命题：有方向，有意义", "gold", at=1)],
    [beat("名字像一个点：只命名对象"), beat("命题像箭头：说出事物如何"), beat("事态只能描述，不能命名", 7.5)], "Namen gleichen Punkten, Sätze Pfeilen")
S("3.203", "名字指称对象", [
    T("name", 0.3, 0.45, "„A“", "gold", 22), N("obj", 0.72, 0.45, "对象", "silver", 16, at=1),
    A("a", "name", "obj", "意义", "gold", at=1)],
    [beat("一个名字"), beat("它的意义就是它所指的对象"), beat("对象是名字的意义", 7.5)], "Der Gegenstand ist seine Bedeutung.")
S("3.3", "只有命题有意义", [
    T("n", 0.3, 0.4, "苏格拉底", "dim", 15),
    B("s", 0.5, 0.62, "苏格拉底是哲学家", 0.6, 0.12, "gold", at=1)],
    [beat("孤立的名字"), beat("只有在命题中，名字才有所指", set={"n": {"x": 0.5, "y": 0.45, "color": "gold"}}), beat("意义的最小单位是命题", 7.5)],
    "Nur der Satz hat Sinn")
S("4", "思想是有意义的命题", [
    N("g", 0.3, 0.45, "思想", "gold", 15), N("s", 0.7, 0.45, "有意义的命题", "gold", 15, at=1),
    A("eq", "g", "s", "=", "gold", at=2)],
    [beat("思想"), beat("有意义的命题"), beat("两者是同一回事", 7.5)], "Der Gedanke ist der sinnvolle Satz.")
S("4.01", "命题是现实的图像", [
    B("s", 0.27, 0.45, "命题", 0.28, 0.14, "gold"), B("w", 0.73, 0.45, "现实", 0.28, 0.14, "silver"),
    A("a", "s", "w", "模型", "gold", at=1)],
    [beat("命题"), beat("是我们所设想的现实的模型"), beat("就像法庭上用玩偶还原车祸", 7.5)], "Der Satz ist ein Bild der Wirklichkeit.")
S("4.022", "命题显示它的意义", [
    B("s", 0.5, 0.35, "命题", 0.3, 0.12, "silver"),
    T("show", 0.3, 0.6, "显示：如果为真会怎样", "gold", 12, at=1), T("say", 0.7, 0.6, "说出：事情就是如此", "primary", 12, at=2)],
    [beat("一个命题"), beat("它显示：如果它为真，事情是怎样"), beat("并且说：事情就是这样", 7.5)], "Der Satz zeigt seinen Sinn.")
S("4.11", "真命题的总和是自然科学", [
    N("t1", 0.25, 0.35, "真", "gold", 9), N("t2", 0.45, 0.3, "真", "gold", 9), N("t3", 0.7, 0.35, "真", "gold", 9),
    N("t4", 0.35, 0.55, "真", "gold", 9, at=1), N("t5", 0.6, 0.55, "真", "gold", 9, at=1),
    R("sci", 0.5, 0.45, 110, "全部自然科学", "silver", at=2)],
    [beat("一个个真命题"), beat("越来越多"), beat("它们的总和就是全部自然科学", 7.5)], "die gesamte Naturwissenschaft")
S("4.112", "哲学是活动，不是学说", [
    P("fog", 0.5, 0.45, 90, 45, "dim", label="模糊的思想"),
    T("t", 0.5, 0.85, "哲学的成果不是哲学命题，而是命题的澄清", "gold", 11, at=2)],
    [beat("思想常常模糊不清"), beat("哲学的任务：逻辑澄清", set={"fog": {"r": 30, "color": "gold"}}), beat("哲学是一种活动", 7.5)],
    "keine Lehre, sondern eine Tätigkeit")
S("4.116", "能想的都能想清楚", [
    P("fog", 0.5, 0.45, 80, 35, "dim"),
    T("t", 0.5, 0.82, "能说的，都能说清楚", "gold", 13, at=2)],
    [beat("能被思考的一切"), beat("都可以被清楚地思考", set={"fog": {"r": 20, "color": "gold"}}), beat("清楚与否只是表达的问题", 7.5)],
    "kann klar gedacht werden")
S("4.1212", "能显示的，不能说出", [
    B("s", 0.5, 0.35, "命题", 0.3, 0.12, "silver"),
    R("form", 0.5, 0.35, 60, "逻辑形式", "gold", at=1, dash=True),
    T("t", 0.5, 0.75, "形式在命题中映现，却不能被命题说出", "primary", 11, at=2)],
    [beat("一个命题"), beat("它的逻辑形式在它身上显示出来"), beat("显示的东西，不能被说出", 7.5)], "Zeigen, nicht sagen")
S("4.46", "重言式与矛盾式", [
    Bar("t", 0.3, 0.75, 0.5, "重言式：总是真", 0.14, "gold"), Bar("c", 0.7, 0.75, 0.01, "矛盾式：总是假", 0.14, "violet", at=1),
    T("x", 0.5, 0.88, "两者都不描绘现实", "primary", 12, at=2)],
    [beat("在所有可能情况下都真"), beat("在所有可能情况下都假"), beat("它们没有说出世界的任何事情", 7.5)], "Tautologie · Kontradiktion")
S("5", "命题是基本命题的真值函数", [
    N("p", 0.25, 0.3, "p", "silver", 12), N("q", 0.5, 0.3, "q", "silver", 12), N("r", 0.75, 0.3, "r", "silver", 12),
    N("f", 0.5, 0.68, "f(p, q, r)", "gold", 16, at=1),
    A("a", "p", "f", "", "gold", at=1), A("b", "q", "f", "", "gold", at=1), A("c", "r", "f", "", "gold", at=1)],
    [beat("基本命题"), beat("复合命题的真假，只取决于它们的真假"), beat("一切命题都是真值函数", 7.5)], "Wahrheitsfunktion der Elementarsätze")
S("5.1361", "因果信念是迷信", [
    N("now", 0.3, 0.45, "现在", "silver", 14), N("fut", 0.72, 0.45, "将来", "dim", 14),
    A("a", "now", "fut", "推出？", "red", at=1, dash=True)],
    [beat("现在的事件"), beat("能逻辑地推出将来吗？"), beat("不能。相信因果关系就是迷信", 7.5, set={"fut": {"opacity": 0.3}})], "Kausalnexus — Aberglaube")
S("5.6", "语言的界限", [
    R("lang", 0.5, 0.48, 70, "我的语言", "gold"),
    R("world", 0.5, 0.48, 70, "", "silver", at=1, dash=True)],
    [beat("我的语言有一个界限"), beat("我的世界也有界限", set={"lang": {"r": 100, "label": "语言的界限 = 世界的界限"}, "world": {"r": 100}}), beat("两条界限重合", 7.5, pulse=["lang"])],
    "Grenzen der Sprache = Grenzen der Welt")
S("5.61", "逻辑充满世界", [
    R("w", 0.5, 0.48, 100, "世界 = 逻辑的界限", "gold"),
    T("t", 0.5, 0.48, "这里有这个，没有那个？", "primary", 12, at=1),
    T("out", 0.5, 0.88, "不能想的，也就不能说", "violet", 12, at=2)],
    [beat("逻辑充满世界"), beat("我们不能在逻辑中排除某些可能"), beat("否则就得站在界限外面", 7.5)], "Die Logik erfüllt die Welt")
S("5.63", "我是我的世界", [
    N("me", 0.5, 0.48, "我", "gold", 16),
    R("w", 0.5, 0.48, 100, "我的世界", "gold", at=1)],
    [beat("我"), beat("我的世界", set={"me": {"r": 100, "opacity": 0.25}}), beat("我就是我的世界（小宇宙）", 7.5)], "Ich bin meine Welt.")
S("5.632", "主体是世界的界限", [
    R("w", 0.5, 0.5, 90, "世界", "silver"),
    N("eye", 0.5, 0.5, "主体？", "dim", 12),
    N("edge", 0.5, 0.5 + 90 / 380, "主体", "gold", 12, at=1)],
    [beat("主体在世界里面吗？"), beat("它不属于世界", set={"eye": {"opacity": 0}}), beat("它是世界的界限", 7.5, pulse=["edge"])], "eine Grenze der Welt")
S("5.633", "眼睛看不见自己", [
    N("eye", 0.15, 0.5, "眼睛", "gold", 14),
    R("field", 0.6, 0.5, 100, "视野", "silver", at=1),
    T("t", 0.6, 0.5, "视野中没有眼睛", "primary", 12, at=2)],
    [beat("一只眼睛"), beat("看到整个视野"), beat("视野里却找不到这只眼睛", 7.5)], "wie mit Auge und Gesichtsfeld")
S("6", "命题的一般形式", [
    T("f", 0.5, 0.4, "[p̄, ξ̄, N(ξ̄)]", "gold", 20),
    T("r", 0.5, 0.6, "从基本命题出发，反复否定", "primary", 12, at=1),
    T("t", 0.5, 0.75, "就能得到一切命题", "gold", 13, at=2)],
    [beat("一切命题的共同形式"), beat("N：对一组命题全部否定"), beat("反复运用，生成所有命题", 7.5)], "die allgemeine Form des Satzes")
S("6.1", "逻辑命题是重言式", [
    T("t", 0.5, 0.4, "p ∨ ∼p", "gold", 22),
    T("r", 0.5, 0.62, "下雨或不下雨", "primary", 13, at=1),
    T("n", 0.5, 0.75, "永远为真，却什么也没说", "violet", 12, at=2)],
    [beat("逻辑命题"), beat("在任何情况下都为真"), beat("它们说的是“无”", 7.5)], "Die Sätze der Logik sind Tautologien.")
S("6.13", "逻辑是世界的镜像", [
    B("w", 0.3, 0.45, "世界", 0.3, 0.2, "silver"), B("m", 0.7, 0.45, "逻辑", 0.3, 0.2, "gold", at=1),
    T("t", 0.5, 0.8, "逻辑不是学说，而是先验的", "gold", 12, at=2)],
    [beat("世界"), beat("逻辑像镜子一样映出它的形式"), beat("逻辑是先验的", 7.5)], "ein Spiegelbild der Welt")
S("6.371", "自然规律并不解释现象", [
    P("ph", 0.5, 0.45, 80, 35, "silver", label="现象"),
    B("law", 0.5, 0.2, "自然规律", 0.3, 0.09, "gold", at=1),
    T("t", 0.5, 0.86, "像古人停在神和命运面前一样", "primary", 11, at=2)],
    [beat("现象"), beat("人们以为自然规律解释了它们"), beat("规律只是描述，解释在其外", 7.5, set={"law": {"opacity": 0.4}})], "die Täuschung")
S("6.41", "世界的意义在世界之外", [
    R("w", 0.5, 0.5, 80, "世界：一切如其所是", "silver"),
    N("sense", 0.88, 0.2, "意义", "gold", 14, at=1)],
    [beat("在世界中，一切都如其所是"), beat("意义不在世界里"), beat("世界的意义必须在世界之外", 7.5, pulse=["sense"])], "Der Sinn der Welt muss außerhalb ihrer liegen.")
S("6.421", "伦理不可说", [
    R("say", 0.5, 0.5, 80, "可说的", "silver"),
    T("e", 0.85, 0.2, "伦理", "gold", 14, at=1), T("a", 0.15, 0.2, "美", "gold", 14, at=1),
    T("t", 0.5, 0.88, "伦理与美学是一回事", "gold", 12, at=2)],
    [beat("能说出的东西"), beat("伦理不在其中"), beat("伦理是先验的", 7.5)], "Ethik und Ästhetik sind Eins.")
S("6.44", "神秘的是世界存在", [
    R("w", 0.5, 0.5, 70, "", "silver"),
    T("how", 0.5, 0.5, "世界怎样", "primary", 13, at=1),
    T("that", 0.5, 0.85, "世界存在：这才是神秘的", "gold", 14, at=2)],
    [beat("世界"), beat("世界是怎样的：科学去回答"), beat("世界竟然存在", 7.5, set={"w": {"r": 110, "color": "gold"}, "how": {"opacity": 0.3}})], "dass sie ist")
S("6.5", "谜不存在", [
    T("q", 0.5, 0.4, "？", "violet", 40),
    T("t", 0.5, 0.75, "如果问题能提出，它就能被回答", "primary", 12, at=1)],
    [beat("不能说出的回答"), beat("对应的问题也说不出"), beat("谜并不存在", 7.5, set={"q": {"opacity": 0}})], "Das Rätsel gibt es nicht.")
S("6.52", "科学回答完了，人生问题仍未触及", [
    Bar("s", 0.35, 0.75, 0.5, "科学问题：全部回答", 0.16, "silver"),
    Bar("l", 0.7, 0.75, 0.5, "人生问题", 0.16, "gold", at=1)],
    [beat("假设所有科学问题都回答了"), beat("人生问题仍然完全没有触及"), beat("而这时也就没有问题了：这就是答案", 7.5, set={"l": {"h": 0.01}})], "unsere Lebensprobleme")
S("6.521", "问题消失就是解决", [
    N("p", 0.5, 0.45, "人生的问题", "violet", 26),
    T("t", 0.5, 0.82, "问题的消失就是它的解决", "gold", 13, at=2)],
    [beat("人生的问题"), beat("不是被回答", set={"p": {"r": 14}}), beat("而是消失", 7.5, set={"p": {"r": 2, "opacity": 0.1}})], "am Verschwinden dieses Problems")
S("6.54", "扔掉梯子", [
    Bar("l1", 0.5, 0.85, 0.15, "", 0.25, "silver"), Bar("l2", 0.5, 0.7, 0.15, "", 0.25, "silver", at=1),
    N("me", 0.5, 0.25, "读者", "gold", 13, at=2)],
    [beat("我的命题像梯子的一级级"), beat("借着它们向上爬"), beat("爬上去之后，就要把梯子扔掉", 7.5, set={"l1": {"opacity": 0}, "l2": {"opacity": 0}})],
    "Er muss sozusagen die Leiter wegwerfen")
S("7", "必须保持沉默", [
    R("lang", 0.5, 0.48, 90, "可说的", "gold"),
    T("out", 0.5, 0.86, "不可说的", "violet", 14, at=1)],
    [beat("能说的，都已说清"), beat("对不可说的"), beat("必须保持沉默", 8, set={"lang": {"opacity": 0.15}})],
    "darüber muss man schweigen")

save("tractatus-de")
