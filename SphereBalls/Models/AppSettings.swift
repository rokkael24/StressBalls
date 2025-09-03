//
//  AppSettings.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

class AppSettings: ObservableObject {
    @Published var ballColor: BallColor = .blue
    @Published var ballSize: BallSize = .medium
    @Published var isDarkMode: Bool = false
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let colorRawValue = UserDefaults.standard.object(forKey: "ballColor") as? String,
           let color = BallColor(rawValue: colorRawValue) {
            ballColor = color
        }
        
        if let sizeRawValue = UserDefaults.standard.object(forKey: "ballSize") as? String,
           let size = BallSize(rawValue: sizeRawValue) {
            ballSize = size
        }
        
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(ballColor.rawValue, forKey: "ballColor")
        UserDefaults.standard.set(ballSize.rawValue, forKey: "ballSize")
        UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
    }
    
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}

enum BallColor: String, CaseIterable, Identifiable {
    case red = "Red"
    case blue = "Blue"
    case green = "Green"
    case yellow = "Yellow"
    case purple = "Purple"
    case gray = "Gray"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .blue:
            return .blue
        case .green:
            return .green
        case .yellow:
            return .yellow
        case .purple:
            return .purple
        case .gray:
            return .gray
        }
    }
}

enum BallSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { rawValue }
    
    var diameter: CGFloat {
        switch self {
        case .small:
            return 120
        case .medium:
            return 180
        case .large:
            return 240
        }
    }
}
