import Foundation

enum CommerceConfiguration {
    static let premiumID = "com.lucasamelin.quiestu.premium.monthly"
    static let appURL = URL(string: "https://apps.apple.com/app/id6740242586")!
    static let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    static func string(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty, !value.contains("$(") else { return nil }
        return value
    }

    static func url(_ key: String) -> URL? {
        guard let value = string(key), let url = URL(string: value),
              url.scheme == "https", url.host != nil else { return nil }
        return url
    }

    static var privacyURL: URL? { url("QuizPrivacyURL") }
    static var paidContentURL: URL? { url("QuizPaidContentURL") }
    static var purchasesEnabled: Bool {
        Bundle.main.object(forInfoDictionaryKey: "QuizPurchasesEnabled") as? Bool == true
            && privacyURL != nil && paidContentURL != nil
    }

    static var isPreviewOrTest: Bool {
        let process = ProcessInfo.processInfo
        return process.arguments.contains("-uiTesting")
            || process.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
            || process.environment["XCTestConfigurationFilePath"] != nil
            || NSClassFromString("XCTestCase") != nil
    }
}
