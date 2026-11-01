import GoogleMobileAds
import Observation
import UserMessagingPlatform

@MainActor @Observable
final class AdvertisingStore {
    private(set) var canRequestAds = false
    private(set) var isPrivacyOptionsRequired = false
    private(set) var isPreparing = false
    private(set) var consentRevision = 0
    var message: String?
    @ObservationIgnored private var hasPrepared = false

    var bannerID: String? {
        guard !CommerceConfiguration.isPreviewOrTest else { return nil }
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-adTesting") {
            return "ca-app-pub-3940256099942544/2435281174"
        }
#endif
        guard Bundle.main.object(forInfoDictionaryKey: "QuizAdsEnabled") as? Bool == true,
              let appID = CommerceConfiguration.string("GADApplicationIdentifier"),
              let banner = CommerceConfiguration.string("QuizBannerAdUnitID"),
              !appID.contains("3940256099942544"), !banner.contains("3940256099942544"),
              CommerceConfiguration.privacyURL != nil else { return nil }
        return banner
    }

    func prepare() async {
        guard bannerID != nil, !hasPrepared, !isPreparing else { return }
        isPreparing = true
        defer { isPreparing = false }
        do {
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: RequestParameters())
            try await ConsentForm.loadAndPresentIfRequired(from: nil)
            updateConsent()
            if canRequestAds {
                MobileAds.shared.requestConfiguration.maxAdContentRating = .general
                MobileAds.shared.requestConfiguration.setPublisherFirstPartyIDEnabled(false)
                await MobileAds.shared.start()
            }
            hasPrepared = true
        } catch {
            // Fail closed for ads; the quiz remains fully usable.
            canRequestAds = false
            isPrivacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        }
    }

    func showPrivacyOptions() async {
        canRequestAds = false
        consentRevision += 1
        do {
            try await ConsentForm.presentPrivacyOptionsForm(from: nil)
            updateConsent()
        } catch {
            message = "Les préférences publicitaires sont indisponibles. Réessaie plus tard."
        }
    }

    private func updateConsent() {
        canRequestAds = ConsentInformation.shared.canRequestAds
        isPrivacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
    }
}
