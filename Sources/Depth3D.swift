import SwiftUI

// MARK: - 3D 版本：把任何 2D 动画的绘制记录下来，放进有纵深的空间里重新渲染
//
// 所有动画都通过同一组绘图函数（line / ring / box / dot / blob / label / fillPath / strokePath）作画。
// 3D 模式下这些函数不直接画，而是记成“图元”；渲染器再给图元加上厚度、体积、阴影和透视，
// 用户可以拖动旋转视角、双指缩放。

enum Prim {
    case line(Double, Double, Double, Double, Color, Double, [CGFloat])
    case ring(Double, Double, Double, Color, Double, [CGFloat])
    case box(Double, Double, Double, Double, Color, Color?)
    case blob(Double, Double, Double, Color)
    case dot(Double, Double, Double, Color)
    case label(String, Double, Double, Color, Double, Bool, Bool)     // 文字、x、y、颜色、字号、衬线、是否为标题栏
    case path(Path, Color?, Color?, StrokeStyle)                      // 路径、填充、描边
}

final class PrimRecorder {
    var prims: [Prim] = []
    var hud = false
    static var current: PrimRecorder?
}

// MARK: - 可记录的路径绘制

func fillPath(_ ctx: inout GraphicsContext, _ p: Path, _ color: Color) {
    if let r = PrimRecorder.current { r.prims.append(.path(p, color, nil, StrokeStyle())); return }
    ctx.fill(p, with: .color(color))
}

func fillPath(_ ctx: inout GraphicsContext, _ p: Path, shading: GraphicsContext.Shading, tint: Color = Color.primary.opacity(0.14)) {
    if let r = PrimRecorder.current { r.prims.append(.path(p, tint, nil, StrokeStyle())); return }
    ctx.fill(p, with: shading)
}

func strokePath(_ ctx: inout GraphicsContext, _ p: Path, _ color: Color, lineWidth: Double = 1) {
    strokePath(&ctx, p, color, style: StrokeStyle(lineWidth: lineWidth))
}

func strokePath(_ ctx: inout GraphicsContext, _ p: Path, _ color: Color, style: StrokeStyle) {
    if let r = PrimRecorder.current { r.prims.append(.path(p, nil, color, style)); return }
    ctx.stroke(p, with: .color(color), style: style)
}

// MARK: - 手指与画面的互动（2D）：手指附近的微粒被轻轻推开

enum TouchField {
    static var point: CGPoint?
    static func push(_ x: Double, _ y: Double) -> (Double, Double) {
        guard let p = point else { return (x, y) }
        let dx = x - p.x, dy = y - p.y, d = max(1, hypot(dx, dy))
        guard d < 90 else { return (x, y) }
        let k = (90 - d) * 0.55
        return (x + dx / d * k, y + dy / d * k)
    }
}

// MARK: - 相机

struct Cam3D: Equatable {
    var yaw = 0.38
    var pitch = 0.30
    var zoom = 1.0
}

struct Projector {
    let W: Double, H: Double
    let cy, sy, cp, sp, f, zoom: Double

    init(_ size: CGSize, _ cam: Cam3D) {
        W = Double(size.width); H = Double(size.height)
        cy = cos(cam.yaw); sy = sin(cam.yaw); cp = cos(cam.pitch); sp = sin(cam.pitch)
        f = 2.4 * max(W, H); zoom = cam.zoom * 0.86
    }

    /// 画布坐标 (x, y) 与纵深 z → 屏幕坐标、缩放系数、离镜头的远近（越大越近）
    func callAsFunction(_ x: Double, _ y: Double, _ z: Double) -> (CGPoint, Double, Double) {
        let X = x - W / 2, Y = y - H / 2
        let x1 = X * cy + z * sy
        let z1 = -X * sy + z * cy
        let y2 = Y * cp - z1 * sp
        let z2 = Y * sp + z1 * cp
        let s = f / (f - z2) * zoom
        return (CGPoint(x: W / 2 + x1 * s, y: H / 2 + 8 + y2 * s), s, z2)
    }
}

/// 点按查看：记录这一帧里文字与节点在屏幕上的位置
final class InspectCache {
    var labels: [(String, CGPoint)] = []
    var nodes: [CGPoint] = []
    var highlight: (CGPoint, Double)?
}

