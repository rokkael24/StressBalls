//
//  BallInteractionView.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

struct BallInteractionView: View {
    let ballType: BallType
    let settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var physicsEngine: PhysicsEngine
    @State private var deformation = BallDeformation()
    @State private var dragTranslation = CGSize.zero
    @State private var pinchScale: CGFloat = 1.0
    @State private var isLongPressing = false
    
    init(ballType: BallType, settings: AppSettings) {
        self.ballType = ballType
        self.settings = settings
        
        // Initialize physics engine with screen bounds
        let screenBounds = UIScreen.main.bounds
        self._physicsEngine = StateObject(wrappedValue: PhysicsEngine(ballType: ballType, screenBounds: screenBounds))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                // Ball
                BallRenderer(
                    ballType: ballType,
                    settings: settings,
                    deformation: $physicsEngine.deformation
                )
                .position(
                    x: geometry.size.width / 2 + physicsEngine.deformation.offsetX,
                    y: geometry.size.height / 2 + physicsEngine.deformation.offsetY
                )
                .onTapGesture { location in
                    physicsEngine.handleTap(at: location)
                }
                .gesture(
                    SimultaneousGesture(
                        // Pinch Gesture
                        MagnificationGesture()
                            .onChanged { scale in
                                pinchScale = scale
                                physicsEngine.handlePinch(scale: scale, isActive: true)
                            }
                            .onEnded { _ in
                                physicsEngine.handlePinch(scale: pinchScale, isActive: false)
                                pinchScale = 1.0
                            },
                        
                        // Drag Gesture
                        DragGesture()
                            .onChanged { value in
                                dragTranslation = value.translation
                                physicsEngine.handleDrag(translation: value.translation, isActive: true)
                            }
                            .onEnded { value in
                                physicsEngine.handleDrag(translation: value.translation, isActive: false)
                                dragTranslation = .zero
                            }
                    )
                )
                .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 50) {
                    // Long press completed
                } onPressingChanged: { pressing in
                    isLongPressing = pressing
                    physicsEngine.handleLongPress(isActive: pressing)
                }
                
                // Instructions overlay
                if shouldShowInstructions {
                    instructionsOverlay
                }
            }
            .onAppear {
                setupBallSize()
            }
            .onChange(of: settings.ballSize) { _ in
                setupBallSize()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.body)
                    }
                    .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(ballType.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
        }
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }
    
    private var backgroundGradient: some View {
        let baseColor = settings.ballColor.color
        
        return ZStack {
            // Main gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    settings.isDarkMode ? Color.black : Color.white,
                    baseColor.opacity(settings.isDarkMode ? 0.15 : 0.08),
                    settings.isDarkMode ? Color.gray.opacity(0.2) : baseColor.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated ambient particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                baseColor.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 25
                        )
                    )
                    .frame(width: CGFloat.random(in: 15...40))
                    .position(
                        x: CGFloat.random(in: 50...350),
                        y: CGFloat.random(in: 100...700)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 4...8))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: physicsEngine.deformation.offsetX
                    )
            }
            
            // Subtle mesh gradient overlay
            Rectangle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            baseColor.opacity(0.05),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 100,
                        endRadius: 300
                    )
                )
        }
    }
    
    private var shouldShowInstructions: Bool {
        // Show instructions for the first few seconds or when ball is idle
        return abs(physicsEngine.deformation.offsetX) < 5 && 
               abs(physicsEngine.deformation.offsetY) < 5 &&
               abs(physicsEngine.deformation.scaleX - 1.0) < 0.1
    }
    
    @ViewBuilder
    private var instructionsOverlay: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                // Enhanced header
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.yellow, .orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Interaction Guide")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    settings.isDarkMode ? .white : .black,
                                    settings.isDarkMode ? .gray : .gray
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                VStack(spacing: 16) {
                    InstructionRow(
                        icon: "hand.tap.fill",
                        text: "Tap for ripple effect",
                        color: .blue
                    )
                    
                    InstructionRow(
                        icon: "hand.pinch.fill",
                        text: ballType == .soft ? "Pinch to compress" : 
                              ballType == .elastic ? "Pinch to stretch" :
                              ballType == .bouncy ? "Pinch to compress" : "Pinch to deform",
                        color: .green
                    )
                    
                    InstructionRow(
                        icon: "hand.draw.fill",
                        text: ballType == .elastic ? "Drag to stretch" :
                              ballType == .bouncy ? "Drag to launch" :
                              ballType == .liquid ? "Drag to flow" : "Drag to move",
                        color: .purple
                    )
                    
                    InstructionRow(
                        icon: "hand.point.up.left.fill",
                        text: "Long press for deep interaction",
                        color: .orange
                    )
                }
            }
            .padding(24)
            .background(
                ZStack {
                    // Glassmorphism background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            settings.isDarkMode ? 
                            Color.black.opacity(0.7) : 
                            Color.white.opacity(0.85)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    
                    // Border with gradient
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    settings.ballColor.color.opacity(0.3),
                                    Color.clear,
                                    settings.ballColor.color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: settings.ballColor.color.opacity(0.2),
                    radius: 20,
                    x: 0,
                    y: 10
                )
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
            .opacity(shouldShowInstructions ? 0.95 : 0.0)
            .scaleEffect(shouldShowInstructions ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: shouldShowInstructions)
        }
    }
    
    private func setupBallSize() {
        physicsEngine.deformation.size = settings.ballSize.diameter
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced icon with background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.2),
                                color.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color,
                                color.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationView {
        BallInteractionView(ballType: .soft, settings: AppSettings())
    }
}
