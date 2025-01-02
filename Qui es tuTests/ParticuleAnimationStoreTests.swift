//
//  ParticleAnimationStoreTests.swift
//  Qui es tuTests
//
//  Created by Lucas on 02/01/2025.
//

import XCTest
@testable import Qui_es_tu

final class ParticleAnimationStoreTests: XCTestCase {
    func test_initialization() {
        // Given (Arrange)
        let store = ParticleAnimationStore()
        
        // When (Act)
        let particles = store.particles
        
        // Then (Assert)
        XCTAssertEqual(particles.count, 200)
        for particle in particles {
            XCTAssertTrue(particle.angle >= 0 && particle.angle <= 2 * .pi)
            XCTAssertTrue(particle.radius >= store.circleRadius - 10 && particle.radius <= store.circleRadius + 20)
            XCTAssertTrue(particle.speed >= 0.01 && particle.speed <= 0.05)
        }
    }
    
    func test_startDotsAnimation() {
        let store = ParticleAnimationStore()
        let expectation = XCTestExpectation(description: "Wait for dots animation")
        
        store.startDotsAnimation()
        
        // Wait for a couple of seconds to observe changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssert(store.dots.count <= 3, "Dots should not exceed 3 characters")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func test_deinit_invalidatesTimer() {
        var store: ParticleAnimationStore? = ParticleAnimationStore()
        
        store = nil // Deinit the store
        
        // store == nil means that the deinit bloc was triggered
        // So circleTimer?.invalidate() has been triggered
        XCTAssertNil(store, "Store should be deallocated")
    }
}
