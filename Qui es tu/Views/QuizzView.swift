import SwiftUI

struct QuizzView: View {
    /// Called when the user closes the result screen, not when they back out mid-quiz.
    var onFinish: () -> Void = {}

    @Environment(QuizzStore.self) private var quizzStore
    @Environment(ResultHistoryStore.self) private var history
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var showsExitConfirmation = false

    var body: some View {
        ZStack {
            if quizzStore.isLoadingResult {
                ParticleAnimationView()
                    .accessibilityIdentifier("quiz.reveal")
            } else if quizzStore.resultArtworkFailed {
                ContentUnavailableView {
                    Label("Le portrait n’a pas pu être chargé", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Vérifie ta connexion pour afficher ton résultat. Tes réponses sont conservées.")
                } actions: {
                    Button("Réessayer", action: quizzStore.retryResultArtwork)
                        .buttonStyle(.borderedProminent)
                    Button("Retour aux thèmes", action: finish)
                }
            } else if quizzStore.isQuizzFinished, let result = quizzStore.bestMatchResult {
                QuizResultContent(result: result, quiz: quizzStore.quizz, onRestart: quizzStore.restartQuizz, onFinish: finish)
            } else {
                VStack(spacing: 0) {
                    QuizHeader(
                        canGoBack: quizzStore.questionIndex > 0 && !quizzStore.isQuizzFinished,
                        onBack: goBack,
                        onClose: close
                    )
                    .frame(maxWidth: QuizTheme.maxWidth)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    GeometryReader { _ in
                        ScrollViewReader { scroll in
                            ScrollView {
                                VStack(alignment: .leading, spacing: QuizTheme.spacing) {
                                    if quizzStore.isQuizzFinished {
                                        ContentUnavailableView(
                                            "Résultat indisponible",
                                            systemImage: "questionmark.circle",
                                            description: Text("Ce thème n’a pas encore de portrait correspondant. Essaie un autre quiz.")
                                        )
                                    } else if quizzStore.questionCount > 0 {
                                        QuizQuestionContent(
                                            question: quizzStore.getQuestion(),
                                            theme: quizzStore.quizz.displayTitle,
                                            questionIndex: quizzStore.questionIndex,
                                            questionCount: quizzStore.questionCount,
                                            selectedAnswer: quizzStore.isCurrentQuestionAnswered
                                                ? quizzStore.userAnswers[quizzStore.questionIndex] : nil,
                                            onSelect: quizzStore.selectAnswer
                                        )
                                    } else {
                                        ContentUnavailableView(
                                            "Quiz indisponible",
                                            systemImage: "questionmark.circle",
                                            description: Text("Ce thème ne contient pas encore de questions. Reviens aux thèmes pour en choisir un autre.")
                                        )
                                    }
                                }
                                .id("quiz.top")
                                .frame(maxWidth: QuizTheme.maxWidth)
                                .padding(.horizontal, QuizTheme.pagePadding)
                                .padding(.bottom, QuizTheme.spacing)
                                .frame(maxWidth: .infinity, alignment: .top)
                            }
                            .onChange(of: quizzStore.questionIndex) {
                                scroll.scrollTo("quiz.top", anchor: .top)
                            }
                            .onChange(of: quizzStore.isQuizzFinished) {
                                scroll.scrollTo("quiz.top", anchor: .top)
                            }
                        }
                    }
                    .clipped()

                    if quizzStore.questionCount > 0 {
                        QuizFooter(
                            isFinished: quizzStore.isQuizzFinished,
                            isAnswered: quizzStore.isCurrentQuestionAnswered,
                            isLastQuestion: quizzStore.questionIndex + 1 == quizzStore.questionCount,
                            onContinue: quizzStore.validateAnswer,
                            onRestart: quizzStore.restartQuizz,
                            onFinish: finish
                        )
                    }
                }
            }
        }
        .background { QuizBackground() }
        .foregroundStyle(QuizTheme.ink)
        .tint(QuizTheme.ink)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .alert("On s’arrête là ?", isPresented: $showsExitConfirmation) {
            Button("Continuer le quiz", role: .cancel) { }
            Button("Quitter le quiz", role: .destructive) { dismiss() }
        } message: {
            Text("En quittant, tu perdras tes réponses à ce quiz.")
        }
        .sensoryFeedback(.selection, trigger: quizzStore.userAnswers)
        .sensoryFeedback(.success, trigger: quizzStore.isLoadingResult) { wasLoading, isLoading in
            wasLoading && !isLoading && quizzStore.isQuizzFinished && scenePhase == .active
        }
        .onDisappear { quizzStore.resetQuizz() }
        .task(id: quizzStore.quizz.id) {
            let quiz = quizzStore.quizz
            let sources = quiz.matchingResults?.keys.map { quiz.resultImages?[$0] ?? $0 } ?? []
            await QuizArtworkStore.shared.preload(sources)
        }
        .task(id: quizzStore.resultPreparationID) {
            if quizzStore.isQuizzFinished {
                await quizzStore.revealResult()
                if !Task.isCancelled, !quizzStore.resultArtworkFailed, let result = quizzStore.bestMatchResult {
                    history.save(quiz: quizzStore.quizz, result: result)
                }
            }
        }
    }

    private func goBack() {
        if quizzStore.questionIndex > 0 && !quizzStore.isQuizzFinished {
            quizzStore.goToPreviousQuestion()
        } else {
            close()
        }
    }

    private func close() {
        if quizzStore.isQuizzFinished {
            finish()
        } else if quizzStore.userAnswers.isEmpty {
            dismiss()
        } else {
            showsExitConfirmation = true
        }
    }

    private func finish() {
        onFinish()
        dismiss()
    }
}

#if DEBUG
#Preview("Clair") {
    let store = QuizzStore(quizzes: Quizz.previewCatalog)
    store.setQuizz(id: "animals")
    return NavigationStack {
        QuizzView().environment(store)
            .environment(ResultHistoryStore()).environment(PurchaseStore())
            .environment(AdvertisingStore()).environment(ReleaseNotificationStore.shared)
    }
    .preferredColorScheme(.light)
}

#Preview("Sombre") {
    let store = QuizzStore(quizzes: Quizz.previewCatalog)
    store.setQuizz(id: "animals")
    return NavigationStack {
        QuizzView().environment(store)
            .environment(ResultHistoryStore()).environment(PurchaseStore())
            .environment(AdvertisingStore()).environment(ReleaseNotificationStore.shared)
    }
    .preferredColorScheme(.dark)
}
#endif
