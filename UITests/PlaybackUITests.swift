import XCTest

/// 复现录屏里的操作：反复点开 / 收起右上角播放按钮
final class PlaybackUITests: XCTestCase {
    func testToggleButtonKeepsWorking() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-book", "lunyu", "-startChapter", "1", "-appearance", "light"]
        app.launch()
        let toggle = app.buttons["playback.toggle"]
        let play = app.buttons["playback.play"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 15))
        var failures = 0
        for round in 1...8 {
            let before = play.exists
            toggle.tap()
            sleep(2)
            let after = play.exists
            print("ROUND \(round): before=\(before) after=\(after) value=\(toggle.value ?? "-")")
            if before == after { failures += 1 }
            if round == 4 { sleep(7); print("AFTER AUTO-COLLAPSE: play=\(play.exists) value=\(toggle.value ?? "-")") }
        }
        XCTAssertEqual(failures, 0, "有 \(failures) 次点击没有切换")
    }
}
