import SwiftUI

// MARK: - 人物名字的四种语言：中文、English、Français、Deutsch
// 写法取各语言通行的称呼（如 Konfuzius、Lao-tseu、Thomas d'Aquin）。

enum NameLang: String, CaseIterable, Identifiable {
    case zh, en, fr, de
    var id: String { rawValue }
    var title: String { ["中文", "English", "Français", "Deutsch"][Self.allCases.firstIndex(of: self)!] }
    static var current: NameLang { NameLang(rawValue: UserDefaults.standard.string(forKey: "nameLang") ?? "zh") ?? .zh }
}

/// id → (English, Français, Deutsch)
let foreignNames: [String: (String, String, String)] = [
    "laozi": ("Laozi", "Lao-tseu", "Laozi"),
    "kongzi": ("Confucius", "Confucius", "Konfuzius"),
    "mozi": ("Mozi", "Mozi", "Mozi"),
    "mengzi": ("Mencius", "Mencius", "Menzius"),
    "zhuangzi": ("Zhuangzi", "Tchouang-tseu", "Zhuangzi"),
    "xunzi": ("Xunzi", "Xunzi", "Xunzi"),
    "hanfei": ("Han Fei", "Han Fei", "Han Fei"),
    "dongzhongshu": ("Dong Zhongshu", "Dong Zhongshu", "Dong Zhongshu"),
    "huineng": ("Huineng", "Huineng", "Huineng"),
    "zhuxi": ("Zhu Xi", "Zhu Xi", "Zhu Xi"),
    "wangyangming": ("Wang Yangming", "Wang Yangming", "Wang Yangming"),
    "wangfuzhi": ("Wang Fuzhi", "Wang Fuzhi", "Wang Fuzhi"),
    "zhouyi": ("I Ching", "Yi Jing", "I Ging"),
    "guanzhong": ("Guan Zhong", "Guan Zhong", "Guan Zhong"),
    "sunwu": ("Sun Tzu", "Sun Tzu", "Sunzi"),
    "zisi": ("Zisi", "Zisi", "Zisi"),
    "liezi": ("Liezi", "Lie-tseu", "Liezi"),
    "gongsunlong": ("Gongsun Long", "Gongsun Long", "Gongsun Long"),
    "wangchong": ("Wang Chong", "Wang Chong", "Wang Chong"),
    "zhoudunyi": ("Zhou Dunyi", "Zhou Dunyi", "Zhou Dunyi"),
    "zhangzai": ("Zhang Zai", "Zhang Zai", "Zhang Zai"),
    "ercheng": ("Cheng Brothers", "Frères Cheng", "Brüder Cheng"),
    "luxiangshan": ("Lu Jiuyuan", "Lu Jiuyuan", "Lu Jiuyuan"),
    "guyanwu": ("Gu Yanwu", "Gu Yanwu", "Gu Yanwu"),
    "socrates": ("Socrates", "Socrate", "Sokrates"),
    "plato": ("Plato", "Platon", "Platon"),
    "aristotle": ("Aristotle", "Aristote", "Aristoteles"),
    "lucretius": ("Lucretius", "Lucrèce", "Lukrez"),
    "epictetus": ("Epictetus", "Épictète", "Epiktet"),
    "marcusaurelius": ("Marcus Aurelius", "Marc Aurèle", "Mark Aurel"),
    "augustine": ("Augustine", "Augustin", "Augustinus"),
    "aquinas": ("Thomas Aquinas", "Thomas d'Aquin", "Thomas von Aquin"),
    "machiavelli": ("Machiavelli", "Machiavel", "Machiavelli"),
    "hobbes": ("Hobbes", "Hobbes", "Hobbes"),
    "descartes": ("Descartes", "Descartes", "Descartes"),
    "pascal": ("Pascal", "Pascal", "Pascal"),
    "spinoza": ("Spinoza", "Spinoza", "Spinoza"),
    "locke": ("Locke", "Locke", "Locke"),
    "leibniz": ("Leibniz", "Leibniz", "Leibniz"),
    "berkeley": ("Berkeley", "Berkeley", "Berkeley"),
    "hume": ("Hume", "Hume", "Hume"),
    "rousseau": ("Rousseau", "Rousseau", "Rousseau"),
    "kant": ("Kant", "Kant", "Kant"),
    "hegel": ("Hegel", "Hegel", "Hegel"),
    "schopenhauer": ("Schopenhauer", "Schopenhauer", "Schopenhauer"),
    "kierkegaard": ("Kierkegaard", "Kierkegaard", "Kierkegaard"),
    "mill": ("J. S. Mill", "J. S. Mill", "J. S. Mill"),
    "marx": ("Marx", "Marx", "Marx"),
    "nietzsche": ("Nietzsche", "Nietzsche", "Nietzsche"),
    "james": ("William James", "William James", "William James"),
    "russell": ("Russell", "Russell", "Russell"),
    "wittgenstein": ("Wittgenstein", "Wittgenstein", "Wittgenstein"),
    "heidegger": ("Heidegger", "Heidegger", "Heidegger"),
    "sartre": ("Sartre", "Sartre", "Sartre"),
    "camus": ("Camus", "Camus", "Camus"),
    "euclid": ("Euclid", "Euclide", "Euklid"),
    "liuhui": ("Liu Hui", "Liu Hui", "Liu Hui"),
    "archimedes": ("Archimedes", "Archimède", "Archimedes"),
    "zhaoshuang": ("Zhao Shuang", "Zhao Shuang", "Zhao Shuang"),
    "newton": ("Newton", "Newton", "Newton"),
    "descartes-geometry": ("Descartes (math.)", "Descartes (math.)", "Descartes (Math.)"),
    "pythagoras": ("Pythagoras", "Pythagore", "Pythagoras"),
    "apollonius": ("Apollonius", "Apollonius", "Apollonios"),
    "diophantus": ("Diophantus", "Diophante", "Diophantos"),
    "zuchongzhi": ("Zu Chongzhi", "Zu Chongzhi", "Zu Chongzhi"),
    "alkhwarizmi": ("al-Khwarizmi", "al-Khwârizmî", "al-Chwarizmi"),
    "fibonacci": ("Fibonacci", "Fibonacci", "Fibonacci"),
    "liye": ("Li Ye", "Li Ye", "Li Ye"),
    "qinjiushao": ("Qin Jiushao", "Qin Jiushao", "Qin Jiushao"),
    "yanghui": ("Yang Hui", "Yang Hui", "Yang Hui"),
    "zhushijie": ("Zhu Shijie", "Zhu Shijie", "Zhu Shijie"),
    "xuguangqi": ("Xu Guangqi", "Xu Guangqi", "Xu Guangqi"),
    "fermat": ("Fermat", "Fermat", "Fermat"),
    "meiwending": ("Mei Wending", "Mei Wending", "Mei Wending"),
    "euler": ("Euler", "Euler", "Euler"),
    "gauss": ("Gauss", "Gauss", "Gauß"),
    "boole": ("Boole", "Boole", "Boole"),
    "riemann": ("Riemann", "Riemann", "Riemann"),
    "dedekind": ("Dedekind", "Dedekind", "Dedekind"),
    "cantor": ("Cantor", "Cantor", "Cantor"),
    "hilbert": ("Hilbert", "Hilbert", "Hilbert"),
    "godel": ("Gödel", "Gödel", "Gödel"),
]

/// 当前语言下的全名（中文时为原有全名）
func fullName(_ t: Thinker) -> String {
    let lang = NameLang.current
    guard lang != .zh, let f = foreignNames[t.id] else { return t.name }
    switch lang {
    case .en: return f.0
    case .fr: return f.1
    case .de: return f.2
    case .zh: return t.name
    }
}

/// 名字去掉括号注释（中文）；其他语言用通行称呼
func shortName(_ t: Thinker) -> String {
    NameLang.current == .zh ? String(t.name.split(separator: "（").first ?? Substring(t.name)) : fullName(t)
}
