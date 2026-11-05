import Foundation
import Testing
@testable import Qui_es_tu

@MainActor
struct PaidQuizCacheTests {
    private let quiz = Quizz(id: "paid", title: "Paid", image: "Lynx",
                             questions: [.init(number: 1, question: "Question", answers: [1: "Oui"])],
                             matchingResults: ["Lynx": [1]], resultDescriptions: ["Lynx": "Portrait"],
                             productID: "com.lucasamelin.quiestu.quiz.paid")

    @Test func ownedQuizOpensFromDiskAfterRelaunchButRefundedOrUnresolvedAccessCannotOpenIt() async throws {
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let access = QuizAccess(isResolved: true, productIDs: [quiz.productID!])
        let cache = PaidQuizStore(directory: directory) { quiz, _ in quiz }
        _ = try await cache.prepare(quiz, access: access, proof: "verified-test-proof")
        let reopened = PaidQuizStore(directory: directory) { _, _ in
            Issue.record("Opening a downloaded quiz must not re-fetch its content")
            throw URLError(.notConnectedToInternet)
        }
        #expect(reopened.cachedQuiz(for: quiz, access: access) == quiz)
        #expect(try await reopened.prepare(quiz, access: access, proof: "verified-test-proof") == quiz)
        #expect(reopened.cachedQuiz(for: quiz, access: QuizAccess()) == nil)
        #expect(reopened.cachedQuiz(for: quiz, access: QuizAccess(isResolved: true)) == nil)
        await #expect(throws: PaidQuizService.PaidQuizError.self) {
            try await reopened.prepare(quiz, access: QuizAccess(isResolved: true), proof: "old-proof")
        }
    }

    @Test func tapJoinsHomePrefetchInsteadOfStartingASecondPaidDownload() async throws {
        let started = DownloadGate()
        let release = DownloadGate()
        let calls = DownloadCounter()
        let access = QuizAccess(isResolved: true, productIDs: [quiz.productID!])
        let cache = PaidQuizStore(directory: nil) { quiz, _ in
            await calls.increment()
            await started.open()
            await release.wait()
            return quiz
        }
        let prefetch = Task { try await cache.prepare(quiz, access: access, proof: "verified-test-proof", refresh: true) }
        await started.wait()
        let tap = Task { try await cache.prepare(quiz, access: access, proof: "verified-test-proof") }
        await release.open()
        #expect(try await prefetch.value == quiz)
        #expect(try await tap.value == quiz)
        #expect(await calls.value == 1)
        #expect(cache.cachedQuiz(for: quiz, access: access) == quiz)
    }
}
