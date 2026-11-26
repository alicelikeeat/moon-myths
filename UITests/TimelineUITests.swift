import XCTest

/// 时间轴必须能左右、上下拖动
final class TimelineUITests: XCTestCase {
    func testTimelineDrags() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-openTimeline", "-appearance", "light"]
        app.launch()
        sleep(3)
        // 打开时定位在轴心时代：孔子可见
        let kongzi = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH '孔子'")).firstMatch
        XCTAssertTrue(kongzi.waitForExistence(timeout: 5), "孔子应可见")
        let x0 = kongzi.frame.midX
        print("ROUND kongzi before x=\(x0)")
        // 向左拖：孔子往左移
        app.swipeLeft()
        sleep(1)
        let x1 = kongzi.frame.midX
        print("AFTER swipeLeft kongzi x=\(x1)")
        XCTAssertLessThan(x1, x0 - 50, "左右拖动应使时间轴移动")
        // 向上拖：数学泳道里的人物出现
        app.swipeUp()
        app.swipeUp()
        sleep(1)
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.lifetime = .keepAlways
        add(shot)
        let y0 = kongzi.frame.midY
        print("AFTER swipeUp kongzi y=\(y0)")
        XCTAssertLessThan(y0, 150, "上下拖动应使时间轴移动")
    }
}
