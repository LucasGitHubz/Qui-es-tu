//
//  MockServices.swift
//  Qui es tuTests
//
//  Created by Lucas on 02/01/2025.
//

@testable import Qui_es_tu

class MockFirestoreService: FirestoreService {
    var quizzesToReturn: [Quizz]?
    var errorToReturn: Error?
    
    override func fetchAllQuizzes(completion: @escaping ([Quizz]?, Error?) -> Void) {
        completion(quizzesToReturn, errorToReturn)
    }
}
