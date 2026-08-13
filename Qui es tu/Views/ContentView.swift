//
//  ContentView.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(QuizzStore.self) private var quizzStore
    @State private var path: [String] = []

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
                            QuizzView()
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
}

#Preview {
    ContentView()
        .environment(QuizzStore(quizzes: Quizz.previewCatalog))
}
