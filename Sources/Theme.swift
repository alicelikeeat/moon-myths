import SwiftUI
import UIKit

/// 颜色的不透明度（0…1）
func alphaOf(_ c: Color) -> Double { Double(UIColor(c).cgColor.alpha) }

/// 纯净调色：几乎全白，只保留极淡的冷暖色差来区分含义
/// 深色模式用 dark，白底模式用 light
private func adaptive(_ dark: (Double, Double, Double), _ light: (Double, Double, Double), alpha: (Double, Double) = (1, 1)) -> Color {
    Color(UIColor { trait in
        let c = trait.userInterfaceStyle == .light ? light : dark
        let a = trait.userInterfaceStyle == .light ? alpha.1 : alpha.0
        return UIColor(red: c.0, green: c.1, blue: c.2, alpha: a)
    })
}

enum Moon {
    static let bg = adaptive((0.035, 0.04, 0.06), (0.975, 0.975, 0.98))
    static let gold = adaptive((1.0, 0.96, 0.88), (0.52, 0.36, 0.06))      // 知性 / 对象 / 强调
    static let silver = adaptive((0.82, 0.90, 1.0), (0.16, 0.30, 0.54))    // 感性 / 现象
    static let violet = adaptive((0.88, 0.85, 1.0), (0.38, 0.25, 0.66))    // 理念 / 本体
    static let dim = Color.primary.opacity(0.4)
    /// 选中态玻璃的着色
    static let selection = adaptive((1, 1, 1), (0, 0, 0), alpha: (0.35, 0.1))
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
    if r >= 4.5, let buf = GlassBuffer.current {
        let a = alphaOf(color)
        guard a > 0.03 else { return }
        buf.nodes.append(GlassNode(kind: .circle, x: x, y: y, w: r * 2, h: r * 2, color: color, alpha: min(1, a * 1.15)))
        return
    }
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
    let hl = CGRect(x: x - r * 0.62, y: y - r * 0.9, width: r * 1.24, height: r * 0.62)
    var inner = ctx
    inner.clip(to: circle)
    inner.fill(Path(ellipseIn: hl), with: .linearGradient(
        Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0)]),
        startPoint: CGPoint(x: x, y: hl.minY), endPoint: CGPoint(x: x, y: hl.maxY)))
}

func label(_ ctx: inout GraphicsContext, _ s: String, _ x: Double, _ y: Double,
           _ color: Color = Moon.dim, size: Double = 12) {
    if let buf = GlassBuffer.current {
        buf.texts.append(GlassText(text: s, x: x, y: y, color: color, size: size))
        return
    }
    ctx.draw(Text(s).font(.system(size: size, weight: .medium, design: .rounded)).foregroundColor(color),
             at: CGPoint(x: x, y: y))
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
                .foregroundStyle(Color.primary)
            Text(formula)
                .font(.system(.footnote, design: .monospaced))
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.25), value: formula)
                .foregroundStyle(Color.primary.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .glassEffect(.regular, in: .capsule)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.primary.opacity(0.7))
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
