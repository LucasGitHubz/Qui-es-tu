import XCTest

final class QuizPresentationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPaidFeaturedAndGridCardsRemainDistinctFromFreeQuizzes() {
        let app = launchApp(paidCatalog: true)
        let featured = app.buttons["home.quiz.creatures"]
        XCTAssertTrue(featured.waitForExistence(timeout: 5))
        XCTAssertTrue(featured.label.contains("quiz payant"))
        capture("Featured paid badge")

        let free = app.buttons["home.quiz.animals"]
        scrollTo(free, in: app)
        XCTAssertFalse(free.label.contains("quiz payant"))
        let paid = app.buttons["home.quiz.weapons"]
        scrollTo(paid, in: app)
        XCTAssertTrue(paid.label.contains("quiz payant"))
        capture("Grid paid badge and free cards")
        paid.tap()
        XCTAssertTrue(app.staticTexts["Passe à Premium"].waitForExistence(timeout: 5))
        app.buttons["Fermer"].tap()
        scrollTo(free, in: app, upwards: false)
        free.tap()
        XCTAssertTrue(app.buttons["quiz.validate"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testMintSelectionAndParticleRevealTransition() {
        let app = launchApp()
        app.buttons["home.quiz.animals"].tap()
        let next = app.buttons["quiz.validate"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertFalse(next.isEnabled)

        for question in 0..<10 {
            let answer = app.buttons["quiz.answer.1"]
            scrollTo(answer, in: app)
            answer.tap()
            XCTAssertTrue(answer.isSelected)
            XCTAssertTrue(next.isEnabled)
            if question == 0 || question == 2 {
                capture(question == 0 ? "Mint selected answer and continue button" : "Long answer mint selection")
            }
            next.tap()
            if question == 9 {
                // Capture the display directly: no existence query that may wait
                // for the three-second animation to become idle first.
                capture("Particle reveal immediately after final answer")
            }
        }

        XCTAssertTrue(app.staticTexts["quiz.result"].waitForExistence(timeout: 8))
        XCTAssertEqual(app.staticTexts["quiz.result"].label, "Lynx")
        XCTAssertTrue(app.buttons["quiz.restart"].isHittable)
        capture("Result after particle reveal")
        app.buttons["quiz.restart"].tap()
        XCTAssertFalse(next.isEnabled)
        XCTAssertFalse(app.buttons["quiz.answer.1"].isSelected)
    }

    @MainActor
    private func launchApp(paidCatalog: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        if paidCatalog { app.launchArguments.append("-uiTestingPaidCatalog") }
        app.launch()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication, upwards: Bool = true) {
        for _ in 0..<4 where !element.isHittable {
            if upwards { app.swipeUp() } else { app.swipeDown() }
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor
    private func capture(_ name: String) {
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
