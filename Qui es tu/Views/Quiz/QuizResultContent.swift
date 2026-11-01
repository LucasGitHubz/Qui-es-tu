import SwiftUI

struct QuizResultContent: View {
    let result: QuizResult
    let theme: String
    var image: String? = nil
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = 44

    var body: some View {
        VStack(alignment: .leading, spacing: QuizTheme.spacing) {
            VStack(alignment: .leading, spacing: 10) {
                Text("TON PORTRAIT · \(theme)")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(QuizTheme.secondary)
                Text(result.name)
                    .font(AppTheme.display(size: titleSize))
                    .foregroundStyle(QuizTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier("quiz.result")
            }

            Color.clear
                .frame(height: 250)
                .overlay {
                    QuizArtwork(source: image ?? result.name)
                }
                .clipped()
                .clipShape(.rect(cornerRadius: QuizTheme.cardRadius))
                .padding(6)
                .background(QuizTheme.surface, in: .rect(cornerRadius: QuizTheme.cardRadius + 6))
                .background {
                    RoundedRectangle(cornerRadius: QuizTheme.cardRadius + 6)
                        .fill(QuizTheme.selection)
                        .offset(y: 6)
                }
                .padding(.bottom, 6)
                .accessibilityHidden(true)

            Text(result.description)
                .font(.body)
                .lineSpacing(5)
                .foregroundStyle(QuizTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
