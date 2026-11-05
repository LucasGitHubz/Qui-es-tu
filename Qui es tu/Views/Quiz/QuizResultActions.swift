import SwiftUI

struct QuizResultActions: View {
    let result: QuizResult
    let quiz: Quizz
    let onRestart: () -> Void
    let onFinish: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(spacing: 12))

        VStack(spacing: 12) {
            ResultShareButton(result: result, quiz: quiz)
            layout {
                QuizResultActionButton(title: "Rejouer", symbol: "arrow.counterclockwise", action: onRestart)
                    .accessibilityIdentifier("quiz.restart")
                QuizResultActionButton(title: "Autres quiz", symbol: "square.grid.2x2", action: onFinish)
                    .accessibilityIdentifier("quiz.finish")
            }
        }
    }
}
