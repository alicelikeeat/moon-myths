import SwiftUI

/// 动画舞台上的播放控件：右上角一个小玻璃按钮，点开后展开节拍、倍速、播放/暂停
struct PlaybackControls: ViewModifier {
    @Bindable var clock: PlaybackClock
    @State private var expanded = false
    @State private var lastTouch = Date()

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                // 不用 GlassEffectContainer：容器的形变过渡在 iOS 26 上会让按钮收起后点不开
                HStack(spacing: 6) {
                    if expanded {
                        TimelineView(.periodic(from: .now, by: 0.25)) { tl in
                            if let beat = clock.beat, beat.durations.count > 1 {
                                BeatDots(beat: beat, current: beat.index(at: clock.time(tl.date.timeIntervalSinceReferenceDate))) { i in
                                    touch()
                                    clock.jump(to: beat.start(of: i))
                                }
                            }
                        }
                        .transition(.opacity)

                        Menu {
                            ForEach(PlaybackClock.speeds, id: \.self) { s in
                                Button {
                                    touch()
                                    clock.setSpeed(s)
                                } label: {
                                    if s == clock.speed { Label(speedText(s), systemImage: "checkmark") } else { Text(speedText(s)) }
                                }
                            }
                        } label: {
                            Text(speedText(clock.speed))
                                .font(.system(size: 12, weight: .semibold).monospacedDigit())
                                .frame(minWidth: 30, minHeight: 28)
                        }
                        .buttonStyle(.glass)
                        .accessibilityIdentifier("playback.speed")
                        .transition(.opacity)

                        Button {
                            touch()
                            withAnimation(.spring(duration: 0.35)) { clock.toggle() }
                        } label: {
                            Image(systemName: clock.playing ? "pause.fill" : "play.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(width: 28, height: 28)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.circle)
                        .accessibilityIdentifier("playback.play")
                        .transition(.opacity)
                    }

                }
                .padding(.vertical, 8)
                .padding(.trailing, 50)
            }
            .overlay(alignment: .topTrailing) {
                // 展开 / 收起按钮单独一层：旁边的控件出现、消失时它的位置和点按区域都不变
                    Button {
                    touch()
                    withAnimation(.snappy(duration: 0.25)) { expanded.toggle() }
                } label: {
                    Image(systemName: expanded ? "chevron.right" : (clock.playing ? "slider.horizontal.3" : "pause.fill"))
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .contentShape(Circle())
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .accessibilityIdentifier("playback.toggle")
                .accessibilityValue(expanded ? "expanded" : "collapsed")
                    .padding(8)
            }
            .task(id: lastTouch) {
                // 播放中 5 秒无操作自动收起；暂停时保持展开，方便拖动
                // 注意：不能用 try?——任务被取消时 sleep 会立刻返回，
                // 旧任务马上把刚点开的面板收起，看起来就像按钮点不开
                do { try await Task.sleep(for: .seconds(5)) } catch { return }
                if !Task.isCancelled && clock.playing && expanded {
                    withAnimation(.snappy(duration: 0.25)) { expanded = false }
                }
            }
            .overlay(alignment: .bottom) {
                if !clock.playing {
                    HStack(spacing: 10) {
                        Image(systemName: "backward.fill").font(.caption2).opacity(0.6)
                        Slider(value: $clock.scrub, in: 0...1, onEditingChanged: { editing in if editing { touch() } })
                        Image(systemName: "forward.fill").font(.caption2).opacity(0.6)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .glassEffect(.regular, in: .capsule)
                    .padding(12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
    }

    private func touch() { lastTouch = Date() }
}

private func speedText(_ s: Double) -> String {
    s == floor(s) ? "\(Int(s))×" : "\(s)×"
}

extension View {
    func playbackControls(_ clock: PlaybackClock) -> some View { modifier(PlaybackControls(clock: clock)) }
}

// MARK: - 随动画变化的公式（键：书籍 id + ":" + 章节序号）

let liveFormulas: [String: (Double) -> String] = [
    "kant-cpr:0": { t in
        let (ph, p) = beats(t, [7, 7])
        let k = ph == 0 ? 1 - smooth(p / 0.25) : smooth(p / 0.25)
        return k < 0.5 ? "认识 → 对象 （认识符合对象）" : "对象 → 认识 （对象符合认识）"
    },
    "kant-cpr:1": { t in
        beats(t, [7, 7]).0 == 0 ? "分析：P ∈ C(S)" : "综合：P ∉ C(S)"
    },
    "kant-cpr:6": { t in
        let n = min(28, Int(fract(t / 11) * 36))
        return "我思 ⊢ r₁ … r\(n)   （\(n) / 28 已统一）"
    },
    "hegel-phen:3": { t in
        ["A ⇄ B  互求承认", "A ＞ B  主人 / 奴隶", "B → 物  劳动陶冶", "B ↑  A ↓  主奴颠倒"][beats(t, [6, 6, 7, 7]).0]
    },
    "hegel-logic:0": { t in
        abs(cos(t * 0.7)) > 0.15 ? "有 ⇄ 无" : "有 = 无  ⟹  变"
    },
    "hegel-logic:1": { t in
        let temp = Int(measureTemp(t))
        let state = temp < 0 ? "冰" : (temp < 100 ? "水" : "汽")
        let leap = abs(temp) <= 2 || abs(temp - 100) <= 2
        return "T = \(temp) °C  →  \(state)\(leap ? "   质变！" : "   量变")"
    },
    "russell-pm:0": { t in
        let speed = 0.4
        return sin(t * speed * 2) > 0 ? "R ∈ R  ⟹  R ∉ R" : "R ∉ R  ⟹  R ∈ R"
    },
]
