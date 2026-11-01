import XCTest

final class CommerceUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPremiumBenefitsAndLegalInformationRemainReachable() throws {
        let app = launchApp()
        app.buttons["home.premium"].tap()
        XCTAssertTrue(app.staticTexts["Passe à Premium"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Tous les quiz, sans publicité."].exists)
        XCTAssertTrue(app.staticTexts["Soutiens un développeur indépendant qui crée cette app en solo."].exists)
        capture(app, name: "Premium benefits")

        let restore = app.buttons["Restaurer mes achats"]
        scrollTo(restore, in: app)
        XCTAssertTrue(restore.isHittable)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Abonnement renouvelé automatiquement.")).firstMatch.exists)
        let privacy = app.buttons["Confidentialité"]
        scrollTo(privacy, in: app)
        XCTAssertTrue(privacy.isHittable)
        capture(app, name: "Premium restoration and legal information")

        privacy.tap()
        XCTAssertTrue(app.navigationBars["Confidentialité"].waitForExistence(timeout: 3))
        capture(app, name: "Privacy information")
        navigateBack(in: app)
        app.buttons["Fermer"].tap()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testCompletedQuizOffersSharingOptionalNotificationsAndSavedHistory() throws {
        let app = launchApp()
        app.buttons["home.quiz.animals"].tap()
        let next = app.buttons["quiz.validate"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        for _ in 0..<10 {
            let answer = app.buttons["quiz.answer.1"]
            scrollTo(answer, in: app)
            answer.tap()
            next.tap()
        }
        XCTAssertTrue(app.staticTexts["quiz.result"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["quiz.result"].label, "Lynx")
        capture(app, name: "Completed free quiz")

        let share = app.buttons["quiz.share"]
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        scrollTo(share, in: app)
        XCTAssertTrue(share.isHittable)
        let decline = app.buttons["Pas maintenant"]
        scrollTo(decline, in: app)
        XCTAssertTrue(app.buttons["Me prévenir des nouveautés"].exists)
        capture(app, name: "Result sharing and optional notifications")
        decline.tap()
        XCTAssertFalse(decline.exists)
        app.buttons["quiz.finish"].tap()

        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
        app.buttons["home.settings"].tap()
        XCTAssertTrue(app.switches["Me prévenir des sorties"].waitForExistence(timeout: 3))
        let history = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Historique (")).firstMatch
        scrollTo(history, in: app)
        capture(app, name: "Notification and purchase settings")
        history.tap()
        XCTAssertTrue(app.navigationBars["Mes portraits"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Lynx"].firstMatch.exists)
        capture(app, name: "Saved result history")
        navigateBack(in: app)
        app.buttons["Terminé"].tap()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-releaseNotifications.promptAnswered", "NO"]
        app.launch()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<4 where !element.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor
    private func navigateBack(in app: XCUIApplication) {
        let back = app.buttons["BackButton"]
        if back.exists {
            back.tap()
        } else {
            app.navigationBars.buttons.firstMatch.tap()
        }
    }

    @MainActor
    private func capture(_ app: XCUIApplication, name: String) {
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
    }
}
