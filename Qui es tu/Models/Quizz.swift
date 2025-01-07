//
//  Quizz.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import Foundation

struct Quizz: Codable, Identifiable, Equatable {
    static func == (lhs: Quizz, rhs: Quizz) -> Bool {
        lhs.id == rhs.id
    }
    
    struct Question: Codable {
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
}
