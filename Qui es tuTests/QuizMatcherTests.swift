import XCTest
@testable import Qui_es_tu

final class QuizMatcherTests: XCTestCase {
    func testBestMatchReturnsHighestScore() {
        let result = QuizMatcher.bestMatch(
            userAnswers: [2, 2, 2],
            matchingResults: [
                "Dog": [1, 2, 3],
                "Cat": [2, 2, 1]
            ],
            resultDescriptions: [
                "Dog": "Friendly",
                "Cat": "Curious"
            ]
        )

        XCTAssertEqual(result, QuizResult(name: "Cat", description: "Curious"))
    }

    func testBestMatchBreaksTiesDeterministicallyByName() {
        let result = QuizMatcher.bestMatch(
            userAnswers: [1],
            matchingResults: [
                "Zebra": [1],
                "Ant": [1]
            ],
            resultDescriptions: [
                "Zebra": "Striped",
                "Ant": "Persistent"
            ]
        )

        XCTAssertEqual(result?.name, "Ant")
    }

    func testBestMatchReturnsNilWhenThereAreNoResults() {
        let result = QuizMatcher.bestMatch(
            userAnswers: [1],
            matchingResults: [:],
            resultDescriptions: [:]
        )

        XCTAssertNil(result)
    }
}
