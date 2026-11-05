//
//  ContentView.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import StoreKit
import SwiftUI

struct ContentView: View {
    var paidQuizzes = PaidQuizStore.shared
    @Environment(QuizzStore.self) private var quizzStore
    @Environment(PurchaseStore.self) private var purchases
    @Environment(AdvertisingStore.self) private var advertising
    @Environment(ReleaseNotificationStore.self) private var notifications
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview
    @AppStorage("lastReviewRequestVersion") private var lastReviewRequestVersion = ""
    @State private var isPreparingHome = true
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
            if isPreparingHome {
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
        .fullScreenCover(isPresented: $showsPaywall) {
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
            async let ownership: Void = purchases.refreshEntitlements()
            await quizzStore.loadQuizzesIfNeeded()
            await QuizArtworkStore.shared.preload(quizzStore.quizzList.filter { $0.isReleased() }.map(\.image))
            await ownership
            guard !Task.isCancelled else { return }
            isPreparingHome = false
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
        .task(id: paidPrefetchKey) {
            guard !isPreparingHome, scenePhase == .active, purchases.access.isResolved else { return }
            await prepareOwnedQuizzes()
        }
        .onChange(of: notifications.pendingQuizID) { _, _ in
            Task { await refreshCatalogue() }
        }
    }

    private func openQuiz(_ quiz: Quizz) {
        guard !isOpeningQuiz, path.isEmpty, quiz.isReleased() else { return }
#if DEBUG
        if quiz.id == DebugCommercePreview.quiz.id {
            paywallQuiz = quiz
            showsPaywall = true
            return
        }
#endif
        guard purchases.access.canOpen(quiz) else {
            paywallQuiz = quiz
            showsPaywall = true
            return
        }
        if quiz.productID == nil {
            quizzStore.setQuizz(id: quiz.id)
            path.append(quiz.id)
        } else if let cached = paidQuizzes.cachedQuiz(for: quiz, access: purchases.access) {
            quizzStore.setDownloadedQuiz(cached)
            path.append(quiz.id)
        } else {
            isOpeningQuiz = true
            Task {
                defer { isOpeningQuiz = false }
                do {
                    guard let proof = purchases.proof(for: quiz) else { throw PaidQuizService.PaidQuizError.unavailable }
                    let downloaded = try await paidQuizzes.prepare(quiz, access: purchases.access, proof: proof)
                    guard purchases.access.canOpen(quiz), path.isEmpty else { return }
                    quizzStore.setDownloadedQuiz(downloaded)
                    path.append(quiz.id)
                } catch { openingError = error.localizedDescription }
            }
        }
    }

    private var paidPrefetchKey: String {
        let catalogue = quizzStore.quizzList.map { "\($0.id):\($0.productID ?? "")" }.sorted().joined(separator: ",")
        return "\(isPreparingHome):\(scenePhase == .active):\(purchases.access.isResolved):\(purchases.access.productIDs.sorted()):\(catalogue)"
    }

    private func prepareOwnedQuizzes() async {
        let access = purchases.access
        let requests = quizzStore.quizzList.compactMap { quiz -> (Quizz, String)? in
            guard quiz.productID != nil, quiz.isReleased(), access.canOpen(quiz),
                  let proof = purchases.proof(for: quiz) else { return nil }
            return (quiz, proof)
        }
        await withTaskGroup(of: Void.self) { group in
            var remaining = requests.makeIterator()
            for _ in 0..<3 {
                guard let (quiz, proof) = remaining.next() else { break }
                group.addTask { _ = try? await paidQuizzes.prepare(quiz, access: access, proof: proof, refresh: true) }
            }
            for await _ in group {
                guard !Task.isCancelled else { break }
                if let (quiz, proof) = remaining.next() {
                    group.addTask { _ = try? await paidQuizzes.prepare(quiz, access: access, proof: proof, refresh: true) }
                }
            }
        }
    }

    private func refreshCatalogue() async {
        guard !isPreparingHome else { return }
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
