import XCTest

/// 复现录屏里的操作：反复点开 / 收起右上角播放按钮，中间等它自动收起
final class PlaybackUITests: XCTestCase {
    func testToggleButtonKeepsWorking() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-book", "lunyu", "-startChapter", "1", "-appearance", "light"]
        app.launch()
        let toggle = app.buttons["playback.toggle"]
        let play = app.buttons["playback.play"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 15))
        var failures = 0
        for round in 1...10 {
            let before = (toggle.value as? String) ?? ""
            toggle.tap()
            // 等状态变化（最多 12 秒；动画持续播放时 XCTest 要等界面“空闲”才读取状态，会拖慢读数），并记录响应用了多久：CI 模拟器刚启动时主线程很忙，固定等 2 秒会误判
            let t0 = Date()
            var after = before
            while Date().timeIntervalSince(t0) < 12 {
                after = (toggle.value as? String) ?? ""
                if after != before { break }
                usleep(100_000)
            }
            print("LATENCY \(round): \(String(format: "%.1f", Date().timeIntervalSince(t0)))s")
            sleep(1)
            print("ROUND \(round): before=\(before) after=\(after) value=\(toggle.value ?? "-")")
            if before == after { failures += 1 }
            if round == 5 { sleep(7); print("AFTER AUTO-COLLAPSE: play=\(play.exists)") }
        }
        // 展开后点播放键（暂停）：暂停时面板应保持展开，方便拖动
        if (toggle.value as? String) != "expanded" { toggle.tap(); sleep(2) }
        if play.waitForExistence(timeout: 5) { play.tap() }
        sleep(2)
        print("AFTER PLAY TAP: value=\(toggle.value ?? "-")")
        XCTAssertEqual(failures, 0, "有 \(failures) 次点击没有生效")
    }
}
