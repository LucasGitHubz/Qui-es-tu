//
//  QuizzStoreTests.swift
//  Qui es tuTests
//
//  Created by Lucas on 02/01/2025.
//

import XCTest
@testable import Qui_es_tu

final class QuizzStoreTests: XCTestCase {
    func test_getQuizzList_success() {
        // Given (Arrange)
        let mockService = MockFirestoreService()
        mockService.quizzesToReturn = Quizz.fakeQuizz
        let store = QuizzStore(firestoreService: mockService)

        // When (Act)
        store.getQuizzList()
        
        // Then (Assert)
        XCTAssertFalse(store.isFetchingQuizzes)
        XCTAssertEqual(store.quizzList, Quizz.fakeQuizz)
    }

    func test_getQuizzList_failure() {
        let mockService = MockFirestoreService()
        mockService.errorToReturn = NSError(domain: "test", code: 1, userInfo: nil)
        let store = QuizzStore(firestoreService: mockService)
        
        store.getQuizzList()

        XCTAssertFalse(store.isFetchingQuizzes)
        XCTAssertTrue(store.showAlert)
        XCTAssertEqual(store.errorMessage, "The operation couldn’t be completed. (test error 1.)")
    }

    func test_setQuizz_found() {
        let store = QuizzStore()
        store.quizzList = [Quizz(id: "1", title: "Quiz 1", image: "", questions: nil, resultDescriptions: nil)]
        
        store.setQuizz(id: "1")
        
        XCTAssertEqual(store.quizz.id, "1")
    }

    func test_setQuizz_notFound() {
        let store = QuizzStore()
        store.quizzList = [Quizz(id: "1", title: "Quiz 1", image: "", questions: nil, resultDescriptions: nil)]
        
        store.setQuizz(id: "2")
        
        XCTAssertEqual(store.quizz.id, "")
    }

    func test_getQuestion_withQuestions() {
        let store = QuizzStore()
        store.quizz = Quizz(id: "1", title: "Quizz", image: "", questions: [Quizz.Question(number: 1, question: "Q1", answers: [:])], resultDescriptions: nil)
        store.questionIndex = 0
        
        let question = store.getQuestion()

        XCTAssertEqual(question.number, 1)
    }

    func test_getQuestion_noQuestions() {
        let store = QuizzStore()

        let question = store.getQuestion()

        XCTAssertEqual(question.number, 0)
    }

    func test_selectAnswer_appendsNewAnswer() {
        let store = QuizzStore()
        store.userAnswers = []

        store.selectAnswer(answerNumber: 1)

        XCTAssertEqual(store.userAnswers, [1])
    }

    func test_selectAnswer_replacesExistingAnswer() {
        let store = QuizzStore()
        store.userAnswers = [1]
        store.questionIndex = 0

        store.selectAnswer(answerNumber: 2)

        XCTAssertEqual(store.userAnswers, [2])
    }

    func test_isAnswerSelected_true() {
        let store = QuizzStore()
        store.userAnswers = [2]
        store.questionIndex = 0

        let isSelected = store.isAnswerSelected(2)

        XCTAssertTrue(isSelected)
    }

    func test_isAnswerSelected_false() {
        let store = QuizzStore()
        store.userAnswers = [1]
        store.questionIndex = 0

        let isSelected = store.isAnswerSelected(2)

        XCTAssertFalse(isSelected)
    }

    func test_isAnswerSelected_noAnswers() {
        let store = QuizzStore()
        store.userAnswers = []
        store.questionIndex = 0

        let isSelected = store.isAnswerSelected(1)

        XCTAssertFalse(isSelected)
    }


    func test_validateAnswer_incrementsIndex() {
        let store = QuizzStore()
        store.userAnswers = [1]
        store.questionIndex = 0

        store.validateAnswer()

        XCTAssertEqual(store.questionIndex, 1)
    }

    func test_validateAnswer_finishesQuizz() {
        let store = QuizzStore()
        store.userAnswers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        store.questionIndex = 9

        store.validateAnswer()

        XCTAssertTrue(store.isQuizzFinished)
    }

    func test_calculateBestMatch() {
        let store = QuizzStore()
        store.quizz = Quizz(id: "1", title: "Quiz", image: "", questions: nil, matchingResults: ["Dog": [1, 2, 3], "Cat": [2, 1, 2]], resultDescriptions: ["Dog": "Friendly", "Cat": "Cute"])
        // [2, 2, 2] will match one time with dog and two times with cat
        // Cat should be chosen.
        store.userAnswers = [2, 3, 1]

        store.calculateBestMatch()

        XCTAssertEqual(store.bestMatchResult?.0, "Cat")
    }

    func test_resetQuizz() {
        let store = QuizzStore()
        store.quizz = Quizz(id: "1", title: "Quiz", image: "", questions: nil, resultDescriptions: nil)
        store.isQuizzFinished = true

        store.resetQuizz()

        XCTAssertEqual(store.quizz.id, "")
        XCTAssertFalse(store.isQuizzFinished)
        XCTAssertEqual(store.userAnswers.count, 0)
    }
}
