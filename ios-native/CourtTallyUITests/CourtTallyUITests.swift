import XCTest

final class CourtTallyUITests: XCTestCase {
  func testSetupScoringUndoAndHistory() {
    let app = XCUIApplication()
    app.launchArguments = ["--uitesting"]
    app.launch()
    let one = app.textFields["sideOneName"]
    XCTAssertTrue(one.waitForExistence(timeout: 10))
    one.tap()
    one.typeText("Alex\n")
    let two = app.textFields["sideTwoName"]
    two.typeText("Sam\n")
    if app.buttons["Done"].exists { app.buttons["Done"].tap() }
    let start = app.buttons["startMatch"]
    if !start.isHittable { app.swipeUp() }
    start.tap()
    let score = app.buttons["scoreOne"]
    XCTAssertTrue(score.waitForExistence(timeout: 5))
    score.tap()
    XCTAssertTrue((score.value as? String)?.contains("1.") == true)
    let undo = app.buttons["undoRally"]
    if !undo.isHittable { app.swipeUp() }
    undo.tap()
    XCTAssertTrue((score.value as? String)?.contains("0.") == true)
    app.tabBars.buttons["History"].tap()
    XCTAssertTrue(app.staticTexts["Alex vs Sam"].waitForExistence(timeout: 5))
  }
  func testNativeTabsAndDataControls() {
    let app = XCUIApplication()
    app.launchArguments = ["--screenshot", "history"]
    app.launch()
    XCTAssertTrue(app.staticTexts["Alex vs Sam"].firstMatch.waitForExistence(timeout: 10))
    app.tabBars.buttons["Your data"].tap()
    XCTAssertTrue(app.buttons["Export JSON backup"].exists)
    XCTAssertTrue(app.buttons["Import JSON backup"].exists)
  }
}
