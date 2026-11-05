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
    @ObservationIgnored private var hasStartedSDK = false
#if DEBUG
    @ObservationIgnored private var hasResetTestConsent = false
    private(set) var debugStatus = "En attente de la préparation des annonces."
    private(set) var debugBannerStatus: [String: String] = [:]
#endif

    var bannerID: String? {
        guard !CommerceConfiguration.isPreviewOrTest else { return nil }
#if DEBUG
        // Development builds always use Google's sample inventory, even when
        // production delivery is disabled. No launch argument is required.
        return "ca-app-pub-3940256099942544/2934735716"
#else
        guard Bundle.main.object(forInfoDictionaryKey: "QuizAdsEnabled") as? Bool == true,
              let appID = CommerceConfiguration.string("GADApplicationIdentifier"),
              let banner = CommerceConfiguration.string("QuizBannerAdUnitID"),
              !appID.contains("3940256099942544"), !banner.contains("3940256099942544"),
              CommerceConfiguration.privacyURL != nil else { return nil }
        return banner
#endif
    }

    func prepare() async {
        guard bannerID != nil, !hasPrepared, !isPreparing else { return }
        isPreparing = true
        defer { isPreparing = false }
#if DEBUG
        debugStatus = "Vérification du consentement…"
#endif
        do {
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: consentParameters())
#if DEBUG
            debugStatus = "Présentation du consentement si nécessaire…"
#endif
            try await ConsentForm.loadAndPresentIfRequired(from: nil)
            await updateConsent()
            hasPrepared = true
        } catch {
            // Fail closed for ads; the quiz remains fully usable.
            canRequestAds = false
            isPrivacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
#if DEBUG
            recordDebugError(error, stage: "Consentement indisponible")
#endif
        }
    }

    func showPrivacyOptions() async {
        guard !isPreparing else { return }
        isPreparing = true
        defer { isPreparing = false }
        message = nil
        canRequestAds = false
        consentRevision += 1
        do {
            try await ConsentForm.presentPrivacyOptionsForm(from: nil)
            await updateConsent()
        } catch {
            message = "Les préférences publicitaires sont indisponibles. Réessaie plus tard."
#if DEBUG
            recordDebugError(error, stage: "Préférences indisponibles")
#endif
        }
    }

    private func updateConsent() async {
        isPrivacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        guard ConsentInformation.shared.canRequestAds else {
            canRequestAds = false
#if DEBUG
            debugStatus = "Le service de consentement n’autorise pas encore les annonces."
#endif
            return
        }
        // Configure and start before exposing banner eligibility to SwiftUI.
        // This also covers consent granted later from the privacy options screen.
        if !hasStartedSDK {
#if DEBUG
            debugStatus = "Démarrage du service publicitaire…"
#endif
            MobileAds.shared.requestConfiguration.maxAdContentRating = .general
            MobileAds.shared.requestConfiguration.setPublisherFirstPartyIDEnabled(false)
            await MobileAds.shared.start()
            hasStartedSDK = true
        }
        canRequestAds = ConsentInformation.shared.canRequestAds
#if DEBUG
        debugStatus = canRequestAds ? "Service publicitaire prêt." : "Annonces non autorisées par le consentement."
#endif
    }

#if DEBUG
    func recordDebugBannerStatus(_ status: String, placement: String) {
        debugBannerStatus[placement] = status
        print("[Ads] \(placement): \(status)")
    }

    func retryDebugAds() async {
        guard !isPreparing else { return }
        // Retry the network requests without erasing the user's consent choices.
        hasPrepared = false
        canRequestAds = false
        consentRevision += 1
        debugBannerStatus.removeAll()
        await prepare()
    }

    private func recordDebugError(_ error: Error, stage: String) {
        let details = error as NSError
        debugStatus = "\(stage) : \(details.localizedDescription) (\(details.domain), \(details.code))"
        print("[Ads] \(debugStatus)")
    }
#endif

    private func consentParameters() -> RequestParameters {
        let parameters = RequestParameters()
#if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-adTesting") {
            if arguments.contains("-adConsentReset"), !hasResetTestConsent {
                ConsentInformation.shared.reset()
                hasResetTestConsent = true
            }
            let settings = DebugSettings()
            // Simulators are UMP test devices automatically. Physical test devices
            // must supply their UMP test identifier; none is embedded in releases.
            if let id = ProcessInfo.processInfo.environment["QUI_AD_TEST_DEVICE_ID"], !id.isEmpty {
                settings.testDeviceIdentifiers = [id]
            }
            if arguments.contains("-adConsentEEA") { settings.geography = .EEA }
            parameters.debugSettings = settings
        }
#endif
        return parameters
    }
}
