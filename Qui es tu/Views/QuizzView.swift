//
//  QuizzView.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import SwiftUI

struct QuizzView: View {
    @EnvironmentObject var quizzStore: QuizzStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if !quizzStore.isQuizzFinished {
                VStack {
                    ProgressView(value: Double(quizzStore.questionIndex) + 1, total: 10.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.white)
                        .padding(.bottom)
                        .padding(.horizontal, 5)
                    Text(quizzStore.getQuestion().question)
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)
                        .padding(20)
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.2), radius: 10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 4)
                                .foregroundStyle(
                                    LinearGradient(colors: [Color("Red"), Color("Turquoise")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        }
                    Spacer()
                    VStack {
                        ForEach(quizzStore.getQuestion().answers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    quizzStore.selectAnswer(answerNumber: key)
                                }
                            } label: {
                                HStack {
                                    Text(value)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(quizzStore.isAnswerSelected(key) ? .white : .black)
                                        .transaction { transaction in
                                            transaction.animation = nil
                                        }
                                    Spacer()
                                }
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                                .padding(.vertical, 20)
                                .background(quizzStore.isAnswerSelected(key) ? Color.mint : .white)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .scaleEffect(quizzStore.isAnswerSelected(key) ? 1.03 : 1.0)
                            }
                            .sensoryFeedback(.impact(flexibility: .soft, intensity: 1), trigger: quizzStore.userAnswers)
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 5)
                    Button {
                        quizzStore.validateAnswer()
                    } label: {
                        Text("Valider")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color("Turquoise").opacity(0.7))
                            .clipShape(.rect(cornerRadius: 5))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(lineWidth: 3)
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .padding()
            } else {
                if quizzStore.isLoadingResult {
                    ParticleAnimationView()
                } else {
                    VStack {
                        VStack {
                            Text(quizzStore.bestMatchResult?.0 ?? "Lynx")
                                .font(.title.bold())
                                .foregroundStyle(.black)
                                .padding(.bottom)
                            Image(quizzStore.bestMatchResult?.0 ?? "Lynx")
                                .resizable()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .shadow(color: .black.opacity(0.1), radius: 5)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(lineWidth: 4)
                                        .foregroundStyle(
                                            LinearGradient(colors: [Color("Red"), Color("Turquoise")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                }
                                .background(.black.opacity(0.1))
                            Text(quizzStore.bestMatchResult?.1 ?? "Description...")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .padding(.vertical)
                        }
                        .padding()
                        .background(.white.opacity(0.8))
                        .clipShape(.rect(cornerRadius: 10))
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Text("Terminer")
                                .font(.title3.bold())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color("Turquoise").opacity(0.6))
                                .clipShape(.rect(cornerRadius: 5))
                        }
                    }
                    .padding()
                }
            }
        }
        .background(
            LinearGradient(colors: [Color("Turquoise").opacity(0.5), Color("Red").opacity(0.5)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
        .onDisappear {
            quizzStore.resetQuizz()
        }
    }
}

#Preview {
    QuizzView()
        .environmentObject(QuizzStore())
}
