import SwiftUI

struct QuizCard: View {
    let quiz: Quizz
    var isUnlocked = true
    var price: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                cover

                HStack(spacing: 8) {
                    Text(quiz.displayTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HomeTheme.ink)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Image(systemName: isUnlocked ? "arrow.right" : "lock.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.turquoiseAccent)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
            }
            .background(HomeTheme.surface)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 7, y: 4)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(quiz.productID == nil ? quiz.title : "\(quiz.title), quiz payant, \(price ?? "prix indisponible")")
        .accessibilityIdentifier("home.quiz.\(quiz.id)")
    }

    private var cover: some View {
        Color.clear
            .frame(height: 96)
            .overlay {
                QuizArtwork(source: quiz.image)
            }
            .clipped()
            .overlay(alignment: .topTrailing) {
                if quiz.productID != nil {
                    PaidQuizBadge(price: price)
                        .padding(8)
                }
            }
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
