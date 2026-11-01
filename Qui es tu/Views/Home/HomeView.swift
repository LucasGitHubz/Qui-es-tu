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
                HStack {
                    HomeHeader()
                    Button("Réglages", systemImage: "gearshape", action: onSettings)
                        .labelStyle(.iconOnly)
                        .accessibilityIdentifier("home.settings")
                }
                    .padding(.top, 14)

                Button(action: onPremium) {
                    Label(purchases.access.isPremium ? "Premium · sans publicité" : "Tous les quiz, sans pub · Premium", systemImage: "sparkles")
                        .font(.subheadline.bold())
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.top, 16)
                .accessibilityIdentifier("home.premium")

                HomeTitleBlock()
                    .padding(.top, 18)

                if let featuredQuiz {
                    FeaturedQuizCard(quiz: featuredQuiz, isUnlocked: purchases.access.canOpen(featuredQuiz)) {
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

                HomeQuizGrid(quizzes: gridQuizzes, access: purchases.access, onSelect: onSelect)

                QuizBanner(placement: "home")
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
