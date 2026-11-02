import SwiftUI

struct QuizAnswerCard: View {
    let text: String
    let badge: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? QuizTheme.accent : QuizTheme.background)
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                    } else {
                        Text(badge)
                            .font(.caption.bold())
                    }
                }
                .foregroundStyle(isSelected ? QuizTheme.actionInk : QuizTheme.secondary)
                .frame(width: 30, height: 30)
                .accessibilityHidden(true)

                Text(text)
                    .font(.subheadline.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(QuizTheme.ink)
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 108, maxHeight: .infinity, alignment: .topLeading)
            .background(
                isSelected ? QuizTheme.selection : QuizTheme.surface,
                in: .rect(cornerRadius: QuizTheme.answerRadius)
            )
            .overlay {
                RoundedRectangle(cornerRadius: QuizTheme.answerRadius)
                    .strokeBorder(isSelected ? QuizTheme.accent : QuizTheme.border, lineWidth: 1.5)
            }
            .contentShape(.rect(cornerRadius: QuizTheme.answerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(text)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
