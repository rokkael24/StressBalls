//
//  UserDefaults+Extensions.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import Foundation

extension UserDefaults {
    /// Keys for storing app preferences
    enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let ballColor = "ballColor"
        static let ballSize = "ballSize"
        static let isDarkMode = "isDarkMode"
        static let appVersion = "appVersion"
    }
    
    /// Safely get a string value with a default fallback
    func string(forKey key: String, defaultValue: String) -> String {
        return string(forKey: key) ?? defaultValue
    }
    
    /// Safely get a bool value with a default fallback
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
    
    /// Reset all app settings to defaults
    func resetAppSettings() {
        removeObject(forKey: Keys.hasCompletedOnboarding)
        removeObject(forKey: Keys.ballColor)
        removeObject(forKey: Keys.ballSize)
        removeObject(forKey: Keys.isDarkMode)
    }
    
    /// Check if this is the first app launch
    var isFirstLaunch: Bool {
        let hasLaunchedBefore = bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            set(true, forKey: "hasLaunchedBefore")
            return true
        }
        return false
    }
}
