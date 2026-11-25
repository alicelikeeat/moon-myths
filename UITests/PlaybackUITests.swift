import XCTest

/// 复现录屏里的操作：展开 → 收起 → 等自动收起 → 反复点开
final class PlaybackUITests: XCTestCase {
    func testToggleButtonKeepsWorking() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-book", "lunyu", "-startChapter", "1", "-appearance", "light"]
        app.launch()
        let toggle = app.buttons["playback.toggle"]
        let play = app.buttons["playback.play"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 15))

        for round in 1...6 {
            toggle.tap()
            XCTAssertTrue(play.waitForExistence(timeout: 3), "第 \(round) 次点击后没有展开")
            add(XCTAttachment(screenshot: app.screenshot()))
            if round % 2 == 0 {
                // 等待自动收起
                let gone = NSPredicate(format: "exists == false")
                expectation(for: gone, evaluatedWith: play)
                waitForExpectations(timeout: 9)
            } else {
                toggle.tap()
                let gone = NSPredicate(format: "exists == false")
                expectation(for: gone, evaluatedWith: play)
                waitForExpectations(timeout: 3)
            }
        }
        // 暂停 / 继续 也要能用
        toggle.tap()
        XCTAssertTrue(play.waitForExistence(timeout: 3))
        play.tap()
        play.tap()
        add(XCTAttachment(screenshot: app.screenshot()))
    }
}
