//
//  OnboardingView.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 16) {
                    Text("Welcome to Stress Balls")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Your pocket stress relief companion")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Onboarding Cards
                TabView(selection: $onboardingManager.currentPage) {
                    ForEach(0..<OnboardingCard.cards.count, id: \.self) { index in
                        OnboardingCardView(
                            card: OnboardingCard.cards[index],
                            isActive: onboardingManager.currentPage == index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 300)
                
                // Page Indicators
                HStack(spacing: 12) {
                    ForEach(0..<OnboardingCard.cards.count, id: \.self) { index in
                        Circle()
                            .fill(onboardingManager.currentPage == index ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(onboardingManager.currentPage == index ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: onboardingManager.currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                // Get Started Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        onboardingManager.completeOnboarding()
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.purple,
                                    Color.pink
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            
                            // Subtle shine effect
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear,
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    )
                    .cornerRadius(28)
                    .shadow(
                        color: Color.blue.opacity(0.3),
                        radius: 15,
                        x: 0,
                        y: 8
                    )
                }
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.1), value: onboardingManager.currentPage)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .background(
            ZStack {
                // Animated background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.15),
                        Color.purple.opacity(0.15),
                        Color.pink.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Floating particles effect
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.blue.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: CGFloat.random(in: 20...60))
                        .position(
                            x: CGFloat.random(in: 0...400),
                            y: CGFloat.random(in: 0...800)
                        )
                        .animation(
                            .easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                            value: animationOffset
                        )
                }
            }
            .ignoresSafeArea()
        )
        .onAppear {
            animationOffset = 100
        }
    }
}

struct OnboardingCardView: View {
    let card: OnboardingCard
    let isActive: Bool
    @State private var animationScale: CGFloat = 0.8
    @State private var animationOpacity: Double = 0.5
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated Icon
            ZStack {
                Circle()
                    .fill(card.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: card.systemImage)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(card.color)
                    .scaleEffect(animationScale)
                    .opacity(animationOpacity)
            }
            .scaleEffect(isActive ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)
            
            // Card Content
            VStack(spacing: 12) {
                Text(card.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(card.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .opacity(isActive ? 1.0 : 0.7)
            .animation(.easeInOut(duration: 0.3), value: isActive)
        }
        .padding(.horizontal, 40)
        .onAppear {
            startAnimation()
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            animationScale = 1.1
            animationOpacity = 1.0
        }
    }
}

#Preview {
    OnboardingView()
}
