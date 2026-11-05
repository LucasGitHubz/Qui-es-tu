//
//  LoadingAnimationView.swift
//  Qui es tu
//
//  Created by Lucas on 01/01/2025.
//

import SwiftUI

struct ParticleAnimationView: View {
    @StateObject private var particleAnimationStore = ParticleAnimationStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var haptics = ParticleHaptics()
    
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
        .onDisappear {
            particleAnimationStore.stopAnimations()
            haptics.stop()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.screenGradient.ignoresSafeArea())
        .task(id: scenePhase) {
            haptics.stop()
            if scenePhase == .active { haptics.start() }
        }
    }
}

#Preview {
    ParticleAnimationView()
        .environmentObject(ParticleAnimationStore())
}
