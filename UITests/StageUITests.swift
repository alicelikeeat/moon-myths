import XCTest

/// 3D 首页的完整路径：聚焦人物 → 人物详情 → 返回 → 查看原型 → 返回 → 全景；以及未评分模式与人名语言
final class StageUITests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testRoundTableFocusPath() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-homeStyle", "table", "-home3D", "YES", "-stageSelect", "russell", "-appearance", "light", "-blindMode", "NO", "-nameLang", "zh"]
        app.launch()
        let detail = app.buttons["人物详情"]
        XCTAssertTrue(detail.waitForExistence(timeout: 30), "聚焦后应出现信息条")
        XCTAssertTrue(app.staticTexts["罗素"].exists, "信息条应显示罗素")
        detail.tap()
        let close = app.buttons["关闭"]
        XCTAssertTrue(close.waitForExistence(timeout: 10), "人物详情应打开")
        close.tap()
        XCTAssertTrue(detail.waitForExistence(timeout: 10), "关闭详情后仍保持聚焦")
        let proto = app.buttons["查看原型"]
        XCTAssertTrue(proto.exists)
        proto.tap()
        XCTAssertTrue(app.buttons["关闭"].waitForExistence(timeout: 10), "原型页应打开")
        XCTAssertTrue(app.staticTexts["据历史影像重建"].exists, "罗素的原型类型")
        app.buttons["关闭"].tap()
        let overview = app.buttons["stage.overview"]
        XCTAssertTrue(overview.waitForExistence(timeout: 10))
        overview.tap()
        let gone = NSPredicate(format: "exists == false")
        expectation(for: gone, evaluatedWith: detail)
        waitForExpectations(timeout: 10)
    }

    func testBlindModeHidesScores() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-homeStyle", "pyramid", "-home3D", "NO", "-blindMode", "YES", "-appearance", "light"]
        app.launch()
        XCTAssertTrue(app.staticTexts["未评"].firstMatch.waitForExistence(timeout: 20), "未评分模式下应显示“未评”")
        XCTAssertFalse(app.staticTexts["93"].exists, "不应出现官方分数")
    }

    func testNamesInGerman() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-homeStyle", "tree", "-home3D", "NO", "-nameLang", "de", "-blindMode", "NO", "-appearance", "light"]
        app.launch()
        XCTAssertTrue(app.staticTexts["Konfuzius"].waitForExistence(timeout: 20), "德语人名")
    }
}
