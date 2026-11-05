import SwiftUI

struct QuizQuestionCard: View {
    let question: String
    @ScaledMetric(relativeTo: .title) private var titleSize = 31

    var body: some View {
        Text(question)
            .font(AppTheme.display(size: titleSize))
            .lineLimit(4)
            .minimumScaleFactor(0.45)
            .allowsTightening(true)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("quiz.question")
            .foregroundStyle(QuizTheme.questionInk)
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
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
