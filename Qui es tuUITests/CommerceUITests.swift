import XCTest

final class CommerceUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPremiumBenefitsAndLegalInformationRemainReachable() throws {
        let app = launchApp()
        capture(app, name: "Home appearance and shortcut colors")
        app.buttons["home.premium"].tap()
        XCTAssertTrue(app.staticTexts["paywall.title"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Tous les quiz débloqués"].exists)
        XCTAssertTrue(app.staticTexts["Un nouveau quiz chaque semaine"].exists)
        XCTAssertTrue(app.staticTexts["Zéro publicité, juste du fun"].exists)
        XCTAssertTrue(app.staticTexts["Un café pour le développeur solo"].exists)
        XCTAssertFalse(app.staticTexts["Il y a plus d’un toi."].exists)
        XCTAssertTrue(app.buttons["paywall.close"].isHittable)
        XCTAssertTrue(app.frame.contains(app.buttons["paywall.subscribe"].frame))
        XCTAssertFalse(app.buttons["paywall.subscribe"].isEnabled)
        capture(app, name: "Premium benefits")

        let scroll = app.scrollViews.firstMatch
        scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
            .press(forDuration: 0.1, thenDragTo: scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.34)))
        XCTAssertTrue(app.buttons["paywall.close"].isHittable)
        capture(app, name: "Premium artwork beneath floating close button")

        let restore = app.buttons["Restaurer mes achats"]
        scrollTo(restore, in: app)
        XCTAssertTrue(restore.isHittable)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Renouvellement automatique.")).firstMatch.exists)
        let privacy = app.descendants(matching: .any).matching(identifier: "Confidentialité").firstMatch
        scrollTo(privacy, in: app)
        XCTAssertTrue(privacy.isHittable)
        capture(app, name: "Premium restoration and legal information")

        privacy.tap()
        if app.navigationBars["Confidentialité"].waitForExistence(timeout: 2) {
            capture(app, name: "Privacy information")
            navigateBack(in: app)
        } else {
            let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
            XCTAssertTrue(safari.wait(for: .runningForeground, timeout: 8))
            app.activate()
        }
        app.buttons["paywall.close"].tap()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testPremiumRemainsUsableWithAccessibilityText() throws {
        let app = launchApp(extraArguments: ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        app.buttons["home.premium"].tap()
        XCTAssertTrue(app.staticTexts["paywall.title"].waitForExistence(timeout: 5))
        capture(app, name: "Premium accessibility top")
        let coffee = app.staticTexts["Un café pour le développeur solo"]
        scrollTo(coffee, in: app)
        capture(app, name: "Premium accessibility benefits")
        let restore = app.buttons["Restaurer mes achats"]
        scrollTo(restore, in: app)
        let privacy = app.descendants(matching: .any).matching(identifier: "Confidentialité").firstMatch
        scrollTo(privacy, in: app)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "Conditions d’utilisation").firstMatch.isHittable)
        XCTAssertTrue(app.buttons["paywall.close"].isHittable)
        capture(app, name: "Premium accessibility footer")
        app.buttons["paywall.close"].tap()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testPaidQuizKeepsIndividualPurchaseAlternative() throws {
        let app = launchApp(extraArguments: ["-uiTestingPaidCatalog"])
        let paidQuiz = app.buttons["home.quiz.creatures"]
        scrollTo(paidQuiz, in: app)
        paidQuiz.tap()
        XCTAssertTrue(app.staticTexts["paywall.title"].waitForExistence(timeout: 5))
        let individualOffer = app.staticTexts["Seulement ce quiz ?"]
        scrollTo(individualOffer, in: app)
        XCTAssertTrue(app.staticTexts["Ce quiz n’est pas encore disponible à l’achat."].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Achat unique, accès permanent et replays inclus.")).firstMatch.exists)
        capture(app, name: "Premium individual quiz alternative")
        app.buttons["paywall.close"].tap()
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
        scrollTo(decline, in: app, above: share)
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
        let countBeforeDeletion = try XCTUnwrap(Int(history.label.filter(\.isNumber)))
        history.tap()
        XCTAssertTrue(app.navigationBars["Mes portraits"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Lynx"].firstMatch.exists)
        capture(app, name: "Saved result history")
        app.staticTexts["Lynx"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Mon portrait"].waitForExistence(timeout: 3))
        capture(app, name: "Saved portrait detail")
        app.buttons["history.delete"].tap()
        let deletePortrait = app.buttons["Supprimer le portrait"]
        XCTAssertTrue(deletePortrait.waitForExistence(timeout: 3))
        deletePortrait.tap()
        XCTAssertTrue(app.navigationBars["Mes portraits"].waitForExistence(timeout: 3))
        capture(app, name: "History after individual deletion")
        navigateBack(in: app)
        XCTAssertTrue(app.buttons["Historique (\(countBeforeDeletion - 1))"].exists)
        app.buttons["Terminé"].tap()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testDebugPaidQuizPreviewsBothOffersWithoutPurchasing() throws {
        let app = launchApp()
        let demo = app.buttons["home.debugPaidQuiz"]
        XCTAssertTrue(demo.waitForExistence(timeout: 5))
        capture(app, name: "Debug paid quiz on home")
        demo.tap()
        XCTAssertTrue(app.staticTexts["paywall.debugNotice"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["paywall.price"].label.contains("1,99"))
        let subscribe = app.buttons["paywall.subscribe"]
        scrollTo(subscribe, in: app)
        XCTAssertTrue(subscribe.isEnabled)
        subscribe.tap()
        XCTAssertTrue(app.alerts["Aperçu du paiement"].waitForExistence(timeout: 3))
        app.alerts.buttons["OK"].tap()

        let buyQuiz = app.buttons["paywall.buyQuiz"]
        scrollTo(buyQuiz, in: app)
        XCTAssertTrue(buyQuiz.label.contains("0,99"))
        XCTAssertTrue(buyQuiz.isEnabled)
        capture(app, name: "Debug quiz payment offer")
        buyQuiz.tap()
        XCTAssertTrue(app.alerts["Aperçu du paiement"].waitForExistence(timeout: 3))
        capture(app, name: "Debug payment confirmation")
        app.alerts.buttons["OK"].tap()
        app.buttons["paywall.close"].tap()
        XCTAssertTrue(demo.waitForExistence(timeout: 3))

        let banner = app.descendants(matching: .any).matching(identifier: "ads.debugBanner").firstMatch
        scrollTo(banner, in: app)
        capture(app, name: "Debug banner at bottom of home")
        XCTAssertTrue(banner.exists)
    }

    @MainActor
    private func launchApp(extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-releaseNotifications.promptAnswered", "NO"] + extraArguments
        app.launch()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication, above pinnedElement: XCUIElement? = nil) {
        func isVisible() -> Bool {
            guard element.isHittable else { return false }
            // XCTest can report scroll content as hittable behind the fixed result footer.
            guard let pinnedElement else { return true }
            return element.frame.maxY < pinnedElement.frame.minY - 16
        }
        for _ in 0..<10 {
            if isVisible() { break }
            app.swipeUp()
        }
        XCTAssertTrue(isVisible(), "The target must be visible above any pinned actions before tapping it.")
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
        let hierarchy = XCTAttachment(string: app.debugDescription)
        hierarchy.name = "\(name) hierarchy"
        hierarchy.lifetime = .keepAlways
        add(hierarchy)
    }
}
