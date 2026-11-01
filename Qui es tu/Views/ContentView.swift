//
//  ContentView.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import StoreKit
import SwiftUI

struct ContentView: View {
    @Environment(QuizzStore.self) private var quizzStore
    @Environment(PurchaseStore.self) private var purchases
    @Environment(AdvertisingStore.self) private var advertising
    @Environment(ReleaseNotificationStore.self) private var notifications
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    @AppStorage("lastReviewRequestVersion") private var lastReviewRequestVersion = ""
    @State private var path: [String] = []
    @State private var isReviewRequestPending = false
    @State private var showsPaywall = false
    @State private var paywallQuiz: Quizz?
    @State private var showsSettings = false
    @State private var isOpeningQuiz = false
    @State private var openingError: String?

    var body: some View {
        @Bindable var quizzStore = quizzStore

        Group {
            if quizzStore.isFetchingQuizzes && quizzStore.quizzList.isEmpty {
                Image("launchScreen")
                    .resizable()
                    .ignoresSafeArea()
            } else {
                NavigationStack(path: $path) {
                    HomeView(
                        quizzes: quizzStore.quizzList.filter { $0.isReleased() },
                        onSelect: openQuiz,
                        onPremium: { paywallQuiz = nil; showsPaywall = true },
                        onSettings: { showsSettings = true }
                    )
                        .refreshable { await refreshCatalogue() }
                        .navigationDestination(for: String.self) { _ in
                            QuizzView(onFinish: { isReviewRequestPending = true })
                        }
                        .alert("Oups !", isPresented: $quizzStore.showAlert) {
                            Button("Ok", role: .cancel) {
                            }
                        } message: {
                            Text(quizzStore.errorMessage)
                        }
                }
                // Keep the home artwork light; the quiz follows the device appearance.
                .preferredColorScheme(path.isEmpty ? .light : nil)
                .tint(QuizTheme.ink)
                .onChange(of: path) { _, newPath in
                    guard newPath.isEmpty else {
                        return
                    }

                    handleReleaseNotification()

                    Task {
                        await requestReviewIfNeeded()
                    }
                }
            }
        }
        .sheet(isPresented: $showsPaywall) {
            PremiumPaywall(quiz: paywallQuiz, quizzes: quizzStore.quizzList) {
                if let quiz = paywallQuiz { openQuiz(quiz) }
            }
        }
        .sheet(isPresented: $showsSettings) { AppSettingsView() }
        .overlay {
            if isOpeningQuiz {
                ProgressView("Chargement du quiz…").padding(24).background(.regularMaterial, in: .rect(cornerRadius: 20))
            }
        }
        .alert("Quiz indisponible", isPresented: Binding(get: { openingError != nil }, set: { if !$0 { openingError = nil } })) {
            Button("OK", role: .cancel) { openingError = nil }
        } message: { Text(openingError ?? "") }
        .task {
            await quizzStore.loadQuizzesIfNeeded()
            await purchases.loadProducts(for: quizzStore.quizzList)
            await notifications.refresh()
            handleReleaseNotification()
            if !CommerceConfiguration.isPreviewOrTest { PilotTelemetry.recordWeeklyVisit() }
        }
        .task(id: purchases.access.allowsAds && path.isEmpty && !showsPaywall && !showsSettings && scenePhase == .active) {
            if purchases.access.allowsAds && path.isEmpty && !showsPaywall && !showsSettings && scenePhase == .active {
                await advertising.prepare()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task {
                    await purchases.refreshEntitlements()
                    await notifications.refresh()
                    await refreshCatalogue()
                    PilotTelemetry.recordWeeklyVisit()
                }
            }
        }
        .onChange(of: notifications.pendingQuizID) { _, _ in
            Task { await refreshCatalogue() }
        }
    }

    private func openQuiz(_ quiz: Quizz) {
        guard !isOpeningQuiz, path.isEmpty, quiz.isReleased() else { return }
        guard purchases.access.canOpen(quiz) else {
            paywallQuiz = quiz
            showsPaywall = true
            return
        }
        if quiz.productID == nil {
            quizzStore.setQuizz(id: quiz.id)
            path.append(quiz.id)
        } else {
            isOpeningQuiz = true
            Task {
                defer { isOpeningQuiz = false }
                do {
                    guard let proof = purchases.proof(for: quiz) else { throw PaidQuizService.PaidQuizError.unavailable }
                    let downloaded = try await PaidQuizService().fetch(quiz, proof: proof)
                    guard purchases.access.canOpen(quiz), path.isEmpty else { return }
                    quizzStore.setDownloadedQuiz(downloaded)
                    path.append(quiz.id)
                } catch { openingError = error.localizedDescription }
            }
        }
    }

    private func refreshCatalogue() async {
        if !CommerceConfiguration.isPreviewOrTest { await quizzStore.loadQuizzes() }
        await purchases.loadProducts(for: quizzStore.quizzList)
        handleReleaseNotification()
    }

    private func handleReleaseNotification() {
        guard path.isEmpty, let id = notifications.pendingQuizID,
              let quiz = quizzStore.quizzList.first(where: { $0.id == id && $0.isReleased() }) else { return }
        notifications.pendingQuizID = nil
        openQuiz(quiz)
    }

    /// Asks for a review once the user is back home after finishing a quiz.
    ///
    /// Limited to once per app version; the system applies its own yearly cap
    /// on top and may show nothing at all.
    @MainActor
    private func requestReviewIfNeeded() async {
        guard isReviewRequestPending, !CommerceConfiguration.isPreviewOrTest else {
            return
        }

        isReviewRequestPending = false

        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""

        guard lastReviewRequestVersion != currentVersion else {
            return
        }

        // Let the pop animation settle before the system sheet slides in.
        try? await Task.sleep(for: .seconds(1))

        lastReviewRequestVersion = currentVersion
        requestReview()
    }
}

#if DEBUG
#Preview {
    ContentView()
        .environment(QuizzStore(quizzes: Quizz.previewCatalog))
        .environment(PurchaseStore()).environment(AdvertisingStore())
        .environment(ResultHistoryStore()).environment(ReleaseNotificationStore.shared)
}
#endif
