import SwiftUI

struct SavedResultRow: View {
    let result: SavedQuizResult
    @ScaledMetric(relativeTo: .body) private var artworkSize = 64

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            QuizArtwork(source: result.image)
                .frame(width: artworkSize, height: artworkSize)
                .clipShape(.rect(cornerRadius: 16))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text(result.quizTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(result.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(result.completedAt, format: .dateTime.day().month(.wide).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}
