import Foundation

struct SavedQuizResult: Codable, Identifiable, Equatable {
    let id: UUID
    let quizID: String
    let quizTitle: String
    let name: String
    let description: String
    let image: String
    let completedAt: Date
}
