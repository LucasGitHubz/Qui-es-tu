//
//  QuizzStore.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import SwiftUI

class QuizzStore: ObservableObject {
    @Published var quizzList: [Quizz] = []
    @Published var quizz: Quizz = Quizz(id: "", title: "", image: "", questions: nil, resultDescriptions: nil)
    @Published var questionIndex = 0
    @Published var userAnswers = [Int]()
    @Published var isQuizzFinished = false
    @Published var bestMatchResult: (String, String)? = nil

    @Published var isFetchingQuizzes = false

    @Published var errorMessage = ""
    @Published var showAlert = false

    private let firestoreService: FirestoreService
    
    init(firestoreService: FirestoreService = FirestoreService()) {
        self.firestoreService = firestoreService

        getQuizzList()
    }

    func getQuizzList() {
        isFetchingQuizzes = true
        firestoreService.fetchAllQuizzes { quizzes, error in
            self.isFetchingQuizzes = false
            if let error {
                print("handle the error")
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                return
            }

            self.quizzList = quizzes ?? []
        }
        // quizzList = Quizz.fakeQuizz
    }

    func setQuizz(id: String) {
        quizz = quizzList.first(where: { $0.id == id }) ?? Quizz(id: "", title: "", image: "", questions: nil, resultDescriptions: nil)
    }

    func getQuestion() -> Quizz.Question {
        guard let questions = quizz.questions else {
            return Quizz.Question(number: 0, question: "", answers: [:])
        }
        return questions[questionIndex]
    }

    func selectAnswer(answerNumber: Int) {
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
        if userAnswers.count > questionIndex {
            // If questionIndex + 1 == 10, that means the last question has been reached.
            // In that case, end the quizz with the result.
            if (questionIndex + 1) == 10 {
                calculateBestMatch()
                isQuizzFinished = true
            } else {
                // Otherwise continue the quizz
                questionIndex += 1
            }
        }
    }

    private func calculateBestMatch() {
        // Ensure there are answers to compare
        guard let matchingResults = quizz.matchingResults,
              let resultDescriptions = quizz.resultDescriptions else {
            bestMatchResult = nil
            return
        }

        // Variable to track the best match
        var bestMatch: (name: String, matches: Int) = ("", 0)

        // Iterate through all matching results
        for (animal, answers) in matchingResults {
            // Compare user's answers with the current result
            let matchCount = zip(userAnswers, answers).filter { $0 == $1 }.count
            
            // Update the best match if this one has more matches
            if matchCount > bestMatch.matches {
                bestMatch = (name: animal, matches: matchCount)
            }
        }

        // Retrieve the description of the best match
        bestMatchResult = (bestMatch.name, resultDescriptions[bestMatch.name] ?? "Description missing...")
    }

    func resetQuizz() {
        quizz = Quizz(id: "", title: "", image: "", questions: nil, resultDescriptions: nil)
        questionIndex = 0
        userAnswers = [Int]()
        isQuizzFinished = false
        bestMatchResult = nil
    }
}
