//
//  OnboardingView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to DailyWellSuper",
            subtitle: "Your personal companion for daily wellness and productivity",
            imageName: "heart.fill",
            description: "Transform your daily routine with our innovative approach to habit tracking, goal setting, and mindful living."
        ),
        OnboardingPage(
            title: "Track Your Habits",
            subtitle: "Build consistency with smart habit tracking",
            imageName: "checkmark.circle.fill",
            description: "Monitor your daily habits, build streaks, and celebrate your progress with beautiful visualizations."
        ),
        OnboardingPage(
            title: "Achieve Your Goals",
            subtitle: "Set meaningful goals and track progress",
            imageName: "target",
            description: "Break down big dreams into achievable milestones and watch yourself grow every day."
        ),
        OnboardingPage(
            title: "Plan Your Day",
            subtitle: "Organize tasks with priority-based planning",
            imageName: "calendar",
            description: "Stay organized with our intuitive daily planner that adapts to your lifestyle and priorities."
        ),
        OnboardingPage(
            title: "Mindful Moments",
            subtitle: "Reflect and grow with guided mindfulness",
            imageName: "leaf.fill",
            description: "Take time for reflection with daily prompts and mindfulness exercises designed for your wellbeing."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F0F1F3")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentPage ? Color(hex: "#E70104") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button(action: completeOnboarding) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: "#E70104"))
                                .cornerRadius(16)
                        }
                    } else {
                        HStack {
                            Button(action: completeOnboarding) {
                                Text("Skip")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#E70104"))
                            }
                            
                            Spacer()
                            
                            Button(action: nextPage) {
                                Text("Next")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 44)
                                    .background(Color(hex: "#E70104"))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func nextPage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage += 1
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let imageName: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(Color(hex: "#E70104"))
                .frame(height: 120)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#E70104"))
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// Color extension for hex colors
extension Color {
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
}

#Preview {
    OnboardingView()
}
