import SwiftUI

struct HomeQuizGrid: View {
    let quizzes: [Quizz]
    var access = QuizAccess()
    var prices: [String: String] = [:]
    let onSelect: (Quizz) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(quizzes) { quiz in
                QuizCard(quiz: quiz, isUnlocked: access.canOpen(quiz), price: quiz.productID.flatMap { prices[$0] }) {
                    onSelect(quiz)
                }
            }
        }
    }
}
