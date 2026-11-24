import SwiftUI

enum ChapterBody {
    case canvas(Draw)
    case interactive(AnyView)
}

struct Chapter {
    let part: String
    let title: String
    let thesis: String
    let formula: String
    let points: [String]
    let body: ChapterBody
}

let bookParts = ["序言与导论", "先验感性论", "概念分析论", "原理分析论", "先验辩证论", "先验方法论"]

let chapters: [Chapter] = [
    Chapter(part: "序言与导论", title: "序言：哥白尼式革命",
            thesis: "不是认识符合对象，而是对象（作为现象）符合认识的先天形式。",
            formula: "认识 → 对象   ⟹   对象 → 认识",
            points: ["形而上学至今在“摸索”，没有走上科学的可靠道路。",
                     "数学和物理学的成功来自：理性只认识它按自己的筹划放进对象里的东西。",
                     "代价：我们只能认识现象，不能认识物自体。"],
            body: .canvas(drawCopernicus)),
    Chapter(part: "序言与导论", title: "导论：先天综合判断",
            thesis: "全书的问题：既扩展知识、又必然普遍的判断如何可能？",
            formula: "{ J : Synthetic(J) ∧ A priori(J) } ≠ ∅ ?",
            points: ["分析判断：谓词已包含在主词概念中，只解释不扩展。",
                     "综合判断：谓词在主词之外，需要“第三者”把它们连起来。",
                     "数学、纯粹自然科学都含有先天综合判断；形而上学至少想要它。"],
            body: .canvas(drawJudgments)),
    Chapter(part: "先验感性论", title: "空间",
            thesis: "空间是外感官的先天形式，是直观而非概念。",
            formula: "σ: X → S × T ,  S ≅ ℝ³",
            points: ["可以设想没有物体的空间，不能设想没有空间的物体。",
                     "只有一个空间，各部分空间是对它的限制，而不是它的组成成分。",
                     "经验上实在，先验上观念：对一切现象有效，对物自体无意义。"],
            body: .canvas(drawSpace)),
    Chapter(part: "先验感性论", title: "时间",
            thesis: "时间是内感官的形式，因而间接是一切现象的形式。",
            formula: "T ≅ ℝ ， 一切表象 r 都有 t(r)",
            points: ["同时与相继只能以时间为前提才被表象。",
                     "时间只有一维：不同的时间不是同时的，而是相继的。",
                     "算术在时间直观中逐次加一，几何在空间直观中构造。"],
            body: .canvas(drawTime)),
    Chapter(part: "概念分析论", title: "先验逻辑：直观与概念",
            thesis: "思维无内容则空，直观无概念则盲。",
            formula: "K = κ ∘ σ",
            points: ["感性是接受性，知性是自发性。",
                     "二者缺一不可，也不能互换职能。",
                     "先验逻辑研究的是：概念如何先天地关联到对象。"],
            body: .interactive(AnyView(PipelineView()))),
    Chapter(part: "概念分析论", title: "形而上学演绎：范畴的线索",
            thesis: "判断的 12 种逻辑功能，用于直观的杂多，就是 12 个范畴。",
            formula: "判断表  ≅  范畴表  (4 × 3)",
            points: ["知性就是判断的能力。",
                     "每组第三项是前两项的综合：全体性 = 复多性被视为单一性。",
                     "量、质是“数学性的”，关系、模态是“力学性的”。"],
            body: .canvas(drawMetaphysicalDeduction)),
    Chapter(part: "概念分析论", title: "先验演绎",
            thesis: "统觉的综合统一保证了范畴对一切经验对象客观有效。",
            formula: "∀r: ◇(我思 ⊢ r)  ⟹  对象 ⊆ 范畴的像",
            points: ["问题是“权利问题”：主观概念凭什么对对象有效？",
                     "“我思”必须能够伴随我的一切表象。",
                     "对象本身就是在范畴之下被统一的杂多，所以范畴必然有效。"],
            body: .canvas(drawDeduction)),
    Chapter(part: "原理分析论", title: "图型法",
            thesis: "范畴通过“先验时间规定”才能应用于现象。",
            formula: "图型 : 范畴 → 时间中的规则",
            points: ["范畴与直观异质，需要一个第三者作中介。",
                     "这个中介一方面是理智的，一方面是感性的：时间。",
                     "点选范畴，看它在时间轴上的样子。"],
            body: .interactive(AnyView(CategoriesView()))),
    Chapter(part: "原理分析论", title: "直观的公理",
            thesis: "一切直观都是广延量。",
            formula: "整体 = Σ 部分（部分先于整体）",
            points: ["直线只能一段一段地画出来才能被表象。",
                     "这保证了几何学可以精确应用于经验对象。"],
            body: .canvas(drawAxioms)),
    Chapter(part: "原理分析论", title: "知觉的预测",
            thesis: "在一切现象中，实在都有强度量，即度。",
            formula: "f(t) ∈ [0, ∞) ，连续",
            points: ["感觉没有广延，却有程度（光的亮度、热的强度）。",
                     "从 0 到任一度之间有无限多中间度：实在是连续的。",
                     "这是对“感觉”唯一能先天知道的东西。"],
            body: .canvas(drawAnticipations)),
    Chapter(part: "原理分析论", title: "经验的类比",
            thesis: "经验只有通过对知觉的必然联结的表象才可能。",
            formula: "dQ/dt = 0 ;  ∀Δ ∃c: c ≺ Δ ;  A(t) ↔ B(t)",
            points: ["第一类比：实体在一切变化中持存，其量不增不减。",
                     "第二类比：一切变化都按因果律发生（客观相继不可逆）。",
                     "第三类比：同时存在的实体处于交互作用中。"],
            body: .canvas(drawAnalogies)),
    Chapter(part: "原理分析论", title: "公设与驳斥唯心论",
            thesis: "我对自身此在的意识，同时就证明了外物的存在。",
            formula: "内在时间规定  ⟹  外部持久之物",
            points: ["可能、现实、必然只表达对象与认识能力的关系。",
                     "我的表象在时间中的位置，需要一个持久之物作参照。",
                     "这个持久之物不能是我的表象本身，只能是外物。"],
            body: .canvas(drawRefutation)),
    Chapter(part: "原理分析论", title: "现象与本体",
            thesis: "范畴只有经验性的使用；本体只能作为限制概念。",
            formula: "可知 = Im(κ∘σ)  ⊊  可思",
            points: ["消极意义的本体：不是感性直观对象的东西，合法。",
                     "积极意义的本体：理智直观的对象，我们没有理智直观。",
                     "点选命题，看它落在哪个圈里。"],
            body: .interactive(AnyView(BoundaryView()))),
    Chapter(part: "原理分析论", title: "反思概念的歧义",
            thesis: "混淆纯粹知性对象与现象，就会犯莱布尼茨的错误。",
            formula: "C(a) = C(b)  ⇏  a = b （若位置不同）",
            points: ["同一与差异、一致与对立、内与外、质料与形式。",
                     "两滴水概念完全相同，但空间位置不同，就是两个。",
                     "莱布尼茨把现象理智化，洛克把概念感性化。"],
            body: .canvas(drawAmphiboly)),
    Chapter(part: "先验辩证论", title: "先验幻相",
            thesis: "理性超越经验界限时，会产生一种自然而不可避免的幻相。",
            formula: "“可无限追溯” ⟹̸ “极限已存在”",
            points: ["像地平线上的月亮：知道是错觉，错觉也不消失。",
                     "批判只能揭露它，防止被它欺骗，却不能让它消失。"],
            body: .canvas(drawIllusion)),
    Chapter(part: "先验辩证论", title: "纯粹理性的概念：理念",
            thesis: "理性要求有条件者的条件的全体，即无条件者。",
            formula: "c₀ ← c₁ ← c₂ ← … ← 无条件者 ?",
            points: ["定言推理 → 灵魂；假言推理 → 世界；选言推理 → 上帝。",
                     "理念在经验中没有相应对象。",
                     "无条件者作为“任务”合法，作为“对象”就成了幻相。"],
            body: .canvas(drawIdeas)),
    Chapter(part: "先验辩证论", title: "谬误推理",
            thesis: "理性心理学把思维的逻辑主体误当作实体性的灵魂。",
            formula: "主体_实在 ≠ 主体_逻辑  ⟹  推理无效",
            points: ["“我思”只是一切思维的形式条件，不是被直观的对象。",
                     "推不出灵魂的实体性、单纯性、人格同一性和独立于身体的存在。"],
            body: .canvas(drawParalogism)),
    Chapter(part: "先验辩证论", title: "二律背反",
            thesis: "关于世界整体，正反两方都能“证明”自己。",
            formula: "¬(|W| < ∞) ∧ ¬(|W| = ∞)",
            points: ["数学性背反：双方共享假前提，二者皆假。",
                     "力学性背反：分属本体与现象，二者可以同真。",
                     "二律背反间接证明了先验观念论。"],
            body: .interactive(AnyView(AntinomyView()))),
    Chapter(part: "先验辩证论", title: "纯粹理性的理想",
            thesis: "上帝存在的三种思辨证明都失败了。",
            formula: "C(100 塔勒_现实) = C(100 塔勒_可能)",
            points: ["本体论证明：存在不是实在谓词，只是设定。",
                     "宇宙论证明：从偶然推到必然，再偷偷换成最实在者。",
                     "自然神学证明：最多得到一个世界建筑师。"],
            body: .canvas(drawIdeal)),
    Chapter(part: "先验辩证论", title: "附录：理念的调节性使用",
            thesis: "理念不能构成对象，却能为知识指出系统统一的方向。",
            formula: "max Unity(T) ,  sup = 理念 ∉ E",
            points: ["像镜子后面的虚焦点：光线并不从那里来，却必须这样设想。",
                     "灵魂、世界、上帝作为“好像”的原则，引导研究。"],
            body: .interactive(AnyView(RegulativeView()))),
    Chapter(part: "先验方法论", title: "纯粹理性的训练",
            thesis: "哲学不能模仿数学的方法。",
            formula: "数学：构造概念   哲学：分析概念",
            points: ["数学在直观中构造概念，所以有定义、公理和演证。",
                     "哲学只能从概念出发进行推论性的认识。",
                     "论战中的理性应接受批判，而非独断或怀疑。"],
            body: .canvas(drawDiscipline)),
    Chapter(part: "先验方法论", title: "纯粹理性的法规",
            thesis: "纯粹理性的正当使用在实践领域。",
            formula: "知识 = 主观充分 ∧ 客观充分",
            points: ["三个问题：我能知道什么？我应当做什么？我可以希望什么？",
                     "上帝与来世是道德上的信念，而不是知识。"],
            body: .canvas(drawCanon)),
    Chapter(part: "先验方法论", title: "纯粹理性的建筑术",
            thesis: "知识应按一个理念组织成系统，而不是堆积。",
            formula: "系统 = 一个理念下的有机整体",
            points: ["系统像动物的身体：内部生长，而非外部添加。",
                     "哲学是一切知识与人类理性根本目的之关系的科学。"],
            body: .canvas(drawArchitectonic)),
    Chapter(part: "先验方法论", title: "纯粹理性的历史",
            thesis: "独断论与怀疑论之后，只剩批判的道路仍然敞开。",
            formula: "独断论 → 怀疑论 → 批判",
            points: ["独断论：未经批判地使用理性。",
                     "怀疑论：动摇一切，却不能建立。",
                     "批判：先考察理性能力本身。"],
            body: .canvas(drawHistory)),
]

