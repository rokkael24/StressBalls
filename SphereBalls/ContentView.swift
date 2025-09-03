//
//  ContentView.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var settings = AppSettings()
    
    var body: some View {
        Group {
            if onboardingManager.hasCompletedOnboarding {
                HomeView()
                    .environmentObject(settings)
            } else {
                OnboardingView()
                    .environmentObject(onboardingManager)
            }
        }
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        .onReceive(onboardingManager.$hasCompletedOnboarding) { completed in
            if completed {
                // Save settings when onboarding is completed
                settings.saveSettings()
            }
        }
    }
}

#Preview {
    ContentView()
}
