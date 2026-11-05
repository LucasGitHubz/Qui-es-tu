import Testing
@testable import Qui_es_tu

@MainActor
struct PurchaseRefreshTests {
    @Test func foregroundRefreshKeepsOwnedQuizUnlockedUntilAnAtomicReplacementIsReady() async {
        let started = DownloadGate()
        let release = DownloadGate()
        let id = "com.lucasamelin.quiestu.quiz.familier"
        let quiz = Quizz(id: "familier", title: "Familier", image: "Lynx", questions: nil,
                         matchingResults: nil, resultDescriptions: nil, productID: id)
        var count = 0
        let store = PurchaseStore(storeKitEnabled: true) {
            count += 1
            if count > 1 {
                await started.open()
                await release.wait()
            }
            return (QuizAccess(isResolved: true, productIDs: [id]), [id: "verified-proof"])
        }
        await store.refreshEntitlements()
        let refresh = Task { await store.refreshEntitlements() }
        await started.wait()
        #expect(store.access.isResolved)
        #expect(store.access.canOpen(quiz))
        #expect(store.proof(for: quiz) == "verified-proof")
        await release.open()
        await refresh.value
        #expect(store.access.canOpen(quiz))
    }

    @Test func completedRefundRefreshRemovesAccessAndProofTogether() async {
        let id = "com.lucasamelin.quiestu.quiz.familier"
        let quiz = Quizz(id: "familier", title: "Familier", image: "Lynx", questions: nil,
                         matchingResults: nil, resultDescriptions: nil, productID: id)
        var count = 0
        let store = PurchaseStore(storeKitEnabled: true) {
            count += 1
            return count == 1
                ? (QuizAccess(isResolved: true, productIDs: [id]), [id: "verified-proof"])
                : (QuizAccess(isResolved: true), [:])
        }
        await store.refreshEntitlements()
        #expect(store.access.canOpen(quiz))
        await store.refreshEntitlements()
        #expect(store.access.canOpen(quiz) == false)
        #expect(store.proof(for: quiz) == nil)
    }
}
