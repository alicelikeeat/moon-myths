import SwiftUI

enum Moon {
    static let bg = Color(red: 0.03, green: 0.03, blue: 0.08)
    static let gold = Color(red: 0.96, green: 0.83, blue: 0.52)
    static let silver = Color(red: 0.76, green: 0.82, blue: 0.97)
    static let violet = Color(red: 0.58, green: 0.47, blue: 0.97)
    static let dim = Color.white.opacity(0.35)
}

func fract(_ v: Double) -> Double { v - floor(v) }

/// 伪随机：同一个 seed 永远给出同一个 [0,1) 数
func hash01(_ seed: Double) -> Double { fract(sin(seed * 12.9898) * 43758.5453) }

func dot(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double, _ color: Color) {
    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(color))
}

func label(_ ctx: inout GraphicsContext, _ s: String, _ x: Double, _ y: Double,
           _ color: Color = Moon.dim, size: Double = 12) {
    ctx.draw(Text(s).font(.system(size: size, weight: .medium, design: .rounded)).foregroundColor(color),
             at: CGPoint(x: x, y: y))
}

struct StarField: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            Canvas { ctx, size in
                let t = tl.date.timeIntervalSinceReferenceDate
                let w = Double(size.width), h = Double(size.height)
                for i in 0..<140 {
                    let s = Double(i)
                    let a = 0.15 + 0.6 * abs(sin(t * 0.7 + s * 1.7))
                    dot(&ctx, hash01(s) * w, hash01(s + 71.3) * h, 0.5 + hash01(s + 3.1) * 1.2, .white.opacity(a))
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
            StarField()
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
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 30, weight: .bold, design: .serif)).foregroundStyle(Moon.gold)
            Text(formula).font(.system(.body, design: .monospaced)).foregroundStyle(Moon.silver)
            Text(subtitle).font(.subheadline).foregroundStyle(.white.opacity(0.7))
        }
    }
}

struct Stage<Content: View>: View {
    var height: Double = 380
    @ViewBuilder var content: Content
    var body: some View {
        content
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 24).fill(.white.opacity(0.05)))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.08)))
    }
}
