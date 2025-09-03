//
//  Color+Extensions.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

extension Color {
    /// Creates a color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Returns a lighter version of the color
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjustBrightness(by: -1 * abs(percentage))
    }
    
    /// Adjusts the brightness of the color
    func adjustBrightness(by percentage: CGFloat) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(
            red: min(max(red + percentage/100, 0.0), 1.0),
            green: min(max(green + percentage/100, 0.0), 1.0),
            blue: min(max(blue + percentage/100, 0.0), 1.0),
            opacity: alpha
        )
    }
}

extension Color {
    static let stressBallBlue = Color(hex: "007AFF")
    static let stressBallGreen = Color(hex: "34C759")
    static let stressBallRed = Color(hex: "FF3B30")
    static let stressBallPurple = Color(hex: "AF52DE")
    static let stressBallYellow = Color(hex: "FFCC00")
    static let stressBallGray = Color(hex: "8E8E93")
}
