import SwiftUI

struct QuizArtwork: View {
    let source: String
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let image = QuizArtworkStore.shared.images[source] {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if URL(string: source)?.scheme != "https" {
                Image(AppAsset.name(source))
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    AppTheme.turquoise.opacity(0.2)
                    Image(systemName: "sparkles").font(.largeTitle)
                }
            }
        }
        .task(id: source) { await QuizArtworkStore.shared.load(source) }
    }
}
