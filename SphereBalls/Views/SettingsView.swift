//
//  SettingsView.swift
//  SphereBalls
//
//  Created by Lukos on 9/3/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var onboardingManager = OnboardingManager()
    @State private var showingResetAlert = false
    
    let colorColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Enhanced background
                LinearGradient(
                    gradient: Gradient(colors: [
                        settings.isDarkMode ? Color.black : Color.white,
                        settings.isDarkMode ? Color.gray.opacity(0.1) : Color.blue.opacity(0.03),
                        settings.isDarkMode ? Color.purple.opacity(0.1) : Color.purple.opacity(0.02)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Ball Color Section
                        SettingsSection(
                            title: "Ball Color",
                            icon: "paintpalette.fill",
                            iconColor: .blue
                        ) {
                            LazyVGrid(columns: colorColumns, spacing: 20) {
                                ForEach(BallColor.allCases) { color in
                                    ColorSelectionButton(
                                        color: color,
                                        isSelected: settings.ballColor == color
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            settings.ballColor = color
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                        }
                        
                        // Ball Size Section
                        SettingsSection(
                            title: "Ball Size",
                            icon: "circle.grid.cross.fill",
                            iconColor: .green
                        ) {
                            VStack(spacing: 16) {
                                Picker("Size", selection: $settings.ballSize) {
                                    ForEach(BallSize.allCases) { size in
                                        Text(size.rawValue).tag(size)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: settings.ballSize) { _ in
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                                
                                // Size preview
                                HStack(spacing: 20) {
                                    ForEach(BallSize.allCases, id: \.self) { size in
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            settings.ballColor.color.opacity(0.8),
                                                            settings.ballColor.color.opacity(0.4)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: size.diameter * 0.3, height: size.diameter * 0.3)
                                                .scaleEffect(settings.ballSize == size ? 1.1 : 1.0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: settings.ballSize)
                                            
                                            Text(size.rawValue)
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Appearance Section
                        SettingsSection(
                            title: "Appearance",
                            icon: "moon.fill",
                            iconColor: .purple
                        ) {
                            HStack {
                                HStack(spacing: 12) {
                                    Image(systemName: settings.isDarkMode ? "moon.fill" : "sun.max.fill")
                                        .font(.title2)
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    settings.isDarkMode ? .purple : .orange,
                                                    settings.isDarkMode ? .blue : .yellow
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Dark Mode")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text(settings.isDarkMode ? "Dark theme enabled" : "Light theme enabled")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $settings.isDarkMode)
                                    .labelsHidden()
                                    .onChange(of: settings.isDarkMode) { _ in
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                    }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // About Section
                        SettingsSection(
                            title: "About",
                            icon: "info.circle.fill",
                            iconColor: .orange
                        ) {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Version")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("1.0.0")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Button(action: {
                                    onboardingManager.resetOnboarding()
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                    impactFeedback.impactOccurred()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.headline)
                                        Text("Reset Onboarding")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.red, .pink]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    iconColor.opacity(0.2),
                                    iconColor.opacity(0.1)
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
                                    iconColor,
                                    iconColor.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Section Content
            VStack(spacing: 12) {
                content
            }
            .padding(20)
            .background(
                ZStack {
                    // Glassmorphism background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground).opacity(0.8))
                        .background(
                            RoundedRectangle(cornerRadius: 16)
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
                    
                    // Border
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    iconColor.opacity(0.3),
                                    Color.clear,
                                    iconColor.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: iconColor.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            )
        }
    }
}

struct ColorSelectionButton: View {
    let color: BallColor
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.color,
                                color.color.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: isSelected ? 3 : 0)
                    )
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    SettingsView(settings: AppSettings())
}