// MARK: - 渲染

private let backZ = -70.0

private func flatten(_ path: Path) -> [[CGPoint]] {
    var subs: [[CGPoint]] = [], cur: [CGPoint] = []
    var last = CGPoint.zero
    path.forEach { el in
        switch el {
        case .move(let p): if cur.count > 1 { subs.append(cur) }; cur = [p]; last = p
        case .line(let p): cur.append(p); last = p
        case .quadCurve(let p, let c):
            for i in 1...6 {
                let t = Double(i) / 6, u = 1 - t
                cur.append(CGPoint(x: u * u * last.x + 2 * u * t * c.x + t * t * p.x, y: u * u * last.y + 2 * u * t * c.y + t * t * p.y))
            }
            last = p
        case .curve(let p, let c1, let c2):
            for i in 1...8 {
                let t = Double(i) / 8, u = 1 - t
                let x = u * u * u * last.x + 3 * u * u * t * c1.x + 3 * u * t * t * c2.x + t * t * t * p.x
                let y = u * u * u * last.y + 3 * u * u * t * c1.y + 3 * u * t * t * c2.y + t * t * t * p.y
                cur.append(CGPoint(x: x, y: y))
            }
            last = p
        case .closeSubpath: if let f = cur.first { cur.append(f) }
        }
    }
    if cur.count > 1 { subs.append(cur) }
    return subs
}

private func roundedOutline(_ x: Double, _ y: Double, _ w: Double, _ h: Double, _ r: Double) -> [CGPoint] {
    let r = min(r, w / 2, h / 2)
    var pts: [CGPoint] = []
    let corners = [(x + w - r, y + r, -Double.pi / 2), (x + w - r, y + h - r, 0), (x + r, y + h - r, Double.pi / 2), (x + r, y + r, Double.pi)]
    for (cx, cy, a0) in corners {
        for k in 0...3 {
            let a = a0 + Double(k) / 3 * Double.pi / 2
            pts.append(CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r))
        }
    }
    return pts
}

private func poly(_ pts: [CGPoint], close: Bool = true) -> Path {
    var p = Path()
    guard let f = pts.first else { return p }
    p.move(to: f)
    for q in pts.dropFirst() { p.addLine(to: q) }
    if close { p.closeSubpath() }
    return p
}

