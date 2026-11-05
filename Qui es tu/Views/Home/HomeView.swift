import SwiftUI

struct HomeView: View {
    let quizzes: [Quizz]
    let onSelect: (Quizz) -> Void
    var onPremium: () -> Void = {}
    var onSettings: () -> Void = {}
    @Environment(PurchaseStore.self) private var purchases

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HomeHeader(isPremium: purchases.access.isPremium, onPremium: onPremium, onSettings: onSettings)
                    .padding(.top, 8)

                HomeTitleBlock()
                    .padding(.top, 18)

#if DEBUG
                DebugPaidQuizCard(onSelect: onSelect)
                    .padding(.top, 18)
#endif

                if let featuredQuiz {
                    FeaturedQuizCard(quiz: featuredQuiz, isUnlocked: purchases.access.canOpen(featuredQuiz), price: featuredQuiz.productID.flatMap { purchases.products[$0]?.displayPrice }) {
                        onSelect(featuredQuiz)
                    }
                    .padding(.top, 18)
                }

                Text("Tous les thèmes")
                    .font(AppTheme.display(size: 17, weight: .bold))
                    .foregroundStyle(HomeTheme.ink)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 22)
                    .padding(.bottom, 12)

                HomeQuizGrid(quizzes: gridQuizzes, access: purchases.access, prices: purchases.products.mapValues(\.displayPrice), onSelect: onSelect)

                QuizBanner(placement: "home")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background {
            HomeBackground()
        }
        .foregroundStyle(HomeTheme.ink)
        .tint(QuizTheme.accent)
    }

    /// Quiz of the day, picked deterministically from the current date.
    private var featuredQuiz: Quizz? {
        guard !quizzes.isEmpty else {
            return nil
        }

        if let latest = quizzes.filter({ $0.releasedAt != nil }).max(by: { ($0.releasedAt ?? .distantPast) < ($1.releasedAt ?? .distantPast) }) { return latest }

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
        .environment(PurchaseStore()).environment(AdvertisingStore())
}
#endif
