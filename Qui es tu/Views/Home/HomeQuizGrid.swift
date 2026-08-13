import SwiftUI

struct HomeQuizGrid: View {
    let quizzes: [Quizz]
    let onSelect: (Quizz) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(quizzes) { quiz in
                QuizCard(quiz: quiz) {
                    onSelect(quiz)
                }
            }
        }
        .padding(20)
    }
}