func render3D(_ prims: [Prim], _ ctx: inout GraphicsContext, _ size: CGSize, cam: Cam3D, t: Double, cache: InspectCache?) {
    let P = Projector(size, cam)
    let W = Double(size.width), H = Double(size.height)
    cache?.labels.removeAll(keepingCapacity: true)
    cache?.nodes.removeAll(keepingCapacity: true)

    // 1. 背板：一块有网格的玻璃底板
    let back = [CGPoint(x: -20, y: -10), CGPoint(x: W + 20, y: -10), CGPoint(x: W + 20, y: H + 10), CGPoint(x: -20, y: H + 10)]
        .map { P($0.x, $0.y, backZ).0 }
    ctx.fill(poly(back), with: .color(Color.primary.opacity(0.035)))
    ctx.stroke(poly(back), with: .color(Color.white.opacity(0.25)), lineWidth: 1)
    var grid = Path()
    var gx = -20.0
    while gx <= W + 20 { grid.move(to: P(gx, -10, backZ).0); grid.addLine(to: P(gx, H + 10, backZ).0); gx += 36 }
    var gy = -10.0
    while gy <= H + 10 { grid.move(to: P(-20, gy, backZ).0); grid.addLine(to: P(W + 20, gy, backZ).0); gy += 36 }
    ctx.stroke(grid, with: .color(Color.primary.opacity(0.05)), lineWidth: 0.6)

    // 2. 投在背板上的影子（光从左上前方来）
    for pr in prims {
        switch pr {
        case .dot(let x, let y, let r, let c) where r >= 4.5:
            let (p, s, _) = P(x + 9, y + 12, backZ)
            let rr = r * 1.15 * s
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - rr, y: p.y - rr, width: rr * 2, height: rr * 2)),
                     with: .radialGradient(Gradient(colors: [Color.black.opacity(0.16 * alphaOf(c)), .clear]),
                                           center: p, startRadius: 0, endRadius: rr))
        case .box(let x, let y, let w, let h, let c, _):
            let pts = [CGPoint(x: x + 10, y: y + 12), CGPoint(x: x + w + 10, y: y + 12), CGPoint(x: x + w + 10, y: y + h + 12), CGPoint(x: x + 10, y: y + h + 12)]
                .map { P($0.x, $0.y, backZ).0 }
            ctx.fill(poly(pts), with: .color(Color.black.opacity(0.07 * alphaOf(c))))
        default: break
        }
    }

    // 3. 平面图元：线、环、路径、微粒（保持原来的先后次序）
    for pr in prims {
        switch pr {
        case .line(let x1, let y1, let x2, let y2, let c, let w, let dash):
            let (a, s, _) = P(x1, y1, 0), (b, _, _) = P(x2, y2, 0)
            var p = Path(); p.move(to: a); p.addLine(to: b)
            ctx.stroke(p, with: .color(c), style: StrokeStyle(lineWidth: w * s, lineCap: .round, dash: dash))
        case .ring(let x, let y, let r, let c, let w, let dash):
            let pts = (0...48).map { k -> CGPoint in
                let a = Double(k) / 48 * 2 * Double.pi
                return P(x + cos(a) * r, y + sin(a) * r, 0).0
            }
            ctx.stroke(poly(pts, close: false), with: .color(c), style: StrokeStyle(lineWidth: w, dash: dash))
        case .path(let path, let fill, let stroke, let style):
            let subs = flatten(path)
            if let fill {
                // 有填充的面：做成薄片，侧面略深
                for sub in subs {
                    let front = sub.map { P($0.x, $0.y, 4).0 }
                    let backS = sub.map { P($0.x, $0.y, 0).0 }
                    ctx.fill(poly(backS), with: .color(fill.opacity(0.5)))
                    ctx.fill(poly(front), with: .color(fill))
                }
            }
            if let stroke {
                for sub in subs {
                    ctx.stroke(poly(sub.map { P($0.x, $0.y, 0).0 }, close: false), with: .color(stroke),
                               style: StrokeStyle(lineWidth: style.lineWidth, lineCap: style.lineCap, dash: style.dash))
                }
            }
        case .blob(let x, let y, let r, let c):
            let (p, s, _) = P(x, y, 2)
            let rr = r * s
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - rr, y: p.y - rr, width: rr * 2, height: rr * 2)), with: .color(c))
        case .dot(let x, let y, let r, let c) where r < 4.5:
            let (p, s, _) = P(x, y, r)
            let rr = r * s
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - rr, y: p.y - rr, width: rr * 2, height: rr * 2)), with: .color(c))
        default: break
        }
    }

    // 4. 立体图元：玻璃球、玻璃板，按远近排序
    var solids: [(Double, Prim)] = []
    for pr in prims {
        switch pr {
        case .dot(let x, let y, let r, _) where r >= 4.5: solids.append((P(x, y, r * 0.7).2, pr))
        case .box(let x, let y, let w, let h, _, _): solids.append((P(x + w / 2, y + h / 2, 6).2, pr))
        default: break
        }
    }
    solids.sort { $0.0 < $1.0 }
    for (_, pr) in solids {
        switch pr {
        case .dot(let x, let y, let r, let c):
            let (p, s, _) = P(x, y, r * 0.7)
            let rr = r * s
            let rect = CGRect(x: p.x - rr, y: p.y - rr, width: rr * 2, height: rr * 2)
            let circle = Path(ellipseIn: rect)
            ctx.fill(circle, with: .radialGradient(Gradient(colors: [c.opacity(0.30), c.opacity(0.9)]),
                                                   center: CGPoint(x: p.x - rr * 0.35, y: p.y - rr * 0.4), startRadius: 0, endRadius: rr * 1.35))
            ctx.stroke(circle, with: .linearGradient(Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.05), Color.white.opacity(0.4)]),
                                                     startPoint: rect.origin, endPoint: CGPoint(x: rect.maxX, y: rect.maxY)), lineWidth: max(0.8, rr * 0.07))
            let hl = CGRect(x: p.x - rr * 0.55, y: p.y - rr * 0.78, width: rr * 0.75, height: rr * 0.45)
            ctx.fill(Path(ellipseIn: hl), with: .linearGradient(Gradient(colors: [Color.white.opacity(0.85), Color.white.opacity(0)]),
                                                                startPoint: CGPoint(x: hl.midX, y: hl.minY), endPoint: CGPoint(x: hl.midX, y: hl.maxY)))
            cache?.nodes.append(p)
        case .box(let x, let y, let w, let h, let c, let fill):
            let depth = min(16, max(6, h * 0.3))
            let outline = roundedOutline(x, y, w, h, min(12, h / 2))
            let backO = outline.map { P($0.x, $0.y, 0).0 }
            let frontO = outline.map { P($0.x, $0.y, depth).0 }
            let side = (fill ?? c).opacity(0.18 * alphaOf(c) + 0.05)
            for i in 0..<outline.count {
                let j = (i + 1) % outline.count
                ctx.fill(poly([backO[i], backO[j], frontO[j], frontO[i]]), with: .color(side))
            }
            let front = poly(frontO)
            ctx.fill(front, with: .linearGradient(Gradient(colors: [Color.white.opacity(0.16), Color.white.opacity(0.04)]),
                                                  startPoint: frontO[0], endPoint: frontO[frontO.count / 2]))
            if let fill { ctx.fill(front, with: .color(fill)) }
            ctx.fill(front, with: .color(c.opacity(0.08)))
            ctx.stroke(front, with: .color(Color.white.opacity(0.55 * alphaOf(c) + 0.1)), lineWidth: 1)
        default: break
        }
    }

    // 5. 文字：悬浮在最前面，始终正对屏幕
    var texts: [(Double, String, CGPoint, Color, Double, Bool)] = []
    var hud: [(String, Double, Double, Color, Double, Bool)] = []
    for pr in prims {
        if case .label(let s, let x, let y, let c, let size, let serif, let isHud) = pr {
            if isHud { hud.append((s, x, y, c, size, serif)); continue }
            let (p, sc, d) = P(x, y, 18)
            texts.append((d, s, p, c, size * min(1.25, max(0.85, sc)), serif))
        }
    }
    texts.sort { $0.0 < $1.0 }
    for (_, s, p, c, size, serif) in texts {
        ctx.draw(Text(s).font(.system(size: size, weight: serif ? .regular : .medium, design: serif ? .serif : .rounded)).foregroundColor(c), at: p)
        cache?.labels.append((s, p))
    }
    for (s, x, y, c, size, serif) in hud {
        ctx.draw(Text(s).font(.system(size: size, weight: serif ? .regular : .medium, design: serif ? .serif : .rounded)).foregroundColor(c),
                 at: CGPoint(x: x, y: y))
    }
}

