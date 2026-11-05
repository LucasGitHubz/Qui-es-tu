import SwiftUI

struct QuizQuestionContent: View {
    let question: Quizz.Question
    let theme: String
    let questionIndex: Int
    let questionCount: Int
    let selectedAnswer: Int?
    let onSelect: (Int) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @AccessibilityFocusState private var isQuestionFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: QuizTheme.spacing) {
            VStack(spacing: 12) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(theme)
                        Spacer(minLength: 8)
                        Text("Question \(questionIndex + 1) sur \(questionCount)")
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(theme)
                        Text("Question \(questionIndex + 1) sur \(questionCount)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(QuizTheme.secondary)

                ProgressView(value: Double(questionIndex + 1), total: Double(max(questionCount, 1)))
                    .progressViewStyle(QuizProgressStyle(questionCount: questionCount))
                    .accessibilityLabel("Progression")
                    .accessibilityValue("Question \(questionIndex + 1) sur \(questionCount)")
                    .accessibilityIdentifier("quiz.progress")
            }

            QuizQuestionCard(question: question.question)
            .accessibilityFocused($isQuestionFocused)

            let answers = question.answers.sorted { $0.key < $1.key }
            let columnCount = dynamicTypeSize >= .xxxLarge ? 1 : 2
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                ForEach(0..<((answers.count + columnCount - 1) / columnCount), id: \.self) { row in
                    GridRow {
                        ForEach(0..<columnCount, id: \.self) { column in
                            let index = row * columnCount + column
                            if index < answers.count {
                                let answer = answers[index]
                                QuizAnswerCard(
                                    text: answer.value,
                                    badge: index < 26 ? String("ABCDEFGHIJKLMNOPQRSTUVWXYZ".dropFirst(index).prefix(1)) : String(index + 1),
                                    isSelected: selectedAnswer == answer.key,
                                    action: { onSelect(answer.key) }
                                )
                                .accessibilityIdentifier("quiz.answer.\(answer.key)")
                            } else {
                                Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                            }
                        }
                    }
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: selectedAnswer)
        }
        .onChange(of: questionIndex) {
            isQuestionFocused = true
        }
    }
}
