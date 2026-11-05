import Foundation
import StoreKit
import StoreKitTest
import Testing
@testable import Qui_es_tu

struct QuizAccessTests {
    private let paid = Quizz(id: "bande", title: "Bande", image: "Loup", questions: nil, matchingResults: nil,
                            resultDescriptions: nil, productID: "com.lucasamelin.quiestu.quiz.bande")

    @Test func freeQuizzesWorkBeforeStoreKitRespondsAndAdsWait() {
        let access = QuizAccess()
        #expect(access.canOpen(.empty))
        #expect(access.canOpen(paid) == false)
        #expect(access.allowsAds == false)
    }

    @Test func individualOwnershipDoesNotRemoveAds() {
        let access = QuizAccess(isResolved: true, productIDs: [paid.productID!])
        #expect(access.canOpen(paid))
        #expect(access.isPremium == false)
        #expect(access.allowsAds)
    }

    @Test func premiumGrantsCatalogueAndExpiryRetainsOwnedQuiz() {
        var access = QuizAccess(isResolved: true, productIDs: [CommerceConfiguration.premiumID, paid.productID!])
        #expect(access.isPremium)
        #expect(access.allowsAds == false)
        var other = paid
        other.productID = "other"
        #expect(access.canOpen(other))
        access.productIDs.remove(CommerceConfiguration.premiumID)
        #expect(access.canOpen(paid))
        #expect(access.canOpen(other) == false)
        #expect(access.allowsAds)
    }

    @Test func legacyQuizzesDecodeAsFreeAndFutureReleasesStayHidden() throws {
        let old = Data(#"{"id":"animals","title":"Animaux","image":"Lynx"}"#.utf8)
        let decoded = try JSONDecoder().decode(Quizz.self, from: old)
        #expect(decoded.productID == nil)
        #expect(decoded.isReleased())
        var scheduled = paid
        scheduled.releasedAt = Date(timeIntervalSince1970: 2000)
        #expect(scheduled.isReleased(at: Date(timeIntervalSince1970: 1999)) == false)
        #expect(scheduled.isReleased(at: Date(timeIntervalSince1970: 2000)))
    }

    @MainActor @Test func portraitsPersistLocallyAndCanBeDeleted() throws {
        let suite = "CommerceTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let history = ResultHistoryStore(defaults: defaults)
        history.save(quiz: paid, result: QuizResult(name: "Le refuge", description: "Au calme"))
        let reopened = ResultHistoryStore(defaults: defaults)
        #expect(reopened.results.count == 1)
        #expect(reopened.results.first?.name == "Le refuge")
        reopened.clear()
        #expect(ResultHistoryStore(defaults: defaults).results.isEmpty)
    }

    @MainActor @Test func paidQuizReplayRetainsDownloadedQuestions() {
        var downloaded = paid
        // Reconstruct content with the same metadata-only catalogue entry.
        downloaded = Quizz(id: paid.id, title: paid.title, image: paid.image,
                           questions: [.init(number: 1, question: "Test", answers: [1: "Oui"])],
                           matchingResults: ["Loup": [1]], resultDescriptions: ["Loup": "Test"], productID: paid.productID)
        let store = QuizzStore(quizzes: [paid])
        store.setDownloadedQuiz(downloaded)
        store.selectAnswer(answerNumber: 1)
        store.validateAnswer()
        store.restartQuizz()
        #expect(store.questionCount == 1)
        #expect(store.isQuizzFinished == false)
        #expect(store.userAnswers.isEmpty)
    }
}

@Suite(.serialized) @MainActor
struct StoreKitIntegrationTests {
    let session: SKTestSession
    let quizID = "com.lucasamelin.quiestu.quiz.bande"

    init() throws {
        session = try SKTestSession(configurationFileNamed: "Pilot")
        session.resetToDefaultState()
        session.storefront = "FRA"
        session.locale = Locale(identifier: "fr_FR")
        session.disableDialogs = true
        session.clearTransactions()
    }

    @Test func verifiedOwnershipSurvivesStoreRecreationAndRefundRemovesIt() async throws {
        let transaction = try await session.buyProduct(identifier: quizID)
        await transaction.finish()
        let first = PurchaseStore(storeKitEnabled: true)
        await first.refreshEntitlements()
        #expect(first.access.productIDs.contains(quizID))
        #expect(first.access.allowsAds)
        let restored = PurchaseStore(storeKitEnabled: true)
        await restored.refreshEntitlements()
        #expect(restored.access.productIDs.contains(quizID))
        try session.refundTransaction(identifier: UInt(transaction.id))
        try await waitForEntitlements(restored) { !$0.productIDs.contains(quizID) }
        #expect(restored.access.productIDs.contains(quizID) == false)
    }

    @Test func subscriptionExpiryKeepsIndividualPurchaseAndRestoresAdEligibility() async throws {
        let individual = try await session.buyProduct(identifier: quizID)
        await individual.finish()
        let premium = try await session.buyProduct(identifier: CommerceConfiguration.premiumID)
        await premium.finish()
        let store = PurchaseStore(storeKitEnabled: true)
        await store.refreshEntitlements()
        #expect(store.access.isPremium)
        #expect(store.access.allowsAds == false)
        try session.disableAutoRenewForTransaction(identifier: UInt(premium.id))
        try session.expireSubscription(productIdentifier: CommerceConfiguration.premiumID)
        try await waitForEntitlements(store) { !$0.isPremium }
        #expect(store.access.isPremium == false)
        #expect(store.access.productIDs.contains(quizID))
        #expect(store.access.allowsAds)
    }

    @Test(arguments: ["fr_FR", "en_US"])
    func loadsMonthlyAndIndividualLocalizedProducts(locale: String) async throws {
        session.locale = Locale(identifier: locale)
        let quiz = Quizz(id: "bande", title: "Bande", image: "Loup", questions: nil,
                         matchingResults: nil, resultDescriptions: nil, productID: quizID)
        let store = PurchaseStore(storeKitEnabled: true)
        await store.loadProducts(for: [quiz])
        let subscription = try #require(store.products[CommerceConfiguration.premiumID])
        // The paywall uses Apple's localized string, never a manually formatted Decimal.
        let displayPrice = subscription.displayPrice.filter { !$0.isWhitespace }
        #expect(displayPrice == (locale == "fr_FR" ? "1,99€" : "€1.99"))
        #expect(subscription.subscription?.subscriptionPeriod.unit == .month)
        let individual = try #require(store.products[quizID])
        let individualDisplayPrice = individual.displayPrice.filter { !$0.isWhitespace }
        #expect(individualDisplayPrice == (locale == "fr_FR" ? "0,99€" : "€0.99"))
    }

    // External refunds and expiry reach StoreKit asynchronously after the test API returns.
    private func waitForEntitlements(_ store: PurchaseStore, matching predicate: (QuizAccess) -> Bool) async throws {
        for _ in 0..<50 {
            await store.refreshEntitlements()
            if predicate(store.access) { return }
            try await Task.sleep(for: .milliseconds(100))
        }
    }
}
