import XCTest

final class QuizPresentationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPaidFeaturedAndGridCardsRemainDistinctFromFreeQuizzes() {
        let app = launchApp(paidCatalog: true)
        XCTAssertEqual(app.buttons["home.premium"].label, "Premium")
        XCTAssertTrue(app.buttons["home.settings"].isHittable)
        XCTAssertFalse(app.staticTexts["QUI ES-TU ?"].exists)
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
        XCTAssertTrue(app.staticTexts["paywall.title"].waitForExistence(timeout: 5))
        app.buttons["paywall.close"].tap()
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
        XCTAssertFalse(app.staticTexts["À TON INSTINCT"].exists)
        XCTAssertFalse(app.staticTexts["Pas de bonne réponse. Juste la tienne."].exists)
        XCTAssertFalse(app.staticTexts["Choisis la réponse qui te ressemble."].exists)

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
        XCTAssertFalse(app.staticTexts["TON PORTRAIT SE DÉVOILE"].exists)
        XCTAssertFalse(app.staticTexts["Un portrait qui te ressemble."].exists)
        capture("Result full subject and continuous background")
        let actionY = app.buttons["quiz.restart"].frame.minY
        app.swipeUp()
        XCTAssertTrue(app.buttons["quiz.share"].isHittable)
        XCTAssertTrue(app.buttons["quiz.finish"].isHittable)
        XCTAssertEqual(app.buttons["quiz.restart"].frame.minY, actionY, accuracy: 1)
        capture("Result scrolled with fixed bottom actions")
        app.swipeDown()
        let top = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.25))
        let pulled = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.65))
        top.press(forDuration: 0.1, thenDragTo: pulled, withVelocity: .slow, thenHoldForDuration: 2)
        capture("Result after pulling the header")
        scrollTo(app.buttons["quiz.restart"], in: app)
        XCTAssertEqual(app.buttons["quiz.restart"].label, "Rejouer")
        XCTAssertEqual(app.buttons["quiz.finish"].label, "Autres quiz")
        XCTAssertFalse(app.staticTexts["Un quiz pour s’amuser, pas un diagnostic."].exists)
        capture("Result after particle reveal")
        app.buttons["quiz.restart"].tap()
        XCTAssertFalse(next.isEnabled)
        XCTAssertFalse(app.buttons["quiz.answer.1"].isSelected)
    }

    @MainActor
    func testRemoteResultArtworkIsReadyWhenThePortraitAppears() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-uiTestingRemoteResult"]
        app.launch()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 5))
        app.buttons["home.quiz.animals"].tap()
        for _ in 0..<10 {
            let answer = app.buttons["quiz.answer.1"]
            scrollTo(answer, in: app)
            answer.tap()
            app.buttons["quiz.validate"].tap()
        }
        XCTAssertTrue(app.staticTexts["quiz.result"].waitForExistence(timeout: 18))
        XCTAssertTrue(app.images["quiz.result.artwork"].exists)
        capture("First remote result with ready artwork and seamless action area")
    }

    @MainActor
    func testOwnedQuizStaysUnlockedAcrossForegroundAndReopensFromCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-uiTestingOwnedCatalog"]
        app.launch()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 5))
        let card = app.buttons["home.quiz.creatures"]
        XCTAssertTrue(card.staticTexts["C'est parti →"].exists)
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(card.staticTexts["C'est parti →"].exists)
        XCTAssertFalse(card.staticTexts["Découvrir →"].exists)
        capture("Owned quiz after foreground entitlement refresh")
        for _ in 0..<2 {
            card.tap()
            XCTAssertTrue(app.buttons["quiz.validate"].waitForExistence(timeout: 3))
            XCTAssertFalse(app.staticTexts["Chargement du quiz…"].exists)
            app.buttons["quiz.close"].tap()
            XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
        }
    }

    @MainActor
    private func launchApp(paidCatalog: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        if paidCatalog { app.launchArguments.append("-uiTestingPaidCatalog") }
        app.launch()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 5))
        capture("Home with preloaded artwork")
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
