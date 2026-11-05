import SwiftUI

struct QuizResultActionButton: View {
    let title: LocalizedStringKey
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundStyle(QuizTheme.ink)
                .background(QuizTheme.surface, in: .rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(QuizTheme.border, lineWidth: 1)
                }
                .contentShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
