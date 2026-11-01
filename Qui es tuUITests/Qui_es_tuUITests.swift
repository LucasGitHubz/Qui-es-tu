//
//  Qui_es_tuUITests.swift
//  Qui es tuUITests
//
//  Created by Lucas on 20/12/2024.
//

import XCTest

final class Qui_es_tuUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHomeOpensFirstQuiz() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let homeTitle = app.staticTexts["home.title"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5))

        app.buttons["home.quiz.animals"].tap()

        XCTAssertTrue(app.progressIndicators["quiz.progress"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testQuizSelectionBackExitReplayAndFinish() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        app.buttons["home.quiz.animals"].tap()

        let next = app.buttons["quiz.validate"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertFalse(next.isEnabled)
        app.buttons["quiz.answer.2"].tap()
        XCTAssertTrue(app.buttons["quiz.answer.2"].isSelected)
        next.tap()
        XCTAssertFalse(next.isEnabled)
        app.buttons["quiz.back"].tap()
        XCTAssertTrue(app.buttons["quiz.answer.2"].isSelected)

        app.buttons["quiz.close"].tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 2))
        app.alerts.buttons["Continuer le quiz"].tap()
        XCTAssertTrue(app.buttons["quiz.answer.2"].isSelected)

        for _ in 0..<10 {
            let answer = app.buttons["quiz.answer.1"]
            if !answer.isHittable { app.swipeUp() }
            answer.tap()
            next.tap()
        }
        XCTAssertTrue(app.staticTexts["quiz.result"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["quiz.result"].label, "Lynx")
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Quiz result"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        app.buttons["quiz.restart"].tap()
        XCTAssertFalse(next.isEnabled)
        XCTAssertFalse(app.buttons["quiz.answer.2"].isSelected)
        app.buttons["quiz.answer.1"].tap()
        app.buttons["quiz.close"].tap()
        app.alerts.buttons["Quitter le quiz"].tap()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))

        app.buttons["home.quiz.animals"].tap()
        for _ in 0..<10 {
            let answer = app.buttons["quiz.answer.1"]
            if !answer.isHittable { app.swipeUp() }
            answer.tap()
            next.tap()
        }
        XCTAssertTrue(app.buttons["quiz.finish"].waitForExistence(timeout: 5))
        app.buttons["quiz.finish"].tap()
        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 3))
    }
}
