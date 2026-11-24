import SwiftUI

/// K = κ ∘ σ ：物自体的刺激 → 时空坐标化（σ）→ 范畴统一（κ）→ 对象
struct PipelineView: View {
    @State private var sensibility = true
    @State private var understanding = true

    var body: some View {
        Header(title: "认识的管线",
               formula: "K = κ ∘ σ ,  σ: X → S×T ,  κ: 杂多 → 对象",
               subtitle: "刺激先被时空“坐标化”，再被范畴统一，才成为对象。关掉任意一层试试。")

        Stage(height: 440) {
            TimelineView(.animation) { tl in
                Canvas { ctx, size in
                    draw(&ctx, size, tl.date.timeIntervalSinceReferenceDate)
                }
            }
        }

        Toggle("感性 σ（直观）", isOn: $sensibility.animation())
        Toggle("知性 κ（概念）", isOn: $understanding.animation())

        Text(status)
            .font(.callout.weight(.semibold))
            .foregroundStyle(Moon.gold)
    }

    private var status: String {
        switch (sensibility, understanding) {
        case (true, true): return "直观 + 概念 → 经验对象（知识）"
        case (true, false): return "无概念的直观是盲的：杂多散开，不成对象"
        case (false, true): return "无直观的概念是空的：范畴没有材料可统一"
        case (false, false): return "什么也没有：只剩不可知的物自体"
        }
    }

    private func draw(_ ctx: inout GraphicsContext, _ size: CGSize, _ t: Double) {
        let w = Double(size.width), h = Double(size.height)
        let ySigma = h * 0.26, yKappa = h * 0.62, yObj = h * 0.88
        let targets: [(Double, String)] = [(w * 0.2, "实体"), (w * 0.5, "因果"), (w * 0.8, "协同")]
        let cols = 7.0

        // 物自体：雾
        var fog = ctx
        fog.addFilter(.blur(radius: 18))
        for i in 0..<18 {
            let s = Double(i)
            let x = hash01(s + 9) * w + sin(t * 0.3 + s) * 20
            let y = hash01(s + 19) * ySigma * 0.8 + 10
            blob(&fog, x, y, 18 + hash01(s) * 20, .white.opacity(0.05))
        }
        label(&ctx, "物自体 X（不可知）", 70, 16)

        // σ 层与时空网格
        let sigmaColor = sensibility ? Moon.silver : Color.gray.opacity(0.25)
        ctx.fill(Path(CGRect(x: 0, y: ySigma - 1, width: w, height: 2)), with: .color(sigmaColor.opacity(0.7)))
        label(&ctx, "σ  时空形式", w - 52, ySigma - 12, sigmaColor)
        if sensibility {
            for c in 0..<Int(cols) {
                let x = (Double(c) + 0.5) * w / cols
                var p = Path()
                p.move(to: CGPoint(x: x, y: ySigma))
                p.addLine(to: CGPoint(x: x, y: yKappa))
                ctx.stroke(p, with: .color(Moon.silver.opacity(0.08)), lineWidth: 1)
            }
        }

        // κ 层
        let kappaColor = understanding ? Moon.gold : Color.gray.opacity(0.25)
        ctx.fill(Path(CGRect(x: 0, y: yKappa - 1, width: w, height: 2)), with: .color(kappaColor.opacity(0.7)))
        label(&ctx, "κ  12 范畴", w - 46, yKappa - 12, kappaColor)

        // 对象节点
        for (x, name) in targets {
            if understanding && sensibility {
                let pulse = 14 + 3 * sin(t * 3 + x)
                dot(&ctx, x, yObj, pulse + 10, Moon.gold.opacity(0.12))
                dot(&ctx, x, yObj, pulse, Moon.gold.opacity(0.35))
            } else {
                ctx.stroke(Path(ellipseIn: CGRect(x: x - 14, y: yObj - 14, width: 28, height: 28)),
                           with: .color(.gray.opacity(0.4)), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
            }
            label(&ctx, name, x, yObj + 26, understanding ? Moon.gold : Moon.dim)
        }

        // 粒子
        let n = 80
        for i in 0..<n {
            let s = Double(i)
            let p = fract(t * 0.11 + s / Double(n))
            let rawX = hash01(s * 3.7) * w
            var x = rawX + sin(t * 2 + s) * 14
            var y = p * h
            var color = Color.white.opacity(0.35)
            var r = 2.2

            if !sensibility {
                y = p * (ySigma - 6)           // 刺激进不来
            } else if y > ySigma {
                let col = (floor(rawX / w * cols) + 0.5) * w / cols
                x = col                         // 被坐标化：吸附到时空网格
                color = Moon.silver.opacity(0.85)
                if y > yKappa {
                    if understanding {
                        let tx = targets[i % 3].0
                        let k = min(1, (y - yKappa) / (yObj - yKappa))
                        x = col + (tx - col) * k * k
                        y = min(y, yObj)
                        color = Moon.gold
                        r = 2.8
                    } else {
                        let spread = (y - yKappa)
                        x = col + sin(t * 4 + s * 1.3) * spread * 0.9   // 盲目散开
                        color = Color.gray.opacity(max(0, 1 - spread / (h - yKappa)))
                    }
                }
            }
            dot(&ctx, x, y, r, color)
        }
    }
}
