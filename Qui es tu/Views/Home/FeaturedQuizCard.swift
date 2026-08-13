import SwiftUI

struct FeaturedQuizCard: View {
    let quiz: Quizz
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            cover
                .overlay { scrim }
                .overlay(alignment: .topLeading) { badge }
                .overlay(alignment: .bottom) { bottomRow }
                .clipShape(.rect(cornerRadius: 24))
                .shadow(color: AppTheme.coralShadow.opacity(0.25), radius: 14, y: 12)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel("Quiz du jour, \(quiz.title)")
        .accessibilityIdentifier("home.quiz.\(quiz.id)")
    }

    private var cover: some View {
        Color.clear
            .frame(height: 200)
            .overlay {
                Image(quiz.image)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
    }

    private var scrim: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0), location: 0.3),
                .init(color: .black.opacity(0.65), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var badge: some View {
        Text("QUIZ DU JOUR")
            .font(AppTheme.display(size: 11))
            .tracking(1)
            .foregroundStyle(AppTheme.ink)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(AppTheme.turquoise, in: .capsule)
            .padding(14)
    }

    private var bottomRow: some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                Text(quiz.displayTitle)
                    .font(AppTheme.display(size: 26))
                    .foregroundStyle(.white)

                if let teaser = quiz.teaser {
                    Text(teaser)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Text("C'est parti →")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(AppTheme.coralCTA, in: .capsule)
                .fixedSize()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }
}

#Preview {
    FeaturedQuizCard(quiz: Quizz.previewCatalog[3]) {}
        .padding(20)
        .background { HomeBackground() }
}
