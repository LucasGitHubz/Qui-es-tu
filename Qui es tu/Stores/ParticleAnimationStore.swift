//
//  ParticleAnimationStore.swift
//  Qui es tu
//
//  Created by Lucas on 01/01/2025.
//

import SwiftUI

class ParticleAnimationStore: ObservableObject {
    @Published var animateQuestionMark = false
    @Published var particles: [Particle] = []
    @Published var activatePulsation = false
    @Published var dots = ""
    
    let maxParticles = 200
    let circleRadius: CGFloat = UIScreen.main.bounds.width / 4 // Radius of the circular flow
    var circleTimer: Timer?
    
    init() {
        particles = (0..<maxParticles).map { index in
            Particle(
                id: index,
                angle: CGFloat.random(in: 0...(2 * .pi)), // Random starting angle
                radius: circleRadius + CGFloat.random(in: -10...20), // Add some variation to radius
                speed: CGFloat.random(in: 0.01...0.05) // Random speed
            )
        }
        startMotion()
    }
    
    func startMotion() {
        circleTimer?.invalidate() // Ensure no duplicate timers
        circleTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.updateParticlePositions()
        }

        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
            activatePulsation.toggle()
        }
        print("test: \(circleRadius)")
    }

    func updateParticlePositions() {
        DispatchQueue.main.async {
            for i in self.particles.indices {
                // Increment the angle based on speed
                self.particles[i].angle += self.particles[i].speed
                
                // Keep angle within 0...2π for consistency
                if self.particles[i].angle > 2 * .pi {
                    self.particles[i].angle -= 2 * .pi
                }
            }
        }
    }

    func startDotsAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if self.dots.count < 3 {
                    self.dots += "."
                } else {
                    self.dots = ""
                }
        }
    }

    deinit {
        circleTimer?.invalidate()
    }
}

struct Particle: Identifiable {
    let id: Int
    var angle: CGFloat = CGFloat.random(in: 0...(2 * .pi)) // Initial angle in radians
    var radius: CGFloat // Distance from the center
    var speed: CGFloat // Speed of movement
}

