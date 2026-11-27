import SwiftUI

typealias Draw = (inout GraphicsContext, CGSize, Double) -> Void

func line(_ ctx: inout GraphicsContext, _ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double,
          _ color: Color, _ width: Double = 1.5, dash: [CGFloat] = []) {
    if let r = PrimRecorder.current { r.prims.append(.line(x1, y1, x2, y2, color, width, dash)); return }
    var p = Path()
    p.move(to: CGPoint(x: x1, y: y1))
    p.addLine(to: CGPoint(x: x2, y: y2))
    // 精致线条：实线下垫一层柔光，圆头
    if dash.isEmpty && width >= 1.2 {
        ctx.stroke(p, with: .color(color.opacity(0.16)), style: StrokeStyle(lineWidth: CGFloat(width * 3.4), lineCap: .round))
    }
    ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: CGFloat(width), lineCap: .round, dash: dash))
}

func ring(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ r: Double,
          _ color: Color, _ width: Double = 1.5, dash: [CGFloat] = []) {
    if let rec = PrimRecorder.current { rec.prims.append(.ring(x, y, r, color, width, dash)); return }
    let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
    if dash.isEmpty && width >= 1.2 {
        ctx.stroke(Path(ellipseIn: rect), with: .color(color.opacity(0.14)), style: StrokeStyle(lineWidth: CGFloat(width * 3.2)))
    }
    ctx.stroke(Path(ellipseIn: rect), with: .color(color), style: StrokeStyle(lineWidth: CGFloat(width), lineCap: .round, dash: dash))
}

func box(_ ctx: inout GraphicsContext, _ x: Double, _ y: Double, _ w: Double, _ h: Double,
         _ color: Color, fill: Color? = nil) {
    if let r = PrimRecorder.current { r.prims.append(.box(x, y, w, h, color, fill)); return }
    if let buf = GlassBuffer.current {
        let a = alphaOf(color)
        guard a > 0.03 else { return }
        buf.nodes.append(GlassNode(kind: .rect(corner: min(12, h / 2)), x: x + w / 2, y: y + h / 2,
                                   w: max(1, w), h: max(1, h), color: fill ?? color, alpha: min(1, a * 1.15)))
        return
    }
    DrawSink.cache?.nodes.append(CGPoint(x: x + w / 2, y: y + h / 2))
    let a = alphaOf(color)
    guard a > 0.02 else { return }
    let rect = CGRect(x: x, y: y, width: w, height: h)
    let corner = min(14, h / 2)
    let path = Path(roundedRect: rect, cornerRadius: corner)
    // 1. 柔和投影（渐变代替模糊，便宜）
    let shadow = Path(roundedRect: rect.offsetBy(dx: 0, dy: 3).insetBy(dx: -2, dy: -1), cornerRadius: corner + 2)
    ctx.fill(shadow, with: .linearGradient(Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.10 * a)]),
                                           startPoint: CGPoint(x: x, y: y), endPoint: CGPoint(x: x, y: y + h + 4)))
    // 2. 玻璃体：上亮下暗，再叠一层色彩
    ctx.fill(path, with: .linearGradient(
        Gradient(colors: [Color.white.opacity(0.20 * a), Color.white.opacity(0.05 * a), color.opacity(0.06 * a)]),
        startPoint: CGPoint(x: x, y: y), endPoint: CGPoint(x: x, y: y + h)))
    if let fill = fill { ctx.fill(path, with: .color(fill)) }
    // 3. 底部折射光
    ctx.fill(Path(roundedRect: CGRect(x: x + 4, y: y + h * 0.62, width: max(0, w - 8), height: h * 0.32), cornerRadius: corner * 0.8),
             with: .linearGradient(Gradient(colors: [color.opacity(0), color.opacity(0.10 * a)]),
                                   startPoint: CGPoint(x: x, y: y + h * 0.62), endPoint: CGPoint(x: x, y: y + h)))
    // 4. 边缘反光：左上亮、右下带色
    ctx.stroke(path, with: .linearGradient(
        Gradient(colors: [Color.white.opacity(0.85 * a), color.opacity(0.30 * a), Color.white.opacity(0.40 * a)]),
        startPoint: CGPoint(x: x, y: y), endPoint: CGPoint(x: x + w, y: y + h)), lineWidth: 1)
    // 5. 顶沿一道细高光
    var top = Path()
    top.move(to: CGPoint(x: x + corner, y: y + 1.2))
    top.addLine(to: CGPoint(x: x + w - corner, y: y + 1.2))
    ctx.stroke(top, with: .linearGradient(Gradient(colors: [Color.white.opacity(0), Color.white.opacity(0.7 * a), Color.white.opacity(0)]),
                                          startPoint: CGPoint(x: x + corner, y: y), endPoint: CGPoint(x: x + w - corner, y: y)), lineWidth: 0.8)
}

/// 缓动：smootherstep（起止都更柔和，所有动画共用）
func smooth(_ x: Double) -> Double {
    let c = min(1, max(0, x))
    return c * c * c * (c * (c * 6 - 15) + 10)
}

func lerp(_ a: Double, _ b: Double, _ k: Double) -> Double { a + (b - a) * k }

/// 节拍：动画按若干节拍依次播放，最后一拍结束后停留 hold 秒再从头开始。
/// 返回当前节拍序号与拍内进度 [0,1]；停留期间保持在最后一拍的终点。
func beats(_ t: Double, _ durations: [Double], hold: Double = 2.5) -> (Int, Double) {
    let total = durations.reduce(0, +) + hold
    var u = fract(t / total) * total
    let info = BeatInfo(durations: durations, hold: hold, cycleStart: t - u)
    GlassBuffer.current?.beat = info
    DrawSink.beat = info
    for (i, d) in durations.enumerated() {
        if u < d { return (i, u / d) }
        u -= d
    }
    return (durations.count - 1, 1)
}

/// 把时间切成 count 段循环：返回当前段号和段内进度 [0,1)
func phase(_ t: Double, period: Double, count: Int) -> (Int, Double) {
    let p = fract(t / period) * Double(count)
    let i = min(Int(p), count - 1)
    return (i, p - Double(i))
}

func caption(_ ctx: inout GraphicsContext, _ s: String, _ size: CGSize) {
    PrimRecorder.current?.hud = true
    defer { PrimRecorder.current?.hud = false }
    // 说明文字下垫一条极淡的胶囊底，任何背景上都清楚
    if PrimRecorder.current == nil, GlassBuffer.current == nil, !s.isEmpty {
        let w = min(Double(size.width) - 24, Double(s.count) * 13.5 + 28)
        let r = CGRect(x: Double(size.width) / 2 - w / 2, y: Double(size.height) - 31, width: w, height: 26)
        ctx.fill(Path(roundedRect: r, cornerRadius: 13), with: .color(Color.primary.opacity(0.05)))
        ctx.stroke(Path(roundedRect: r, cornerRadius: 13), with: .color(Color.primary.opacity(0.06)), lineWidth: 0.5)
    }
    label(&ctx, s, Double(size.width) / 2, Double(size.height) - 18, Moon.gold, size: 13)
}

func headline(_ ctx: inout GraphicsContext, _ s: String, _ size: CGSize, _ color: Color = Color.primary) {
    PrimRecorder.current?.hud = true
    defer { PrimRecorder.current?.hud = false }
    label(&ctx, s, Double(size.width) / 2, 24, color, size: 15, serif: true)
}

/// 单遍绘制时收集点按提示所需的文字与节点位置，以及节拍信息
enum DrawSink {
    static var cache: InspectCache?
    static var beat: BeatInfo?
}
