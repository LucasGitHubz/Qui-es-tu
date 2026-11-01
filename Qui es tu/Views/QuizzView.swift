import SwiftUI

struct QuizzView: View {
    /// Called when the user closes the result screen, not when they back out mid-quiz.
    var onFinish: () -> Void = {}

    @Environment(QuizzStore.self) private var quizzStore
    @Environment(ResultHistoryStore.self) private var history
    @Environment(\.dismiss) private var dismiss
    @State private var showsExitConfirmation = false
    @AccessibilityFocusState private var isResultFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            QuizHeader(
                canGoBack: quizzStore.questionIndex > 0 && !quizzStore.isQuizzFinished,
                onBack: goBack,
                onClose: close
            )
            .frame(maxWidth: QuizTheme.maxWidth)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)

            GeometryReader { geometry in
                ScrollViewReader { scroll in
                    ScrollView {
                        VStack(alignment: .leading, spacing: QuizTheme.spacing) {
                            if quizzStore.isLoadingResult {
                                QuizRevealView()
                                    .frame(minHeight: max(geometry.size.height - 48, 0))
                            } else if quizzStore.isQuizzFinished {
                                if let result = quizzStore.bestMatchResult {
                                    QuizResultContent(result: result, theme: quizzStore.quizz.displayTitle, image: quizzStore.quizz.resultImages?[result.name])
                                        .accessibilityFocused($isResultFocused)
                                    Text("Un quiz pour s’amuser, pas un diagnostic.").font(.footnote).foregroundStyle(.secondary)
                                    ResultShareButton(result: result, quiz: quizzStore.quizz)
                                    ReleaseNotificationPrompt()
                                    QuizBanner(placement: "result")
                                } else {
                                    ContentUnavailableView(
                                        "Résultat indisponible",
                                        systemImage: "questionmark.circle",
                                        description: Text("Ce thème n’a pas encore de portrait correspondant. Essaie un autre quiz.")
                                    )
                                }
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
                    .onChange(of: quizzStore.isQuizzFinished) { _, isFinished in
                        scroll.scrollTo("quiz.top", anchor: .top)
                        if !isFinished { isResultFocused = false }
                    }
                    .onChange(of: quizzStore.isLoadingResult) { _, isLoading in
                        scroll.scrollTo("quiz.top", anchor: .top)
                        isResultFocused = !isLoading && quizzStore.isQuizzFinished
                    }
                }
            }
            .clipped()

            if !quizzStore.isLoadingResult && quizzStore.questionCount > 0 {
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
        .onDisappear { quizzStore.resetQuizz() }
        .task(id: quizzStore.isQuizzFinished) {
            if quizzStore.isQuizzFinished {
                await quizzStore.revealResult()
                if !Task.isCancelled, let result = quizzStore.bestMatchResult {
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
