//
//  OnboardingManager.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

class OnboardingManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var currentPage: Int = 0
    
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        currentPage = 0
        UserDefaults.standard.set(false, forKey: onboardingKey)
    }
    
    func nextPage() {
        if currentPage < 2 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

struct OnboardingCard {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
    
    static let cards = [
        OnboardingCard(
            title: "Touch & Squeeze",
            description: "Press and compress your stress ball to feel the satisfying resistance",
            systemImage: "hand.tap.fill",
            color: .blue
        ),
        OnboardingCard(
            title: "Stretch & Play",
            description: "Drag and stretch elastic balls in any direction for endless fun",
            systemImage: "arrow.up.and.down.and.arrow.left.and.right",
            color: .green
        ),
        OnboardingCard(
            title: "Relax & Unwind",
            description: "Let the smooth animations and physics help you find your calm",
            systemImage: "heart.fill",
            color: .purple
        )
    ]
}
