import SwiftUI

struct QuizCard: View {
    let quiz: Quizz
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(quiz.image)
                    .resizable()
                    .aspectRatio(1.5, contentMode: .fit)
                    .accessibilityHidden(true)

                Text(quiz.title)
                    .font(.headline)
                    .padding(.vertical, 10)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .background(.white)
            }
            .background(.white)
            .clipShape(.rect(cornerRadius: 18))
            .shadow(color: .black.opacity(0.2), radius: 4)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(lineWidth: 4)
                    .foregroundStyle(.white)
            }
            .padding(5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(quiz.title)
        .accessibilityIdentifier("home.quiz.\(quiz.id)")
    }
}
