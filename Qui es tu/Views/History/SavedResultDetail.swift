import SwiftUI

struct SavedResultDetail: View {
    let result: SavedQuizResult
    @Environment(ResultHistoryStore.self) private var history
    @Environment(\.dismiss) private var dismiss
    @State private var confirmsDeletion = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                QuizArtwork(source: result.image, contentMode: .fit)
                    .frame(maxHeight: 320)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 24))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text(result.quizTitle).font(.subheadline).foregroundStyle(.secondary)
                    Text(result.name).font(.largeTitle.bold())
                    Text(result.completedAt, format: .dateTime.day().month(.wide).year().hour().minute())
                        .font(.caption).foregroundStyle(.secondary)
                }
                Text(result.description)
                    .font(.body)
                    .textSelection(.enabled)
            }
            .padding(24)
            .frame(maxWidth: 600, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Mon portrait")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Supprimer ce portrait", systemImage: "trash", role: .destructive) {
                confirmsDeletion = true
            }
            .accessibilityIdentifier("history.delete")
        }
        .confirmationDialog("Supprimer ce portrait de cet appareil ?", isPresented: $confirmsDeletion, titleVisibility: .visible) {
            Button("Supprimer le portrait", role: .destructive) {
                history.delete(ids: [result.id])
                dismiss()
            }
        }
    }
}
