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
    private var paidQuizzes = PaidQuizStore.shared

    init() {
#if DEBUG
        let usesPreviewCatalog = ProcessInfo.processInfo.arguments.contains("-uiTesting")
        var previewCatalog = Quizz.previewCatalog
        if usesPreviewCatalog && ProcessInfo.processInfo.arguments.contains("-uiTestingPaidCatalog") {
            previewCatalog[3].productID = "com.lucasamelin.quiestu.quiz.creatures"
            previewCatalog[3].releasedAt = .now
            previewCatalog[5].productID = "com.lucasamelin.quiestu.quiz.weapons"
            previewCatalog[5].releasedAt = .now.addingTimeInterval(-7 * 24 * 60 * 60)
        }
        if usesPreviewCatalog && ProcessInfo.processInfo.arguments.contains("-uiTestingRemoteResult") {
            let base = previewCatalog[0]
            previewCatalog[0] = Quizz(
                id: base.id, title: base.title, image: base.image, questions: base.questions,
                matchingResults: base.matchingResults, resultDescriptions: base.resultDescriptions,
                resultImages: ["Lynx": "https://qui-es-tu-d441b.web.app/assets/familiers/v1/chat-des-ombres.jpg?test=\(UUID().uuidString)"]
            )
        }
        if usesPreviewCatalog && ProcessInfo.processInfo.arguments.contains("-uiTestingOwnedCatalog") {
            let productID = "com.lucasamelin.quiestu.quiz.creatures"
            previewCatalog[3].productID = productID
            previewCatalog[3].releasedAt = .now
            _purchases = State(initialValue: PurchaseStore(storeKitEnabled: true, readEntitlements: {
                try? await Task.sleep(for: .milliseconds(500))
                return (QuizAccess(isResolved: true, productIDs: [productID]), [productID: "ui-test-proof"])
            }))
            paidQuizzes = PaidQuizStore(directory: nil, fetch: { quiz, _ in
                try await Task.sleep(for: .milliseconds(300))
                return quiz
            })
        }
        _quizzStore = State(
            initialValue: QuizzStore(
                quizzes: usesPreviewCatalog ? previewCatalog : [],
                telemetry: usesPreviewCatalog ? NoOpTelemetry() : FirebaseTelemetry()
            )
        )
#else
        _quizzStore = State(initialValue: QuizzStore(telemetry: FirebaseTelemetry()))
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView(paidQuizzes: paidQuizzes)
                .environment(quizzStore)
                .environment(purchases)
                .environment(advertising)
                .environment(history)
                .environment(ReleaseNotificationStore.shared)
                .task { await purchases.observeTransactions() }
        }
    }
}
