//
//  Quizz.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import Foundation

struct Quizz: Codable, Identifiable, Equatable, Sendable {
    struct Question: Codable, Equatable, Sendable {
        let number: Int
        let question: String
        let answers: [Int: String]
    }

    let id: String
    let title: String
    let image: String
    let questions: [Question]?
    let matchingResults: [String: [Int]]?
    let resultDescriptions: [String: String]?

    static let empty = Quizz(
        id: "",
        title: "",
        image: "",
        questions: nil,
        matchingResults: nil,
        resultDescriptions: nil
    )

#if DEBUG
    static let previewCatalog: [Quizz] = {
        let questions = (1...10).map {
            Question(
                number: $0,
                question: "Preview question",
                answers: [1: "Answer"]
            )
        }

        return [
            Quizz(id: "animals", title: "Animaux", image: "Lynx", questions: questions, matchingResults: nil, resultDescriptions: nil),
            Quizz(id: "cities", title: "Villes", image: "Tokyo", questions: questions, matchingResults: nil, resultDescriptions: nil),
            Quizz(id: "colors", title: "Couleurs", image: "Violet", questions: questions, matchingResults: nil, resultDescriptions: nil),
            Quizz(id: "creatures", title: "Creatures", image: "Dragon", questions: questions, matchingResults: nil, resultDescriptions: nil),
            Quizz(id: "gods", title: "Dieux", image: "Zeus", questions: questions, matchingResults: nil, resultDescriptions: nil),
            Quizz(id: "weapons", title: "Apocalypse", image: "Le katana", questions: questions, matchingResults: nil, resultDescriptions: nil)
        ]
    }()
#endif
}