/// 用 3D 方式画一帧：先把 draw 的输出记录成图元，再渲染。返回这一帧的节拍信息。
@discardableResult
func drawIn3D(_ draw: (inout GraphicsContext, CGSize, Double) -> Void, _ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double,
              cam: Cam3D, cache: InspectCache?) -> BeatInfo? {
    let rec = PrimRecorder()
    let beatBuf = GlassBuffer()
    PrimRecorder.current = rec
    GlassBuffer.current = beatBuf
    var scratch = ctx
    scratch.opacity = 0
    draw(&scratch, size, t)
    PrimRecorder.current = nil
    GlassBuffer.current = nil
    render3D(rec.prims, &ctx, size, cam: cam, t: t, cache: cache)
    return beatBuf.beat
}

/// 点按处的高亮：扩散的光环
func drawHighlight(_ ctx: inout GraphicsContext, _ cache: InspectCache, _ now: Double) {
    guard let (p, t0) = cache.highlight else { return }
    let age = now - t0
    guard age < 1.6 else { cache.highlight = nil; return }
    for j in 0..<2 {
        let f = min(1, max(0, (age - Double(j) * 0.25) / 1.1))
        let r = 10 + f * 46
        ctx.stroke(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                   with: .color(Moon.gold.opacity(0.7 * (1 - f))), lineWidth: 2)
    }
}

// MARK: - 可拖动的元素（数据驱动的场景）

protocol DragSurface: AnyObject {
    /// 返回手指下方可以拖动的元素
    func hit(_ p: CGPoint) -> String?
    func drag(_ id: String, by d: CGSize)
    func resetDrag()
    var hasDrag: Bool { get }
}
