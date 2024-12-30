//
//  ContentView.swift
//  Qui es tu
//
//  Created by Lucas on 20/12/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var quizzStore: QuizzStore

    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Choisis ton thème")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.black.opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    Spacer()
                }
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(quizzStore.quizzList, id: \.id) { quizz in
                            NavigationLink {
                                QuizzView(quizzId: quizz.id)
                            } label: {
                                VStack(spacing: 0) {
                                    Image(quizz.image)
                                        .resizable()
                                        .aspectRatio(1.5, contentMode: .fit)
                                    Text(quizz.title)
                                        .font(.headline)
                                        .padding(.vertical)
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity)
                                        .background(.white)
                                }
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: .black.opacity(0.2), radius: 4)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(lineWidth: 4)
                                        .foregroundStyle(.white)
                                }
                                
                                .padding(5)
                                
                            }
                        }
                    }
                    .padding(20)
                }
                Spacer()
            }
            .background(
                LinearGradient(colors: [Color("Turquoise").opacity(0.5), Color("Red").opacity(0.5)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .onAppear {
                quizzStore.getQuizzList()
            }
        }
        .preferredColorScheme(.light)
        .tint(.white)
    }
}

#Preview {
    ContentView()
        .environmentObject(QuizzStore())
}
