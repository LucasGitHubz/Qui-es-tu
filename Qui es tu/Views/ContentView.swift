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
    @Environment(\.requestReview) private var requestReview
    @AppStorage("lastReviewRequestVersion") private var lastReviewRequestVersion = ""
    @State private var path: [String] = []
    @State private var isReviewRequestPending = false

    var body: some View {
        @Bindable var quizzStore = quizzStore

        Group {
            if quizzStore.isFetchingQuizzes && quizzStore.quizzList.isEmpty {
                Image("launchScreen")
                    .resizable()
                    .ignoresSafeArea()
            } else {
                NavigationStack(path: $path) {
                    HomeView(quizzes: quizzStore.quizzList, onSelect: openQuiz)
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
                .preferredColorScheme(.light)
                .tint(.white)
                .onChange(of: path) { _, newPath in
                    guard newPath.isEmpty else {
                        return
                    }

                    Task {
                        await requestReviewIfNeeded()
                    }
                }
            }
        }
        .task {
            await quizzStore.loadQuizzesIfNeeded()
        }
    }

    private func openQuiz(_ quiz: Quizz) {
        quizzStore.setQuizz(id: quiz.id)
        path.append(quiz.id)
    }

    /// Asks for a review once the user is back home after finishing a quiz.
    ///
    /// Limited to once per app version; the system applies its own yearly cap
    /// on top and may show nothing at all.
    @MainActor
    private func requestReviewIfNeeded() async {
        guard isReviewRequestPending else {
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

#Preview {
    ContentView()
        .environment(QuizzStore(quizzes: Quizz.previewCatalog))
}
