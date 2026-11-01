import FirebaseMessaging
import Observation
import UIKit
import UserNotifications

@MainActor @Observable
final class ReleaseNotificationStore {
    static let shared = ReleaseNotificationStore()
    private(set) var enabled = UserDefaults.standard.bool(forKey: "releaseNotifications.enabled")
    private(set) var hasAnsweredPrompt = UserDefaults.standard.bool(forKey: "releaseNotifications.promptAnswered")
    private(set) var isBusy = false
    private(set) var authorizationDenied = false
    var pendingQuizID: String?
    var message: String?
    private let topic = "weekly_quizzes_fr"
    @ObservationIgnored private var isSynchronizing = false
    @ObservationIgnored private var needsSynchronization = false

    func dismissPrompt() {
        hasAnsweredPrompt = true
        UserDefaults.standard.set(true, forKey: "releaseNotifications.promptAnswered")
    }

    func setEnabled(_ value: Bool) async {
        guard !isBusy, !CommerceConfiguration.isPreviewOrTest else { return }
        isBusy = true
        defer { isBusy = false }
        dismissPrompt()
        if value {
            do {
                let allowed = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                guard allowed else {
                    authorizationDenied = true
                    message = "Les notifications sont désactivées dans les réglages de l’iPhone."
                    return
                }
                authorizationDenied = false
            } catch {
                message = "Impossible d’activer les notifications pour le moment."
                return
            }
        }
        enabled = value
        UserDefaults.standard.set(value, forKey: "releaseNotifications.enabled")
        if value {
            Messaging.messaging().isAutoInitEnabled = true
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Unregister immediately even if the network is unavailable for unsubscribe.
            UIApplication.shared.unregisterForRemoteNotifications()
            Messaging.messaging().isAutoInitEnabled = false
        }
        await synchronizeTopic()
    }

    func refresh() async {
        guard !CommerceConfiguration.isPreviewOrTest else { return }
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationDenied = settings.authorizationStatus == .denied
        if enabled && !authorizationDenied {
            Messaging.messaging().isAutoInitEnabled = true
            UIApplication.shared.registerForRemoteNotifications()
        }
        await synchronizeTopic()
    }

    func synchronizeTopic() async {
        guard !CommerceConfiguration.isPreviewOrTest else { return }
        needsSynchronization = true
        guard !isSynchronizing else { return }
        isSynchronizing = true
        defer { isSynchronizing = false }
        while needsSynchronization {
            needsSynchronization = false
            // APNs registration completes asynchronously; token delegate retries this method.
            guard Messaging.messaging().apnsToken != nil else { return }
            do {
                if enabled && !authorizationDenied {
                    try await Messaging.messaging().subscribe(toTopic: topic)
                } else {
                    try await Messaging.messaging().unsubscribe(fromTopic: topic)
                }
            } catch {
                message = "Le réglage est enregistré. La connexion aux alertes sera réessayée à la prochaine ouverture."
            }
        }
    }
}
