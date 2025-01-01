//
//  ParticuleAnimationStore.swift
//  Qui es tu
//
//  Created by Lucas on 01/01/2025.
//

import SwiftUI

class ParticuleAnimationStore: ObservableObject {
    @Published var animateQuestionMark = false
    @Published var particules: [Particule] = []
    @Published var activatePulsation = false
    @Published var dots = ""
    
    private let maxParticles = 200
    private let circleRadius: CGFloat = UIScreen.main.bounds.width / 4 // Radius of the circular flow
    private var circleTimer: Timer?
    
    init() {
        particules = (0..<maxParticles).map { index in
            Particule(
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

    private func updateParticlePositions() {
        DispatchQueue.main.async {
            for i in self.particules.indices {
                // Increment the angle based on speed
                self.particules[i].angle += self.particules[i].speed
                
                // Keep angle within 0...2π for consistency
                if self.particules[i].angle > 2 * .pi {
                    self.particules[i].angle -= 2 * .pi
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

struct Particule: Identifiable {
    let id: Int
    var angle: CGFloat = CGFloat.random(in: 0...(2 * .pi)) // Initial angle in radians
    var radius: CGFloat // Distance from the center
    var speed: CGFloat // Speed of movement
}

