import SwiftUI

struct QuizBackground: View {
    var body: some View {
        QuizTheme.background
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: QuizTheme.topWash, location: 0),
                        .init(color: .clear, location: 0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.65),
                        .init(color: QuizTheme.bottomWash, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}
