import SwiftUI

struct QuizResultHero: View {
    let result: QuizResult
    let quiz: Quizz
    let topInset: CGFloat
    let onClose: () -> Void
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 38
    @AccessibilityFocusState private var isTitleFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                Text(quiz.displayTitle.uppercased())
                    .font(.caption.bold())
                    .tracking(1.5)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Button(action: onClose) {
                    Label("Fermer", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                        .font(.body.bold())
                        .frame(width: 44, height: 44)
                        .background(.black.opacity(0.35), in: .circle)
                        .contentShape(.circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Fermer")
                .accessibilityIdentifier("quiz.close")
            }

            QuizArtwork(source: quiz.resultImages?[result.name] ?? result.name, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                }
                .accessibilityHidden(false)
                .accessibilityLabel("Portrait de \(result.name)")
                .accessibilityIdentifier("quiz.result.artwork")

            Text(result.name)
                .font(AppTheme.display(size: titleSize))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("quiz.result")
                .accessibilityFocused($isTitleFocused)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .padding(.top, topInset + 16)
        .padding(.bottom, 50)
        .background {
            GeometryReader { geometry in
                let pull = max(0, geometry.frame(in: .scrollView).minY)
                Color.clear
                    .overlay {
                        QuizArtwork(source: quiz.resultImages?[result.name] ?? result.name)
                            .blur(radius: 24)
                            .overlay(.black.opacity(0.35))
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height + pull)
                    .clipped()
                    .offset(y: -pull)
                    .accessibilityHidden(true)
            }
        }
        .task { isTitleFocused = true }
    }
}
