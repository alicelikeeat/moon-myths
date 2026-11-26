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
            sleep(2)
            let after = (toggle.value as? String) ?? ""
            print("ROUND \(round): before=\(before) after=\(after) value=\(toggle.value ?? "-")")
            if before == after { failures += 1 }
            if round == 5 { sleep(7); print("AFTER AUTO-COLLAPSE: play=\(play.exists)") }
        }
        // 展开后点倍速以外的播放键，面板不应立刻收起
        if (toggle.value as? String) != "expanded" { toggle.tap(); sleep(1) }
        play.tap(); sleep(1)
        print("AFTER PLAY TAP: value=\(toggle.value ?? "-")")
        if (toggle.value as? String) != "expanded" { failures += 1 }
        XCTAssertEqual(failures, 0, "有 \(failures) 次点击没有生效")
    }
}
