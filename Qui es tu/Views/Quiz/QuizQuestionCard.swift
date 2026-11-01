import SwiftUI

struct QuizQuestionCard: View {
    let question: String
    let isLastQuestion: Bool
    @ScaledMetric(relativeTo: .title) private var titleSize = 31

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isLastQuestion ? "LA DERNIÈRE !" : "À TON INSTINCT")
                .font(.caption.bold())
                .tracking(1.5)

            Text(question)
                .font(AppTheme.display(size: titleSize))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("quiz.question")

            Text("Pas de bonne réponse. Juste la tienne.")
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(QuizTheme.questionInk)
        .frame(maxWidth: .infinity, minHeight: 154, alignment: .leading)
        .padding(QuizTheme.spacing)
        .background(QuizTheme.question, in: .rect(cornerRadius: QuizTheme.cardRadius))
        .background {
            RoundedRectangle(cornerRadius: QuizTheme.cardRadius)
                .fill(QuizTheme.questionShadow)
                .offset(y: 7)
        }
        .padding(.bottom, 7)
    }
}
