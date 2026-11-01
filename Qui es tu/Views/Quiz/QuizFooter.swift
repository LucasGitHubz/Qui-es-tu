import SwiftUI

struct QuizFooter: View {
    let isFinished: Bool
    let isAnswered: Bool
    let isLastQuestion: Bool
    let onContinue: () -> Void
    let onRestart: () -> Void
    let onFinish: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 8) {
            if isFinished {
                QuizPrimaryButton(title: "Refaire le quiz", symbol: "arrow.counterclockwise", action: onRestart)
                    .accessibilityIdentifier("quiz.restart")
                Button(action: onFinish) {
                    Text("Retour aux thèmes")
                        .font(.subheadline.bold())
                        .foregroundStyle(QuizTheme.ink)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("quiz.finish")
            } else {
                QuizPrimaryButton(
                    title: isLastQuestion ? "Découvrir mon résultat" : "Continuer",
                    symbol: "arrow.right",
                    isEnabled: isAnswered,
                    action: onContinue
                )
                .accessibilityIdentifier("quiz.validate")
                .accessibilityHint(isAnswered ? "Tu peux encore changer d’avis." : "Choisis la réponse qui te ressemble.")

                if !dynamicTypeSize.isAccessibilitySize {
                    Text(isAnswered ? "Tu peux encore changer d’avis." : "Choisis la réponse qui te ressemble.")
                        .font(.footnote)
                        .foregroundStyle(QuizTheme.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: QuizTheme.maxWidth)
        .padding(.horizontal, QuizTheme.pagePadding)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }
}
