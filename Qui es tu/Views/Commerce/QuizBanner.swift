import GoogleMobileAds
import SwiftUI

struct QuizBanner: View {
    let placement: String
    @Environment(PurchaseStore.self) private var purchases
    @Environment(AdvertisingStore.self) private var advertising

    var body: some View {
        if purchases.access.allowsAds, advertising.canRequestAds, let id = advertising.bannerID {
            BannerContainer(adUnitID: id, placement: placement, advertising: advertising)
                .id(advertising.consentRevision)
                .frame(width: 320, height: 50)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .accessibilityLabel("Publicité")
        }
#if DEBUG
        if purchases.access.allowsAds, advertising.bannerID == nil {
            VStack(spacing: 2) {
                Text("Bannière publicitaire · DEBUG")
                    .font(.caption.weight(.semibold))
                Text("Aperçu fictif · Annonces réelles désactivées")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(.quaternary, in: .rect(cornerRadius: 8))
            .padding(.vertical, 12)
            .accessibilityIdentifier("ads.debugBanner")
        } else {
            DebugAdStatusView(placement: placement)
        }
#endif
    }
}

private struct BannerContainer: UIViewRepresentable {
    let adUnitID: String
    let placement: String
    let advertising: AdvertisingStore

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.paidEventHandler = { value in
            PilotTelemetry.event("banner_revenue", parameters: [
                "value": value.value.doubleValue, "currency": value.currencyCode,
                "placement": placement, "ad_platform": "AdMob"
            ])
        }
        let request = Request()
        let extras = Extras()
        // The pilot does not request cross-app tracking or personalized ads.
        extras.additionalParameters = ["npa": "1"]
        request.register(extras)
        banner.load(request)
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    static func dismantleUIView(_ uiView: BannerView, coordinator: Coordinator) {
        uiView.delegate = nil
        uiView.paidEventHandler = nil
        uiView.removeFromSuperview()
    }

    func makeCoordinator() -> Coordinator { Coordinator(placement: placement, advertising: advertising) }

    final class Coordinator: NSObject, BannerViewDelegate {
        let placement: String
        let advertising: AdvertisingStore
        init(placement: String, advertising: AdvertisingStore) {
            self.placement = placement
            self.advertising = advertising
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
#if DEBUG
            bannerView.accessibilityIdentifier = "ads.loaded.\(placement)"
            advertising.recordDebugBannerStatus("Bannière de test chargée.", placement: placement)
#endif
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
#if DEBUG
            let details = error as NSError
            advertising.recordDebugBannerStatus(
                "Échec du chargement : \(details.localizedDescription) (\(details.domain), \(details.code))",
                placement: placement
            )
#endif
        }

        func bannerViewDidRecordImpression(_ bannerView: BannerView) {
            PilotTelemetry.event("banner_impression", parameters: ["placement": placement])
        }
    }
}
