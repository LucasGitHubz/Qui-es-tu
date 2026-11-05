import SwiftUI

struct PaywallBenefits: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("QUI ES-TU ? PREMIUM")
                .font(.subheadline.weight(.heavy))
                .tracking(3)
                .foregroundStyle(PaywallTheme.accent)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("paywall.title")

            VStack(alignment: .leading, spacing: 8) {
                PaywallBenefitRow(title: "Tous les quiz débloqués", symbol: "lock.open")
                PaywallBenefitRow(title: "Un nouveau quiz chaque semaine", symbol: "calendar")
                PaywallBenefitRow(title: "Zéro publicité, juste du fun", symbol: "megaphone")
                PaywallBenefitRow(title: "Un café pour le développeur solo", symbol: "cup.and.saucer")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
