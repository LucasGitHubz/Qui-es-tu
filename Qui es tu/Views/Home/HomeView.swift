import SwiftUI

struct HomeView: View {
    let quizzes: [Quizz]
    let onSelect: (Quizz) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeHeader()
                    .padding(.top, 14)

                HomeTitleBlock()
                    .padding(.top, 18)

                if let featuredQuiz {
                    FeaturedQuizCard(quiz: featuredQuiz) {
                        onSelect(featuredQuiz)
                    }
                    .padding(.top, 18)
                }

                Text("Tous les thèmes")
                    .font(AppTheme.display(size: 17, weight: .bold))
                    .foregroundStyle(AppTheme.ink)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 22)
                    .padding(.bottom, 12)

                HomeQuizGrid(quizzes: gridQuizzes, onSelect: onSelect)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background {
            HomeBackground()
        }
    }

    /// Quiz of the day, picked deterministically from the current date.
    private var featuredQuiz: Quizz? {
        guard !quizzes.isEmpty else {
            return nil
        }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0

        return quizzes[dayOfYear % quizzes.count]
    }

    private var gridQuizzes: [Quizz] {
        guard let featuredQuiz else {
            return quizzes
        }

        return quizzes.filter { $0.id != featuredQuiz.id }
    }
}

#if DEBUG
#Preview {
    HomeView(quizzes: Quizz.previewCatalog) { _ in }
}
#endif
