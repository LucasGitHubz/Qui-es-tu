//
//  Qui_es_tuUITestsLaunchTests.swift
//  Qui es tuUITests
//
//  Created by Lucas on 20/12/2024.
//

import XCTest

final class Qui_es_tuUITestsLaunchTests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        XCTAssertTrue(app.staticTexts["home.title"].waitForExistence(timeout: 5))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Modernized Home"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
