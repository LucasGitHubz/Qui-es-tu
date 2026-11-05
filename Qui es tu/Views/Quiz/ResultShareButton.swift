import SwiftUI
import UIKit

struct ResultShareButton: View {
    let result: QuizResult
    let quiz: Quizz
    @State private var shareImage: Image?

    var body: some View {
        Group {
            if let shareImage {
                ShareLink(item: shareImage,
                          message: Text("Je suis \(result.name) ! Et toi ? \(CommerceConfiguration.appURL.absoluteString)"),
                          preview: SharePreview("\(quiz.displayTitle) · \(result.name)", image: shareImage)) {
                    Label(quiz.id == "familier" ? "Partager mon familier" : "Partager mon portrait", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(QuizTheme.accent, in: .rect(cornerRadius: 17))
                        .contentShape(.rect(cornerRadius: 17))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    PilotTelemetry.event("result_share_opened", parameters: ["quiz_id": quiz.id])
                })
            } else {
                ProgressView("Préparation du portrait…")
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(QuizTheme.accent, in: .rect(cornerRadius: 17))
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(QuizTheme.actionInk)
        .accessibilityIdentifier("quiz.share")
        .task(id: result.name) { await render() }
    }

    private func render() async {
        let source = quiz.resultImages?[result.name] ?? result.name
        await QuizArtworkStore.shared.load(source)
        let artwork = QuizArtworkStore.shared.images[source]
        guard !Task.isCancelled else { return }
        let renderer = ImageRenderer(content: ResultShareCard(
            result: result, theme: quiz.displayTitle, artwork: artwork.map { Image(uiImage: $0) }
        ))
        renderer.scale = 2
        if let image = renderer.uiImage { shareImage = Image(uiImage: image) }
    }
}
