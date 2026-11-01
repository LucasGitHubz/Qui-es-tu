import SwiftUI

struct QuizArtwork: View {
    let source: String

    var body: some View {
        if let url = URL(string: source), url.scheme == "https" {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    AppTheme.turquoise.opacity(0.2)
                    Image(systemName: "sparkles").font(.largeTitle)
                }
            }
        } else {
            Image(AppAsset.name(source)).resizable().scaledToFill()
        }
    }
}
