import SwiftUI

struct HomeHeader: View {
    var isPremium = false
    var onPremium: () -> Void = {}
    var onSettings: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            Button(action: onPremium) {
                Label("Premium", systemImage: "crown.fill")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(HomeTheme.premiumInk)
                    .frame(width: 44, height: 44)
                    .background(HomeTheme.premiumSurface, in: .circle)
                    .overlay {
                        Circle().strokeBorder(HomeTheme.premiumBorder, lineWidth: 1)
                    }
            }
            .accessibilityValue(isPremium ? "Actif" : "Découvrir les offres")
            .accessibilityIdentifier("home.premium")

            Button(action: onSettings) {
                Label("Réglages", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(HomeTheme.settingsInk)
                    .frame(width: 44, height: 44)
                    .background(HomeTheme.surface, in: .circle)
                    .overlay {
                        Circle().strokeBorder(HomeTheme.settingsBorder, lineWidth: 1)
                    }
            }
            .accessibilityIdentifier("home.settings")
        }
        .font(.title3.weight(.semibold))
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeHeader()
        .padding(20)
        .background { HomeBackground() }
}
