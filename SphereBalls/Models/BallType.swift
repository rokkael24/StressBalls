//
//  BallType.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

enum BallType: String, CaseIterable, Identifiable {
    case soft = "Soft Ball"
    case elastic = "Elastic Ball"
    case bouncy = "Bouncy Ball"
    case liquid = "Liquid Ball"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .soft:
            return "Compressible and soothing"
        case .elastic:
            return "Stretchable in all directions"
        case .bouncy:
            return "Bounces off screen edges"
        case .liquid:
            return "Flows like fluid"
        }
    }
    
    var systemImage: String {
        switch self {
        case .soft:
            return "circle.fill"
        case .elastic:
            return "oval.fill"
        case .bouncy:
            return "sportscourt.fill"
        case .liquid:
            return "drop.fill"
        }
    }
    
    var baseColor: Color {
        switch self {
        case .soft:
            return .blue
        case .elastic:
            return .green
        case .bouncy:
            return .red
        case .liquid:
            return .purple
        }
    }
    
    var visualStyle: BallVisualStyle {
        switch self {
        case .soft:
            return BallVisualStyle(
                opacity: 0.8,
                hasGradient: true,
                hasReflection: false,
                isGlossy: false
            )
        case .elastic:
            return BallVisualStyle(
                opacity: 1.0,
                hasGradient: true,
                hasReflection: true,
                isGlossy: true
            )
        case .bouncy:
            return BallVisualStyle(
                opacity: 1.0,
                hasGradient: true,
                hasReflection: true,
                isGlossy: true
            )
        case .liquid:
            return BallVisualStyle(
                opacity: 0.9,
                hasGradient: true,
                hasReflection: false,
                isGlossy: false
            )
        }
    }
}

struct BallVisualStyle {
    let opacity: Double
    let hasGradient: Bool
    let hasReflection: Bool
    let isGlossy: Bool
}
