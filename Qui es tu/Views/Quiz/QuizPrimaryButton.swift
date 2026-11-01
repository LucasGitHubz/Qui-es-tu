import SwiftUI

struct QuizPrimaryButton: View {
    let title: LocalizedStringKey
    let symbol: String
    var isEnabled = true
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)
                if !dynamicTypeSize.isAccessibilitySize {
                    Image(systemName: symbol)
                        .accessibilityHidden(true)
                }
            }
            .font(.headline)
            .foregroundStyle(isEnabled ? QuizTheme.actionInk : QuizTheme.secondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(isEnabled ? QuizTheme.coral : QuizTheme.border, in: .capsule)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
