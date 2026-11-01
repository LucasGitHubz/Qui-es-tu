import Foundation

/// Built only from verified StoreKit current entitlements, never from UserDefaults.
struct QuizAccess: Equatable {
    var isResolved = false
    var productIDs: Set<String> = []

    var isPremium: Bool { productIDs.contains(CommerceConfiguration.premiumID) }
    var allowsAds: Bool { isResolved && !isPremium }

    func canOpen(_ quiz: Quizz) -> Bool {
        guard let productID = quiz.productID else { return true }
        return isResolved && (isPremium || productIDs.contains(productID))
    }
}
