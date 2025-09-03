//
//  HomeView.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showingSettings = false
    @State private var selectedBall: BallType?
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced Background
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            settings.isDarkMode ? Color.black : Color.white,
                            settings.isDarkMode ? Color.gray.opacity(0.3) : Color.blue.opacity(0.08),
                            settings.isDarkMode ? Color.purple.opacity(0.2) : Color.purple.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle geometric patterns
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.1),
                                        Color.purple.opacity(0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: CGFloat(200 + index * 100))
                            .position(
                                x: CGFloat(100 + index * 150),
                                y: CGFloat(200 + index * 200)
                            )
                            .opacity(0.3)
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Enhanced Header
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "circle.hexagongrid.fill")
                                .font(.title)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Stress Balls")
                                .font(.largeTitle)
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
                        
                        Text("Choose your stress relief companion")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Enhanced Ball Selection Grid
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(BallType.allCases) { ballType in
                            BallSelectionCard(
                                ballType: ballType,
                                settings: settings
                            ) {
                                selectedBall = ballType
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(settings: settings)
            }
            .navigationDestination(item: $selectedBall) { ballType in
                BallInteractionView(ballType: ballType, settings: settings)
            }
        }
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }
}

struct BallSelectionCard: View {
    let ballType: BallType
    let settings: AppSettings
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var animationScale: CGFloat = 1.0
    @State private var hoverEffect = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 18) {
                // Enhanced Ball Preview
                ZStack {
                    // Outer glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    settings.ballColor.color.opacity(0.3),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 40,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(animationScale * 0.8)
                    
                    // Main ball circle with enhanced gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    settings.ballColor.color.opacity(0.9),
                                    settings.ballColor.color.opacity(0.6),
                                    settings.ballColor.color.opacity(0.3)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 85, height: 85)
                        .scaleEffect(animationScale)
                        .overlay(
                            // Shine effect
                            Circle()
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
                                .frame(width: 85, height: 85)
                                .scaleEffect(animationScale)
                        )
                    
                    // Ball type icon with enhanced styling
                    Image(systemName: ballType.systemImage)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color.white.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(animationScale)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
                }
                
                // Enhanced Ball Info
                VStack(spacing: 6) {
                    Text(ballType.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
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
                    
                    Text(ballType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .background(
                ZStack {
                    // Card background with glassmorphism effect
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            settings.isDarkMode ? 
                            Color.black.opacity(0.3) : 
                            Color.white.opacity(0.9)
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 24)
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
                    
                    // Border gradient
                    RoundedRectangle(cornerRadius: 24)
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
                    radius: isPressed ? 8 : 15,
                    x: 0,
                    y: isPressed ? 4 : 8
                )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            startIdleAnimation()
        }
    }
    
    private func startIdleAnimation() {
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            animationScale = 1.05
        }
    }
}

#Preview {
    HomeView()
}
