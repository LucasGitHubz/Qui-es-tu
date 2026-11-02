import SwiftUI

struct QuizProgressStyle: ProgressViewStyle {
    let questionCount: Int

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<max(questionCount, 1), id: \.self) { index in
                Capsule()
                    .fill(
                        Double(index) < (configuration.fractionCompleted ?? 0) * Double(questionCount)
                            ? QuizTheme.accent : QuizTheme.border
                    )
            }
        }
        .frame(height: 6)
    }
}
