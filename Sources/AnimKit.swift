import SwiftUI

typealias Draw = (inout GraphicsContext, CGSize, Double) -> Void

func line(_ ctx: inout GraphicsContext, _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double,
          _ color: Color, _ width: Double = 1.5, dash: [CGFloat] = []) {
    var p = Path()
    p.move(to: CGPoint(x: x1, y: y1))
    p.addLine(to: CGPoint(x: x2, y: y2))
    ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: CGFloat(width), dash: dash))
}

func ring(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double,
          _ color: Color, _ width: Double = 1.5, dash: [CGFloat] = []) {
    let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
    ctx.stroke(Path(ellipseIn: rect), with: .color(color), style: StrokeStyle(lineWidth: CGFloat(width), dash: dash))
}

func box(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ w: Double, _ h: Double,
         _ color: Color, fill: Color? = nil) {
    let path = Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: min(12, h / 2))
    ctx.fill(path, with: .linearGradient(
        Gradient(colors: [Color.white.opacity(0.10), Color.white.opacity(0.03)]),
        startPoint: CGPoint(x: x, y: y), endPoint: CGPoint(x: x, y: y + h)))
    if let fill = fill { ctx.fill(path, with: .color(fill)) }
    ctx.stroke(path, with: .linearGradient(
        Gradient(colors: [Color.white.opacity(0.7), color.opacity(0.25), Color.white.opacity(0.35)]),
        startPoint: CGPoint(x: x, y: y), endPoint: CGPoint(x: x + w, y: y + h)), lineWidth: 1)
}

func smooth(_ x: Double) -> Double {
    let c = min(1, max(0, x))
    return c * c * (3 - 2 * c)
}

func lerp(_ a: Double, _ b: Double, _ k: Double) -> Double { a + (b - a) * k }

/// 把时间切成 count 段循环：返回当前段号和段内进度 [0,1)
func phase(_ t: Double, period: Double, count: Int) -> (Int, Double) {
    let p = fract(t / period) * Double(count)
    let i = min(Int(p), count - 1)
    return (i, p - Double(i))
}

func caption(_ ctx: inout GraphicsContext, _ s: String, _ size: CGSize) {
    label(&ctx, s, Double(size.width) / 2, Double(size.height) - 18, Moon.gold, size: 13)
}

func headline(_ ctx: inout GraphicsContext, _ s: String, _ size: CGSize, _ color: Color = .white) {
    label(&ctx, s, Double(size.width) / 2, 22, color, size: 14)
}
