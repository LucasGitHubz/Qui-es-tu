//
//  LoadingAnimationView.swift
//  Qui es tu
//
//  Created by Lucas on 01/01/2025.
//

import SwiftUI

struct ParticuleAnimationView: View {
    @StateObject private var particuleAnimationStore = ParticuleAnimationStore()
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Spacer()
                ZStack {
                    ForEach(particuleAnimationStore.particules) { particule in
                        Circle()
                            .foregroundStyle(.white)
                            .frame(width: 5, height: 5)
                            .offset(x: particule.radius * cos(particule.angle) * (particuleAnimationStore.activatePulsation ? 0.7 : 0.3),
                                    y: particule.radius * sin(particule.angle) * (particuleAnimationStore.activatePulsation ? 0.7 : 0.3)) // Position on the circle
                            .shadow(color: .white.opacity(0.7), radius: 3)
                            .scaleEffect(particuleAnimationStore.activatePulsation ? 1.05 : 1)
                    }
                }
                .padding(.vertical, 80)
                HStack(spacing: 1) {
                    Text("Analyse en cours\(particuleAnimationStore.dots)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .onAppear {
                            particuleAnimationStore.startDotsAnimation()
                        }
                }
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            particuleAnimationStore.startMotion()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Color("Turquoise").opacity(0.5), Color("Red").opacity(0.5)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
    }
}

#Preview {
    ParticuleAnimationView()
        .environmentObject(ParticuleAnimationStore())
}
