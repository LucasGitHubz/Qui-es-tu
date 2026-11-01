import SwiftUI

struct QuizHeader: View {
    let canGoBack: Bool
    let onBack: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Label(canGoBack ? "Question précédente" : "Retour", systemImage: "arrow.left")
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
                    .contentShape(.rect)
            }
            .accessibilityIdentifier("quiz.back")

            Spacer(minLength: 0)

            Text("QUI ES-TU ?")
                .font(.footnote.weight(.heavy))
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .tracking(1)
                .foregroundStyle(AppTheme.turquoise)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(AppTheme.ink, in: .capsule)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            Button(action: onClose) {
                Label("Quitter le quiz", systemImage: "xmark")
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
                    .contentShape(.rect)
            }
            .accessibilityIdentifier("quiz.close")
        }
        .buttonStyle(.plain)
        .foregroundStyle(QuizTheme.ink)
    }
}