// MARK: - 目录
struct ChapterListView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Backdrop()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        Text("Pure")
                            .font(.system(size: 44, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)
                        Text("纯粹理性批判")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white.opacity(0.85))
                        Text("\(chapters.count) 章 · v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "")")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.6))
                            .padding(.bottom, 8)
                        ForEach(bookParts, id: \.self) { part in
                            Text(part)
                                .font(.footnote.weight(.semibold)).foregroundStyle(.white.opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.top, 12)
                            GlassEffectContainer(spacing: 10) {
                                VStack(spacing: 10) {
                                    ForEach(Array(chapters.enumerated()).filter { $0.element.part == part }, id: \.offset) { item in
                                        NavigationLink {
                                            ChapterView(index: item.offset)
                                        } label: {
                                            ChapterRow(number: item.offset + 1, chapter: item.element)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

private struct ChapterRow: View {
    let number: Int
    let chapter: Chapter
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(format: "%02d", number))
                .font(.system(.callout, design: .monospaced).weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 40, height: 40)
                .glassEffect(Glass.regular.tint(.white.opacity(0.12)), in: .circle)
            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title).font(.body.weight(.semibold)).foregroundStyle(.white)
                Text(chapter.thesis).font(.caption).foregroundStyle(.white.opacity(0.6)).lineLimit(2)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Moon.dim)
        }
        .padding(16)
        .contentShape(.rect(cornerRadius: 22))
        .glassEffect(Glass.regular.interactive(), in: .rect(cornerRadius: 22))
    }
}

