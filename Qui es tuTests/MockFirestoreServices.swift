//
//  MockServices.swift
//  Qui es tuTests
//
//  Created by Lucas on 02/01/2025.
//

@testable import Qui_es_tu

final class MockFirestoreService: QuizzService {
    var result: Result<[Quizz], Error>

    init(result: Result<[Quizz], Error> = .success([])) {
        self.result = result
    }

    func fetchAllQuizzes() async throws -> [Quizz] {
        try result.get()
    }
}
