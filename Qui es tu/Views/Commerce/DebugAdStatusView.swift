#if DEBUG
import SwiftUI

/// Visible diagnostics for development runs, including physical devices.
struct DebugAdStatusView: View {
    let placement: String
    @Environment(PurchaseStore.self) private var purchases
    @Environment(AdvertisingStore.self) private var advertising

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Publicité de test · DEBUG")
                .font(.caption.bold())
            Text(status)
                .font(.caption)
                .textSelection(.enabled)
            if purchases.access.allowsAds, advertising.bannerID != nil {
                Button("Réessayer la bannière") {
                    Task { await advertising.retryDebugAds() }
                }
                .font(.caption)
                .disabled(advertising.isPreparing)
                .accessibilityIdentifier("ads.debugRetry")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.quaternary, in: .rect(cornerRadius: 8))
        .padding(.vertical, 12)
        .accessibilityIdentifier("ads.debugStatus")
    }

    private var status: String {
        if !purchases.access.isResolved {
            return "En attente de la vérification des achats. Les annonces restent masquées."
        }
        if purchases.access.isPremium {
            return "Premium est actif sur cet appareil : les annonces sont masquées."
        }
        if advertising.canRequestAds {
            return advertising.debugBannerStatus[placement] ?? "Chargement de la bannière Google…"
        }
        return advertising.debugStatus
    }
}
#endif
