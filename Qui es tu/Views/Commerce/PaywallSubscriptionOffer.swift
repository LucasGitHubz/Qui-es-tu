import StoreKit
import SwiftUI

struct PaywallSubscriptionOffer: View {
    let product: Product?
    let isPremium: Bool
    let isLoading: Bool
    let isBusy: Bool
    let onSubscribe: () -> Void
    let onContinue: () -> Void
    var previewPrice: String? = nil
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 12) {
            if isPremium {
                Label("Premium est actif", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(PaywallTheme.accent)
                Button("Continuer", action: onContinue)
                    .buttonStyle(PaywallButtonStyle())
            } else {
                if let price = previewPrice ?? product?.displayPrice {
                    let layout = dynamicTypeSize.isAccessibilitySize
                        ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                        : AnyLayout(HStackLayout(spacing: 12))
                    layout {
                        Text("Premium mensuel")
                            .font(.headline.weight(.heavy))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(Text(price).font(.title2.weight(.heavy))) / mois")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("paywall.price")
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PaywallTheme.accentSurface, in: .rect(cornerRadius: 20))
                } else if isLoading {
                    ProgressView("Chargement des prix…")
                        .padding(16)
                } else {
                    Text("L’offre Premium sera bientôt disponible.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button(action: onSubscribe) {
                    HStack(spacing: 12) {
                        Text("Débloquer Premium")
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                        if !dynamicTypeSize.isAccessibilitySize {
                            Image(systemName: "arrow.right")
                                .accessibilityHidden(true)
                        }
                    }
                }
                .buttonStyle(PaywallButtonStyle())
                .disabled(isBusy || (previewPrice == nil && (product == nil || !CommerceConfiguration.purchasesEnabled)))
                .accessibilityIdentifier("paywall.subscribe")

                Text("Renouvellement automatique. Résiliable à tout moment dans les réglages de l’App Store. Accès jusqu’à la fin de la période payée.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
