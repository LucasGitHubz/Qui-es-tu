import SwiftUI

struct PaywallFooter: View {
    let onRestore: () -> Void
    var isDebugPreview = false
    @Environment(PurchaseStore.self) private var purchases
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 4) {
            if !isDebugPreview && !CommerceConfiguration.purchasesEnabled && !purchases.access.isPremium {
                Text("Les achats ne sont pas encore ouverts. Les quiz gratuits restent disponibles.")
                    .font(.caption)
                    .padding(.bottom, 8)
            }
            if purchases.isBusy {
                ProgressView("Connexion à l’App Store…")
                    .padding(.bottom, 8)
            }
            if !isDebugPreview, let message = purchases.message {
                Text(message)
                    .font(.callout)
                    .padding(.bottom, 8)
                    .accessibilityIdentifier("paywall.message")
            }
            Button(action: onRestore) {
                Text("Restaurer mes achats").underline()
                    .frame(minHeight: 44)
            }
            .disabled(purchases.isBusy || isDebugPreview)

            if purchases.access.isPremium {
                Link("Gérer mon abonnement", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    .frame(minHeight: 44)
            }

            let layout = dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: 0))
                : AnyLayout(HStackLayout(spacing: 20))
            layout {
                Link("Conditions", destination: CommerceConfiguration.termsURL)
                    .frame(minHeight: 44)
                    .accessibilityLabel("Conditions d’utilisation")
                if !dynamicTypeSize.isAccessibilitySize {
                    Text("·").accessibilityHidden(true)
                }
                if let privacy = CommerceConfiguration.privacyURL {
                    Link("Confidentialité", destination: privacy)
                        .frame(minHeight: 44)
                } else {
                    NavigationLink("Confidentialité") {
                        PrivacyInformationView()
                            .toolbar(.visible, for: .navigationBar)
                    }
                    .frame(minHeight: 44)
                }
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .tint(.secondary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }
}
