//
//  QuizzStore.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import Foundation
import Observation

@MainActor
@Observable
final class QuizzStore {
    private(set) var quizzList: [Quizz]
    private(set) var quizz: Quizz = .empty
    private(set) var questionIndex = 0
    private(set) var userAnswers: [Int] = []
    private(set) var isQuizzFinished = false
    private(set) var bestMatchResult: QuizResult?

    private(set) var isLoadingResult = false
    private(set) var isFetchingQuizzes = false

    private(set) var errorMessage = ""
    var showAlert = false

    private let firestoreService: any QuizzService
    private let telemetry: any AppTelemetry

    init(
        firestoreService: any QuizzService = FirestoreService(),
        quizzes: [Quizz] = [],
        telemetry: (any AppTelemetry)? = nil
    ) {
        self.firestoreService = firestoreService
        self.quizzList = quizzes
        self.telemetry = telemetry ?? NoOpTelemetry()
    }

    var questionCount: Int {
        quizz.questions?.count ?? 0
    }

    var isCurrentQuestionAnswered: Bool {
        userAnswers.indices.contains(questionIndex)
    }

    func loadQuizzesIfNeeded() async {
        guard quizzList.isEmpty else {
            return
        }

        await loadQuizzes()
    }

    func loadQuizzes() async {
        guard !isFetchingQuizzes else {
            return
        }

        isFetchingQuizzes = true
        showAlert = false
        errorMessage = ""
        defer { isFetchingQuizzes = false }

        do {
            quizzList = try await firestoreService.fetchAllQuizzes()
        } catch is CancellationError {
            return
        } catch {
            telemetry.recordQuizLoadingFailure(error)
            errorMessage = error.localizedDescription
            showAlert = true
        }
    }

    func setQuizz(id: String) {
        quizz = quizzList.first(where: { $0.id == id }) ?? .empty
        trackStart()
    }

    func setDownloadedQuiz(_ quiz: Quizz) {
        quizz = quiz
        trackStart()
    }

    private func trackStart() {
        if questionCount > 0 {
            telemetry.track(.started(quizID: quizz.id, questionCount: questionCount))
        }
    }

    func getQuestion() -> Quizz.Question {
        guard let questions = quizz.questions,
              questions.indices.contains(questionIndex) else {
            return Quizz.Question(number: 0, question: "", answers: [:])
        }

        return questions[questionIndex]
    }

    func selectAnswer(answerNumber: Int) {
        guard !isQuizzFinished, getQuestion().answers[answerNumber] != nil else { return }

        if userAnswers.count > questionIndex {
            userAnswers[questionIndex] = answerNumber
        } else {
            userAnswers.append(answerNumber)
        }
    }

    func isAnswerSelected(_ answerNumber: Int) -> Bool {
        guard userAnswers.count > questionIndex else {
            return false
        }
        return userAnswers[questionIndex] == answerNumber
    }

    func validateAnswer() {
        guard !isQuizzFinished, isCurrentQuestionAnswered, questionCount > 0 else {
            return
        }

        if questionIndex + 1 >= questionCount {
            calculateBestMatch()
            isLoadingResult = true
            isQuizzFinished = true
            telemetry.track(.completed(quizID: quizz.id, questionCount: questionCount))
        } else {
            questionIndex += 1
        }
    }

    func goToPreviousQuestion() {
        guard questionIndex > 0, !isQuizzFinished else { return }
        questionIndex -= 1
    }

    func restartQuizz() {
        let previous = quizz
        resetQuizz()
        setDownloadedQuiz(previous)
    }

    func revealResult() async {
        guard isLoadingResult else {
            return
        }

        do {
            try await Task.sleep(for: .milliseconds(1200))
            try Task.checkCancellation()
            isLoadingResult = false
        } catch {
            return
        }
    }

    func calculateBestMatch() {
        guard let matchingResults = quizz.matchingResults,
              let resultDescriptions = quizz.resultDescriptions else {
            bestMatchResult = nil
            return
        }

        bestMatchResult = QuizMatcher.bestMatch(
            userAnswers: userAnswers,
            matchingResults: matchingResults,
            resultDescriptions: resultDescriptions
        )
    }

    func resetQuizz() {
        if questionCount > 0 && !isQuizzFinished {
            telemetry.track(.exited(quizID: quizz.id, answeredCount: userAnswers.count))
        }
        quizz = .empty
        questionIndex = 0
        userAnswers = []
        isQuizzFinished = false
        isLoadingResult = false
        bestMatchResult = nil
    }
}
