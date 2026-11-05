import SwiftUI

/// A dedicated export view. Advertising and screen controls are never rendered here.
struct ResultShareCard: View {
    let result: QuizResult
    let theme: String
    let artwork: Image?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("QUI ES-TU ?").font(.headline).tracking(3)
            Text(theme).font(.title2.bold())
            if let artwork {
                artwork.resizable().scaledToFill()
                    .frame(width: 440, height: 260).clipped()
                    .clipShape(.rect(cornerRadius: 22))
            } else {
                Image(systemName: "sparkles").font(.system(size: 80))
                    .frame(width: 440, height: 200)
            }
            Text(result.name).font(.largeTitle.bold())
            Text(result.description).font(.title3).fixedSize(horizontal: false, vertical: true)
            Text("Et toi, qui es-tu ?").font(.title2.bold())
            Text("apps.apple.com/app/id6740242586").font(.subheadline)
        }
        .foregroundStyle(Color(red: 0.09, green: 0.16, blue: 0.19))
        .padding(32)
        .frame(width: 504)
        .background(Color(red: 0.84, green: 0.97, blue: 0.93))
        .environment(\.colorScheme, .light)
        .environment(\.dynamicTypeSize, .large)
    }
}
