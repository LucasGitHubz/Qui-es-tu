#if DEBUG
import SwiftUI

/// Local UI fixtures only: never added to the published catalogue or entitlement store.
enum DebugCommercePreview {
    static let quiz = Quizz(
        id: "debug-paid-quiz",
        title: "Ton pouvoir secret",
        image: "Dragon",
        questions: nil,
        matchingResults: nil,
        resultDescriptions: nil,
        productID: "debug.quiz.preview",
        subtitle: "Quiz fictif pour essayer l’écran d’achat"
    )
    static let quizPrice = "0,99 €"
    static let premiumPrice = "1,99 €"
}
#endif
