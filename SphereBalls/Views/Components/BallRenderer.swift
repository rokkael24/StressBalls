//
//  BallRenderer.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

struct BallRenderer: View {
    let ballType: BallType
    let settings: AppSettings
    @Binding var deformation: BallDeformation
    @State private var animationPhase: Double = 0
    
    var body: some View {
        ZStack {
            // Main ball shape
            ballShape
                .fill(ballGradient)
                .opacity(ballType.visualStyle.opacity)
            
            // Reflection/highlight for glossy balls
            if ballType.visualStyle.hasReflection {
                ballShape
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .scaleEffect(0.6)
                    .offset(x: -deformation.size * 0.1, y: -deformation.size * 0.1)
            }
            
            // Liquid ball special effects
            if ballType == .liquid {
                liquidEffects
            }
        }
        .frame(width: deformation.size, height: deformation.size)
        .scaleEffect(x: deformation.scaleX, y: deformation.scaleY)
        .offset(x: deformation.offsetX, y: deformation.offsetY)
        .rotationEffect(.degrees(deformation.rotation))
        .onAppear {
            startIdleAnimation()
        }
    }
    
    private var ballShape: some Shape {
        switch ballType {
        case .soft:
            return AnyShape(Circle())
        case .elastic:
            return AnyShape(Ellipse())
        case .bouncy:
            return AnyShape(Circle())
        case .liquid:
            return AnyShape(LiquidShape(deformation: deformation, phase: animationPhase))
        }
    }
    
    private var ballGradient: LinearGradient {
        let baseColor = settings.ballColor.color
        
        switch ballType {
        case .soft:
            return LinearGradient(
                gradient: Gradient(colors: [
                    baseColor.opacity(0.8),
                    baseColor.opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .elastic:
            return LinearGradient(
                gradient: Gradient(colors: [
                    baseColor,
                    baseColor.opacity(0.7),
                    baseColor.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .bouncy:
            return LinearGradient(
                gradient: Gradient(colors: [
                    baseColor,
                    baseColor.opacity(0.8),
                    baseColor
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .liquid:
            return LinearGradient(
                gradient: Gradient(colors: [
                    baseColor.opacity(0.9),
                    baseColor.opacity(0.6),
                    baseColor.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    @ViewBuilder
    private var liquidEffects: some View {
        // Flowing particles effect for liquid ball
        ForEach(0..<5, id: \.self) { index in
            Circle()
                .fill(settings.ballColor.color.opacity(0.3))
                .frame(width: 8, height: 8)
                .offset(
                    x: sin(animationPhase + Double(index) * 0.5) * 20,
                    y: cos(animationPhase + Double(index) * 0.7) * 15
                )
                .animation(
                    .easeInOut(duration: 2.0 + Double(index) * 0.3)
                    .repeatForever(autoreverses: true),
                    value: animationPhase
                )
        }
    }
    
    private func startIdleAnimation() {
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            animationPhase = .pi * 2
        }
    }
}

struct BallDeformation {
    var size: CGFloat = 180
    var scaleX: CGFloat = 1.0
    var scaleY: CGFloat = 1.0
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var rotation: Double = 0
    var compressionFactor: CGFloat = 1.0
    
    static let identity = BallDeformation()
    
    mutating func reset() {
        let currentSize = self.size
        self = BallDeformation.identity
        self.size = currentSize // Preserve the size
    }
}

// Custom shape for liquid ball
struct LiquidShape: Shape {
    let deformation: BallDeformation
    let phase: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Create a wavy circle for liquid effect
        let points = 60
        let angleStep = 2 * Double.pi / Double(points)
        
        for i in 0..<points {
            let angle = Double(i) * angleStep
            let waveOffset = sin(angle * 3 + phase) * 5 * deformation.compressionFactor
            let currentRadius = radius + waveOffset
            
            let x = center.x + cos(angle) * currentRadius
            let y = center.y + sin(angle) * currentRadius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// Type-erased shape wrapper
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = shape.path(in:)
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

#Preview {
    VStack(spacing: 30) {
        BallRenderer(
            ballType: .soft,
            settings: AppSettings(),
            deformation: .constant(BallDeformation())
        )
        
        BallRenderer(
            ballType: .liquid,
            settings: AppSettings(),
            deformation: .constant(BallDeformation())
        )
    }
    .padding()
}
