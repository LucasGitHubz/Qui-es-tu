import SwiftUI

struct QuizResultContent: View {
    let result: QuizResult
    let quiz: Quizz
    let onRestart: () -> Void
    let onFinish: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    QuizResultHero(result: result, quiz: quiz, topInset: geometry.safeAreaInsets.top, onClose: onFinish)

                    VStack(alignment: .leading, spacing: 22) {
                        Text(overview)
                            .font(.body)
                            .lineSpacing(5)
                            .foregroundStyle(QuizTheme.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        ReleaseNotificationPrompt()
                        // Optional content scrolls independently of the pinned result actions.
                        QuizBanner(placement: "result")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(QuizTheme.surface, in: UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
                    .padding(.top, -24)
                }
                .frame(maxWidth: QuizTheme.maxWidth)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height + geometry.safeAreaInsets.top, alignment: .top)
            }
            .ignoresSafeArea(edges: .top)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            QuizResultActions(result: result, quiz: quiz, onRestart: onRestart, onFinish: onFinish)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .frame(maxWidth: QuizTheme.maxWidth)
                .frame(maxWidth: .infinity)
                .background(QuizTheme.surface)
        }
        .background(QuizTheme.surface.ignoresSafeArea())
    }

    private var overview: String {
        guard quiz.id == "familier", let bonus = result.description.range(of: "Son pouvoir :") else {
            return result.description
        }
        return String(result.description[..<bonus.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
