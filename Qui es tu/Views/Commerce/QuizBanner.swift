import GoogleMobileAds
import SwiftUI

struct QuizBanner: View {
    let placement: String
    @Environment(PurchaseStore.self) private var purchases
    @Environment(AdvertisingStore.self) private var advertising

    var body: some View {
        if purchases.access.allowsAds, advertising.canRequestAds, let id = advertising.bannerID {
            BannerContainer(adUnitID: id, placement: placement)
                .id(advertising.consentRevision)
                .frame(width: 320, height: 50)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .accessibilityLabel("Publicité")
        }
    }
}

private struct BannerContainer: UIViewRepresentable {
    let adUnitID: String
    let placement: String

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

    func makeCoordinator() -> Coordinator { Coordinator(placement: placement) }

    final class Coordinator: NSObject, BannerViewDelegate {
        let placement: String
        init(placement: String) { self.placement = placement }

        func bannerViewDidRecordImpression(_ bannerView: BannerView) {
            PilotTelemetry.event("banner_impression", parameters: ["placement": placement])
        }
    }
}
