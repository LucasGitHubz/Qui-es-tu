import SwiftUI

struct QuizCard: View {
    let quiz: Quizz
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                cover

                HStack(spacing: 8) {
                    Text(quiz.displayTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text("→")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.turquoiseAccent)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
            }
            .background(.white)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: AppTheme.ink.opacity(0.08), radius: 7, y: 4)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(quiz.title)
        .accessibilityIdentifier("home.quiz.\(quiz.id)")
    }

    private var cover: some View {
        Color.clear
            .frame(height: 96)
            .overlay {
                Image(quiz.image)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 14) {
        QuizCard(quiz: Quizz.previewCatalog[0]) {}
        QuizCard(quiz: Quizz.previewCatalog[5]) {}
    }
    .padding(20)
    .background { HomeBackground() }
}
#endif
