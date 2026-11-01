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
                    Label("Partager mon portrait", systemImage: "square.and.arrow.up")
                        .foregroundStyle(.white)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    PilotTelemetry.event("result_share_opened", parameters: ["quiz_id": quiz.id])
                })
            } else {
                ProgressView("Préparation du portrait…")
            }
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier("quiz.share")
        .task(id: result.name) { await render() }
    }

    private func render() async {
        let source = quiz.resultImages?[result.name] ?? result.name
        var artwork: UIImage?
        if let url = URL(string: source), url.scheme == "https" {
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            if let (data, response) = try? await URLSession.shared.data(for: request),
               (response as? HTTPURLResponse)?.statusCode == 200 {
                artwork = UIImage(data: data)
            }
        } else {
            artwork = UIImage(named: AppAsset.name(source))
        }
        guard !Task.isCancelled else { return }
        let renderer = ImageRenderer(content: ResultShareCard(
            result: result, theme: quiz.displayTitle, artwork: artwork.map { Image(uiImage: $0) }
        ))
        renderer.scale = 2
        if let image = renderer.uiImage { shareImage = Image(uiImage: image) }
    }
}
