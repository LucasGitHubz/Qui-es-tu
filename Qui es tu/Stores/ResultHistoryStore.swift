import Foundation
import Observation

@MainActor @Observable
final class ResultHistoryStore {
    private(set) var results: [SavedQuizResult] = []
    private let defaults: UserDefaults
    private let key = "quiz.resultHistory.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let saved = try? JSONDecoder().decode([SavedQuizResult].self, from: data) {
            results = saved
        }
    }

    func save(quiz: Quizz, result: QuizResult) {
        results.insert(SavedQuizResult(
            id: UUID(), quizID: quiz.id, quizTitle: quiz.displayTitle,
            name: result.name, description: result.description,
            image: quiz.resultImages?[result.name] ?? result.name, completedAt: .now
        ), at: 0)
        results = Array(results.prefix(100))
        persist()
    }

    func clear() {
        results = []
        defaults.removeObject(forKey: key)
    }

    func delete(ids: Set<SavedQuizResult.ID>) {
        results.removeAll { ids.contains($0.id) }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(results) { defaults.set(data, forKey: key) }
    }
}
