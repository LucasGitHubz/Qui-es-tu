import SwiftUI

struct QuizRevealView: View {
    var body: some View {
        VStack(spacing: QuizTheme.spacing) {
            Image(systemName: "sparkles")
                .font(.largeTitle)
                .foregroundStyle(QuizTheme.questionInk)
                .frame(width: 100, height: 100)
                .background(QuizTheme.question, in: .rect(cornerRadius: 30))
                .rotationEffect(.degrees(-7))
                .accessibilityHidden(true)

            Text("Ton portrait prend forme…")
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(QuizTheme.ink)
                .accessibilityAddTraits(.isHeader)

            Text("Un peu d’instinct. Beaucoup de toi.")
                .font(.body)
                .foregroundStyle(QuizTheme.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("quiz.reveal")
    }
}
