import SwiftUI

struct HomeTitleBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choisis ton thème")
                .font(AppTheme.display(size: 34))
                .foregroundStyle(HomeTheme.ink)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("home.title")

            Text("10 questions, une révélation.")
                .font(.system(size: 14))
                .foregroundStyle(QuizTheme.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeTitleBlock()
        .padding(20)
        .background { HomeBackground() }
}
