import Foundation
import Testing
@testable import Qui_es_tu

@MainActor
struct ResultHistoryStoreTests {
    private let quiz = Quizz(id: "animals", title: "Animaux", image: "Lynx",
                             questions: nil, matchingResults: nil, resultDescriptions: nil)

    @Test func deletingOneOfTwoIdenticalPortraitsPreservesTheOtherAfterReload() throws {
        let suite = "history-deletion-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let history = ResultHistoryStore(defaults: defaults)
        let portrait = QuizResult(name: "Lynx", description: "Un portrait à conserver")
        history.save(quiz: quiz, result: portrait)
        let survivor = try #require(history.results.first)
        history.save(quiz: quiz, result: portrait)
        let deleted = try #require(history.results.first)

        history.delete(ids: [deleted.id])

        #expect(history.results == [survivor])
        #expect(ResultHistoryStore(defaults: defaults).results == [survivor])
    }

    @Test func deletingSeveralPortraitsPreservesOrderAndDeletingLastPersistsEmptyHistory() throws {
        let suite = "history-deletion-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let history = ResultHistoryStore(defaults: defaults)
        for name in ["Lynx", "Loup", "Renard", "Hibou"] {
            history.save(quiz: quiz, result: QuizResult(name: name, description: name))
        }
        let saved = history.results
        history.delete(ids: [saved[0].id, saved[2].id, UUID()])
        #expect(ResultHistoryStore(defaults: defaults).results == [saved[1], saved[3]])

        history.delete(ids: [saved[1].id, saved[3].id])
        #expect(history.results.isEmpty)
        #expect(ResultHistoryStore(defaults: defaults).results.isEmpty)
    }
}
