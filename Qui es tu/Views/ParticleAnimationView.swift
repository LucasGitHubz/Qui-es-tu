//
//  LoadingAnimationView.swift
//  Qui es tu
//
//  Created by Lucas on 01/01/2025.
//

import SwiftUI

struct ParticleAnimationView: View {
    @StateObject private var particleAnimationStore = ParticleAnimationStore()
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            ZStack {
                ForEach(particleAnimationStore.particles) { particle in
                    Circle()
                        .foregroundStyle(.white)
                        .frame(width: 4, height: 4)
                        .offset(x: particle.radius * cos(particle.angle) * (particleAnimationStore.activatePulsation ? 0.7 : 0.3),
                                y: particle.radius * sin(particle.angle) * (particleAnimationStore.activatePulsation ? 0.7 : 0.3)) // Position on the circle
                        .shadow(color: .white.opacity(0.7), radius: 3)
                        .scaleEffect(particleAnimationStore.activatePulsation ? 1.05 : 1)
                }
            }
            .padding(.vertical, 80)
            HStack(spacing: 1) {
                Text("Analyse en cours\(particleAnimationStore.dots)")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .onAppear {
                        particleAnimationStore.startDotsAnimation()
                    }
            }
            Spacer()
            Spacer()
        }
        .onAppear {
            particleAnimationStore.startMotion()
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
    ParticleAnimationView()
        .environmentObject(ParticleAnimationStore())
}