// MARK: - 章节页
struct ChapterView: View {
    @State var index: Int

    var body: some View {
        let c = chapters[index]
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("第 \(index + 1) / \(chapters.count) 章 · \(c.part)")
                        .font(.caption).foregroundStyle(Moon.silver)
                    content(c)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("要点").font(.headline).foregroundStyle(.white)
                        ForEach(c.points, id: \.self) { pt in
                            HStack(alignment: .top, spacing: 8) {
                                Circle().fill(.white.opacity(0.8)).frame(width: 5, height: 5).padding(.top, 7)
                                Text(pt).font(.subheadline).foregroundStyle(.white.opacity(0.85))
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: .rect(cornerRadius: 24))
                    GlassEffectContainer(spacing: 12) {
                        HStack {
                            Button { withAnimation(.spring(duration: 0.5)) { index -= 1 } } label: {
                                Label("上一章", systemImage: "chevron.left").padding(.vertical, 4)
                            }
                            .buttonStyle(.glass)
                            .disabled(index == 0)
                            Spacer()
                            Button { withAnimation(.spring(duration: 0.5)) { index += 1 } } label: {
                                Label("下一章", systemImage: "chevron.right").padding(.vertical, 4)
                            }
                            .buttonStyle(.glassProminent)
                            .disabled(index == chapters.count - 1)
                        }
                    }
                    .font(.callout.weight(.semibold))
                    .tint(.white.opacity(0.25))
                }
                .padding(20)
                .id(index)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func content(_ c: Chapter) -> some View {
        switch c.body {
        case .canvas(let draw):
            Header(title: c.title, formula: c.formula, subtitle: c.thesis)
            Stage(height: 380) {
                TimelineView(.animation) { tl in
                    Canvas { ctx, size in
                        draw(&ctx, size, tl.date.timeIntervalSinceReferenceDate)
                    }
                }
            }
        case .interactive(let view):
            view
        }
    }
}
