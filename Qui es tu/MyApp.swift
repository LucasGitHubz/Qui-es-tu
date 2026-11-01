//
//  Qui_es_tuApp.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import FirebaseCore
import FirebaseMessaging
import UserNotifications
import Foundation
import SwiftUI

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        FirebaseTelemetry.configureCollection()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Task { await ReleaseNotificationStore.shared.synchronizeTopic() }
    }

    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task { @MainActor in await ReleaseNotificationStore.shared.synchronizeTopic() }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        ReleaseNotificationStore.shared.enabled ? [.banner, .sound] : []
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard ReleaseNotificationStore.shared.enabled else { return }
        ReleaseNotificationStore.shared.pendingQuizID = response.notification.request.content.userInfo["quiz_id"] as? String
    }
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @State private var quizzStore: QuizzStore
    @State private var purchases = PurchaseStore()
    @State private var advertising = AdvertisingStore()
    @State private var history = ResultHistoryStore()

    init() {
#if DEBUG
        let usesPreviewCatalog = ProcessInfo.processInfo.arguments.contains("-uiTesting")
        _quizzStore = State(
            initialValue: QuizzStore(
                quizzes: usesPreviewCatalog ? Quizz.previewCatalog : [],
                telemetry: usesPreviewCatalog ? NoOpTelemetry() : FirebaseTelemetry()
            )
        )
#else
        _quizzStore = State(initialValue: QuizzStore(telemetry: FirebaseTelemetry()))
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(quizzStore)
                .environment(purchases)
                .environment(advertising)
                .environment(history)
                .environment(ReleaseNotificationStore.shared)
                .task { await purchases.observeTransactions() }
        }
    }
}
