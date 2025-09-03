//
//  PhysicsEngine.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI
import CoreHaptics

class PhysicsEngine: ObservableObject {
    @Published var deformation = BallDeformation()
    
    private let ballType: BallType
    private let screenBounds: CGRect
    private var velocity = CGVector.zero
    private var isPressed = false
    private var hapticEngine: CHHapticEngine?
    
    // Physics constants
    private let gravity: CGFloat = 0.5
    private let friction: CGFloat = 0.98
    private let bounceDamping: CGFloat = 0.8
    private let elasticSpringStrength: CGFloat = 0.15
    private let softCompressionRate: CGFloat = 0.3
    
    init(ballType: BallType, screenBounds: CGRect) {
        self.ballType = ballType
        self.screenBounds = screenBounds
        setupHaptics()
        resetBallPosition()
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine failed to start: \(error)")
        }
    }
    
    func resetBallPosition() {
        deformation.offsetX = 0
        deformation.offsetY = 0
        deformation.scaleX = 1.0
        deformation.scaleY = 1.0
        deformation.rotation = 0
        deformation.compressionFactor = 1.0
        velocity = .zero
    }
    
    // MARK: - Gesture Handling
    
    func handleTap(at location: CGPoint) {
        playHapticFeedback(.light)
        
        switch ballType {
        case .soft:
            handleSoftTap()
        case .elastic:
            handleElasticTap()
        case .bouncy:
            handleBouncyTap()
        case .liquid:
            handleLiquidTap(at: location)
        }
    }
    
    func handlePinch(scale: CGFloat, isActive: Bool) {
        isPressed = isActive
        
        switch ballType {
        case .soft:
            handleSoftPinch(scale: scale, isActive: isActive)
        case .elastic:
            handleElasticPinch(scale: scale, isActive: isActive)
        case .bouncy:
            handleBouncyPinch(scale: scale, isActive: isActive)
        case .liquid:
            handleLiquidPinch(scale: scale, isActive: isActive)
        }
    }
    
    func handleDrag(translation: CGSize, isActive: Bool) {
        switch ballType {
        case .soft:
            handleSoftDrag(translation: translation, isActive: isActive)
        case .elastic:
            handleElasticDrag(translation: translation, isActive: isActive)
        case .bouncy:
            handleBouncyDrag(translation: translation, isActive: isActive)
        case .liquid:
            handleLiquidDrag(translation: translation, isActive: isActive)
        }
    }
    
    func handleLongPress(isActive: Bool) {
        playHapticFeedback(.medium)
        
        switch ballType {
        case .soft:
            handleSoftLongPress(isActive: isActive)
        case .elastic:
            handleElasticLongPress(isActive: isActive)
        case .bouncy:
            handleBouncyLongPress(isActive: isActive)
        case .liquid:
            handleLiquidLongPress(isActive: isActive)
        }
    }
    
    // MARK: - Ball-Specific Behaviors
    
    private func handleSoftTap() {
        withAnimation(.easeOut(duration: 0.3)) {
            deformation.scaleX = 0.9
            deformation.scaleY = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.elasticOut(duration: 0.5)) {
                self.deformation.scaleX = 1.0
                self.deformation.scaleY = 1.0
            }
        }
    }
    
    private func handleSoftPinch(scale: CGFloat, isActive: Bool) {
        if isActive {
            playHapticFeedback(.light)
            let compressionScale = max(0.5, min(1.5, scale))
            withAnimation(.easeInOut(duration: 0.1)) {
                deformation.scaleX = compressionScale
                deformation.scaleY = compressionScale
                deformation.compressionFactor = compressionScale
            }
        } else {
            withAnimation(.elasticOut(duration: 0.8)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
                deformation.compressionFactor = 1.0
            }
        }
    }
    
    private func handleSoftDrag(translation: CGSize, isActive: Bool) {
        if isActive {
            let dampedTranslation = CGSize(
                width: translation.width * 0.3,
                height: translation.height * 0.3
            )
            deformation.offsetX = dampedTranslation.width
            deformation.offsetY = dampedTranslation.height
        } else {
            withAnimation(.elasticOut(duration: 0.6)) {
                deformation.offsetX = 0
                deformation.offsetY = 0
            }
        }
    }
    
    private func handleSoftLongPress(isActive: Bool) {
        if isActive {
            withAnimation(.easeInOut(duration: 0.5)) {
                deformation.scaleX = 0.7
                deformation.scaleY = 0.7
                deformation.compressionFactor = 0.7
            }
        } else {
            withAnimation(.elasticOut(duration: 1.0)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
                deformation.compressionFactor = 1.0
            }
        }
    }
    
    private func handleElasticTap() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.3)) {
            deformation.scaleX = 1.3
            deformation.scaleY = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                self.deformation.scaleX = 1.0
                self.deformation.scaleY = 1.0
            }
        }
    }
    
    private func handleElasticPinch(scale: CGFloat, isActive: Bool) {
        if isActive {
            let stretchScale = max(0.3, min(2.0, scale))
            withAnimation(.easeInOut(duration: 0.1)) {
                deformation.scaleX = stretchScale
                deformation.scaleY = 2.0 - stretchScale
            }
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.3)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
            }
        }
    }
    
    private func handleElasticDrag(translation: CGSize, isActive: Bool) {
        if isActive {
            let stretchFactor = sqrt(translation.width * translation.width + translation.height * translation.height) / 100
            deformation.offsetX = translation.width * 0.5
            deformation.offsetY = translation.height * 0.5
            deformation.scaleX = 1.0 + stretchFactor * 0.3
            deformation.scaleY = 1.0 - stretchFactor * 0.2
        } else {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                deformation.offsetX = 0
                deformation.offsetY = 0
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
            }
        }
    }
    
    private func handleElasticLongPress(isActive: Bool) {
        if isActive {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                deformation.scaleX = 1.5
                deformation.scaleY = 0.6
            }
        } else {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.3)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
            }
        }
    }
    
    private func handleBouncyTap() {
        playHapticFeedback(.heavy)
        velocity = CGVector(dx: Double.random(in: -5...5), dy: -8)
        startBouncyPhysics()
    }
    
    private func handleBouncyPinch(scale: CGFloat, isActive: Bool) {
        if isActive {
            let compressionScale = max(0.6, min(1.4, scale))
            withAnimation(.easeInOut(duration: 0.1)) {
                deformation.scaleX = compressionScale
                deformation.scaleY = compressionScale
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
            }
            // Add some bounce after release
            velocity = CGVector(dx: Double.random(in: -3...3), dy: -5)
            startBouncyPhysics()
        }
    }
    
    private func handleBouncyDrag(translation: CGSize, isActive: Bool) {
        if isActive {
            deformation.offsetX = translation.width * 0.8
            deformation.offsetY = translation.height * 0.8
        } else {
            // Launch the ball based on drag velocity
            velocity = CGVector(
                dx: translation.width * 0.1,
                dy: translation.height * 0.1
            )
            startBouncyPhysics()
        }
    }
    
    private func handleBouncyLongPress(isActive: Bool) {
        if isActive {
            withAnimation(.easeInOut(duration: 0.3)) {
                deformation.scaleX = 0.8
                deformation.scaleY = 0.8
            }
        } else {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
            }
            // Big bounce after long press
            velocity = CGVector(dx: 0, dy: -12)
            startBouncyPhysics()
        }
    }
    
    private func handleLiquidTap(at location: CGPoint) {
        withAnimation(.easeInOut(duration: 0.4)) {
            deformation.compressionFactor = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.6)) {
                self.deformation.compressionFactor = 1.0
            }
        }
    }
    
    private func handleLiquidPinch(scale: CGFloat, isActive: Bool) {
        if isActive {
            let flowScale = max(0.4, min(1.8, scale))
            withAnimation(.easeInOut(duration: 0.2)) {
                deformation.scaleX = flowScale
                deformation.scaleY = 2.0 - flowScale
                deformation.compressionFactor = flowScale
            }
        } else {
            withAnimation(.easeOut(duration: 1.0)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
                deformation.compressionFactor = 1.0
            }
        }
    }
    
    private func handleLiquidDrag(translation: CGSize, isActive: Bool) {
        if isActive {
            let flowFactor = sqrt(translation.width * translation.width + translation.height * translation.height) / 150
            deformation.offsetX = translation.width * 0.4
            deformation.offsetY = translation.height * 0.4
            deformation.compressionFactor = 1.0 + flowFactor
        } else {
            // For liquid ball, keep the position but reset compression factor
            withAnimation(.easeOut(duration: 0.8)) {
                deformation.compressionFactor = 1.0
            }
            // Position stays where it was dragged to (liquid flows and stays)
        }
    }
    
    private func handleLiquidLongPress(isActive: Bool) {
        if isActive {
            withAnimation(.easeInOut(duration: 0.6)) {
                deformation.scaleX = 1.3
                deformation.scaleY = 0.7
                deformation.compressionFactor = 0.8
            }
        } else {
            withAnimation(.easeOut(duration: 1.2)) {
                deformation.scaleX = 1.0
                deformation.scaleY = 1.0
                deformation.compressionFactor = 1.0
            }
        }
    }
    
    // MARK: - Bouncy Ball Physics
    
    private func startBouncyPhysics() {
        guard ballType == .bouncy else { return }
        
        // Use a simpler animation-based approach instead of Timer
        withAnimation(.easeOut(duration: 2.0)) {
            simulateBouncyMovement()
        }
    }
    
    private func simulateBouncyMovement() {
        // Calculate bounce trajectory
        let bounceHeight: CGFloat = -200
        let bounceWidth: CGFloat = velocity.dx * 20
        
        // Clamp to screen bounds
        let ballRadius = deformation.size / 2
        let maxX = screenBounds.width / 2 - ballRadius - 50
        let maxY = screenBounds.height / 2 - ballRadius - 100
        
        let targetX = max(-maxX, min(maxX, bounceWidth))
        let targetY = max(-maxY, min(maxY, bounceHeight))
        
        // Animate to bounce position
        deformation.offsetX = targetX
        deformation.offsetY = targetY
        
        // Add haptic feedback
        playHapticFeedback(.light)
        
        // Return to center after bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                self.deformation.offsetX = 0
                self.deformation.offsetY = 0
            }
        }
    }
    
    // MARK: - Haptic Feedback
    
    private func playHapticFeedback(_ intensity: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: intensity)
        impactFeedback.impactOccurred()
    }
}

extension Animation {
    static func elasticOut(duration: Double) -> Animation {
        .timingCurve(0.34, 1.56, 0.64, 1, duration: duration)
    }
}
