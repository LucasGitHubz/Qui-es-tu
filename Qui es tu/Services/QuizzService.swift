import Foundation

protocol QuizzService {
    func fetchAllQuizzes() async throws -> [Quizz]
}
