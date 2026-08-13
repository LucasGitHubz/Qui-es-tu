//
//  QuizzStoreTests.swift
//  Qui es tuTests
//
//  Created by Lucas on 02/01/2025.
//

import XCTest
@testable import Qui_es_tu

@MainActor
final class QuizzStoreTests: XCTestCase {
    func testLoadQuizzesSuccess() async {
        let quizzes = [makeQuiz(id: "1")]
        let mockService = MockFirestoreService(result: .success(quizzes))
        let store = QuizzStore(firestoreService: mockService)

        await store.loadQuizzes()

        XCTAssertFalse(store.isFetchingQuizzes)
        XCTAssertEqual(store.quizzList, quizzes)
        XCTAssertFalse(store.showAlert)
    }

    func testLoadQuizzesFailureEndsLoadingAndShowsAlert() async {
        let error = NSError(domain: "test", code: 1)
        let mockService = MockFirestoreService(result: .failure(error))
        let store = QuizzStore(firestoreService: mockService)

        await store.loadQuizzes()

        XCTAssertFalse(store.isFetchingQuizzes)
        XCTAssertTrue(store.showAlert)
        XCTAssertFalse(store.errorMessage.isEmpty)
    }

    func testSuccessfulRetryClearsPreviousError() async {
        let mockService = MockFirestoreService(
            result: .failure(NSError(domain: "test", code: 1))
        )
        let store = QuizzStore(firestoreService: mockService)
        await store.loadQuizzes()

        mockService.result = .success([makeQuiz(id: "1")])
        await store.loadQuizzes()

        XCTAssertFalse(store.showAlert)
        XCTAssertTrue(store.errorMessage.isEmpty)
    }

    func testSetQuizzFound() {
        let quiz = makeQuiz(id: "1")
        let store = QuizzStore(quizzes: [quiz])

        store.setQuizz(id: "1")

        XCTAssertEqual(store.quizz.id, "1")
    }

    func testSetQuizzNotFoundUsesEmptyQuiz() {
        let store = QuizzStore(quizzes: [makeQuiz(id: "1")])

        store.setQuizz(id: "2")

        XCTAssertEqual(store.quizz.id, "")
    }

    func testGetQuestionWithQuestions() {
        let quiz = makeQuiz(id: "1", questionCount: 1)
        let store = QuizzStore(quizzes: [quiz])
        store.setQuizz(id: quiz.id)

        let question = store.getQuestion()

        XCTAssertEqual(question.number, 1)
    }

    func testGetQuestionWithoutQuestionsReturnsEmptyQuestion() {
        let store = QuizzStore()

        let question = store.getQuestion()

        XCTAssertEqual(question.number, 0)
    }

    func testSelectAnswerAppendsNewAnswer() {
        let store = preparedStore(questionCount: 1)

        store.selectAnswer(answerNumber: 1)

        XCTAssertEqual(store.userAnswers, [1])
    }

    func testSelectAnswerReplacesExistingAnswer() {
        let store = preparedStore(questionCount: 1)
        store.selectAnswer(answerNumber: 1)

        store.selectAnswer(answerNumber: 2)

        XCTAssertEqual(store.userAnswers, [2])
    }

    func testIsAnswerSelectedReturnsTrueForSelection() {
        let store = preparedStore(questionCount: 1)
        store.selectAnswer(answerNumber: 2)

        let isSelected = store.isAnswerSelected(2)

        XCTAssertTrue(isSelected)
    }

    func testIsAnswerSelectedReturnsFalseForAnotherAnswer() {
        let store = preparedStore(questionCount: 1)
        store.selectAnswer(answerNumber: 1)

        let isSelected = store.isAnswerSelected(2)

        XCTAssertFalse(isSelected)
    }

    func testIsAnswerSelectedReturnsFalseWithoutAnswers() {
        let store = preparedStore(questionCount: 1)

        let isSelected = store.isAnswerSelected(1)

        XCTAssertFalse(isSelected)
    }

    func testValidateAnswerIncrementsIndex() {
        let store = preparedStore(questionCount: 2)
        store.selectAnswer(answerNumber: 1)

        store.validateAnswer()

        XCTAssertEqual(store.questionIndex, 1)
    }

    func testValidateAnswerUsesActualQuestionCountToFinish() {
        let store = preparedStore(questionCount: 1)
        store.selectAnswer(answerNumber: 1)

        store.validateAnswer()

        XCTAssertTrue(store.isQuizzFinished)
        XCTAssertTrue(store.isLoadingResult)
    }

    func testCalculateBestMatch() {
        let quiz = Quizz(
            id: "1",
            title: "Quiz",
            image: "",
            questions: [makeQuestion(number: 1)],
            matchingResults: ["Dog": [1], "Cat": [2]],
            resultDescriptions: ["Dog": "Friendly", "Cat": "Cute"]
        )
        let store = QuizzStore(quizzes: [quiz])
        store.setQuizz(id: quiz.id)
        store.selectAnswer(answerNumber: 2)

        store.calculateBestMatch()

        XCTAssertEqual(store.bestMatchResult, QuizResult(name: "Cat", description: "Cute"))
    }

    func testResetQuizzClearsSessionState() {
        let store = preparedStore(questionCount: 1)
        store.selectAnswer(answerNumber: 1)
        store.validateAnswer()

        store.resetQuizz()

        XCTAssertEqual(store.quizz.id, "")
        XCTAssertFalse(store.isQuizzFinished)
        XCTAssertEqual(store.userAnswers.count, 0)
    }

    private func preparedStore(questionCount: Int) -> QuizzStore {
        let quiz = makeQuiz(id: "quiz", questionCount: questionCount)
        let store = QuizzStore(quizzes: [quiz])
        store.setQuizz(id: quiz.id)
        return store
    }

    private func makeQuiz(id: String, questionCount: Int = 1) -> Quizz {
        Quizz(
            id: id,
            title: "Quiz",
            image: "",
            questions: (1...questionCount).map(makeQuestion),
            matchingResults: ["Result": Array(repeating: 1, count: questionCount)],
            resultDescriptions: ["Result": "Description"]
        )
    }

    private func makeQuestion(number: Int) -> Quizz.Question {
        Quizz.Question(
            number: number,
            question: "Question",
            answers: [1: "First", 2: "Second"]
        )
    }
}
