#if DEBUG
import SwiftUI

struct DebugPaidQuizCard: View {
    let onSelect: (Quizz) -> Void

    var body: some View {
        Button {
            onSelect(DebugCommercePreview.quiz)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quiz payant de démonstration")
                        .font(.headline)
                    Text("Ton pouvoir secret · 0,99 €")
                        .font(.subheadline)
                    Text("DEBUG · Aucun paiement réel")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(HomeTheme.surface, in: .rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(HomeTheme.settingsBorder)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("home.debugPaidQuiz")
    }
}
#endif
