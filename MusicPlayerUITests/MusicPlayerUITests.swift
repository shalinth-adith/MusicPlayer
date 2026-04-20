import XCTest

final class MusicPlayerUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch

    @MainActor
    func testAppLaunchShowsNowPlayingScreen() throws {
        XCTAssert(app.staticTexts["NOW PLAYING"].exists)
    }

    // MARK: - Sidebar

    @MainActor
    func testMenuButtonOpensSidebar() throws {
        app.buttons["Menu"].tap()
        XCTAssert(app.buttons["LIBRARY"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSidebarClosesOnOverlayTap() throws {
        app.buttons["Menu"].tap()
        XCTAssert(app.buttons["LIBRARY"].waitForExistence(timeout: 2))
        // Tap the dim overlay (center-right of screen, outside sidebar)
        let screen = app.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.5))
        screen.tap()
        XCTAssertFalse(app.buttons["LIBRARY"].waitForExistence(timeout: 1))
    }

    // MARK: - Navigation

    @MainActor
    func testNavigateToLibrary() throws {
        app.buttons["Menu"].tap()
        XCTAssert(app.buttons["LIBRARY"].waitForExistence(timeout: 2))
        app.buttons["LIBRARY"].tap()
        XCTAssert(app.staticTexts["LIBRARY"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testNavigateBackToNowPlaying() throws {
        // Go to Library first
        app.buttons["Menu"].tap()
        app.buttons["LIBRARY"].tap()
        XCTAssert(app.staticTexts["LIBRARY"].waitForExistence(timeout: 2))
        // Tap back chevron
        app.buttons.element(boundBy: 0).tap()
        XCTAssert(app.staticTexts["NOW PLAYING"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testNowPlayingShowsEmptyState() throws {
        XCTAssert(app.staticTexts["No song selected"].waitForExistence(timeout: 3))
    }

    // MARK: - Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
