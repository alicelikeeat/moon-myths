import SwiftUI

/// 纯净调色：几乎全白，只保留极淡的冷暖色差来区分含义
enum Moon {
    static let bg = Color(red: 0.035, green: 0.04, blue: 0.06)
    static let gold = Color(red: 1.0, green: 0.96, blue: 0.88)      // 暖白：知性 / 对象 / 强调
    static let silver = Color(red: 0.82, green: 0.90, blue: 1.0)    // 冰白：感性 / 现象
    static let violet = Color(red: 0.88, green: 0.85, blue: 1.0)    // 淡紫白：理念 / 本体
    static let dim = Color.white.opacity(0.4)
}

func fract(_ v: Double) -> Double { v - floor(v) }

/// 伪随机：同一个 seed 永远给出同一个 [0,1) 数
func hash01(_ seed: Double) -> Double { fract(sin(seed * 12.9898) * 43758.5453) }

/// 实心小点（粒子）
func blob(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ color: Color) {
    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(color))
}

/// Liquid Glass 风格的圆：半透明体、渐变边缘、顶部高光
func dot(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ color: Color) {
    let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
    let circle = Path(ellipseIn: rect)
    if r < 4.5 {
        ctx.fill(circle, with: .color(color))
        return
    }
    ctx.fill(circle, with: .radialGradient(
        Gradient(colors: [color.opacity(0.35), color.opacity(0.75)]),
        center: CGPoint(x: x, y: y + r * 0.2), startRadius: 0, endRadius: r))
    ctx.stroke(circle, with: .linearGradient(
        Gradient(colors: [Color.white.opacity(0.85), Color.white.opacity(0.08), Color.white.opacity(0.45)]),
        startPoint: CGPoint(x: x - r, y: y - r), endPoint: CGPoint(x: x + r, y: y + r)),
        lineWidth: max(0.8, r * 0.07))
    let hl = CGRect(x: x - r * 0.55, y: y - r * 0.78, width: r * 1.1, height: r * 0.5)
    ctx.fill(Path(ellipseIn: hl), with: .linearGradient(
        Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0)]),
        startPoint: CGPoint(x: x, y: hl.minY), endPoint: CGPoint(x: x, y: hl.maxY)))
}

func label(_ ctx: inout GraphicsContext, _ s: String, _ x: Double, _ y: Double,
           _ color: Color = Moon.dim, size: Double = 12) {
    ctx.draw(Text(s).font(.system(size: size, weight: .medium, design: .rounded)).foregroundColor(color),
             at: CGPoint(x: x, y: y))
}

/// 背景：缓慢漂移的柔光，给玻璃提供可折射的内容
struct Backdrop: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let w = Double(size.width), h = Double(size.height)
                ctx.addFilter(.blur(radius: 70))
                let lights: [(Double, Double, Double, Color)] = [
                    (0.25, 0.2, 0.0, Moon.silver), (0.8, 0.45, 2.1, Moon.violet), (0.4, 0.8, 4.2, Moon.gold),
                ]
                for (bx, by, ph, c) in lights {
                    let x = w * bx + sin(t * 0.13 + ph) * w * 0.15
                    let y = h * by + cos(t * 0.11 + ph) * h * 0.08
                    let r = w * 0.45
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                             with: .color(c.opacity(0.16)))
                }
            }
        }
        .background(Moon.bg)
        .ignoresSafeArea()
    }
}

struct Page<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) { content }
                    .padding(20)
            }
        }
    }
}

struct Header: View {
    let title: String
    let formula: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
            Text(formula)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

/// 动画舞台：一整块玻璃
struct Stage<Content: View>: View {
    var height: Double = 380
    @ViewBuilder var content: Content
    var body: some View {
        content
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .clipShape(.rect(cornerRadius: 30))
            .glassEffect(.regular, in: .rect(cornerRadius: 30))
    }
}

/// 通用玻璃卡片
struct GlassCard<Content: View>: View {
    var tint: Color? = nil
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(tint.map { Glass.regular.tint($0.opacity(0.25)) } ?? .regular, in: .rect(cornerRadius: 22))
    }
}
