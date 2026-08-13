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
}
