import StoreKit
import SwiftUI

struct PaywallQuizOffer: View {
    let title: String
    let product: Product?
    let isBusy: Bool
    let onPurchase: () -> Void
    var previewPrice: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Seulement ce quiz ?")
                .font(.headline)
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text("Achat unique, accès permanent et replays inclus. Les publicités restent affichées sur l’accueil et les résultats. Seul Premium supprime les publicités.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let price = previewPrice ?? product?.displayPrice {
                Button("Acheter ce quiz · \(price)", action: onPurchase)
                    .buttonStyle(.bordered)
                    .disabled(isBusy || (previewPrice == nil && !CommerceConfiguration.purchasesEnabled))
                    .accessibilityIdentifier("paywall.buyQuiz")
            } else {
                Text("Ce quiz n’est pas encore disponible à l’achat.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(HomeTheme.surface, in: .rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(HomeTheme.settingsBorder)
        }
    }
}
