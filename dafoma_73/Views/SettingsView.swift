//
//  SettingsView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var dailyReminderTime = Date()
    @AppStorage("weeklyGoalReview") private var weeklyGoalReview = true
    @AppStorage("habitStreakNotifications") private var habitStreakNotifications = true
    
    @State private var showingDataExport = false
    @State private var showingResetConfirmation = false
    @State private var exportedData: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile section
                        profileSection
                        
                        // Notifications section
                        notificationsSection
                        
                        // Data management section
                        dataManagementSection
                        
                        // Reset section
                        resetSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView(data: exportedData)
        }
        .alert("Reset All Data", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will permanently delete all your tasks, habits, goals, and journal entries. This action cannot be undone.")
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Profile")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "#E70104"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DailyWell User")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Building better habits daily")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Member since")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("October 2025")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Session ID")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text("7192")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#E70104"))
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    private var notificationsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Notifications")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Enable Notifications",
                    subtitle: "Get reminders and updates"
                ) {
                    Toggle("", isOn: $notificationsEnabled)
                        .tint(Color(hex: "#E70104"))
                }
                
                if notificationsEnabled {
                    Divider()
                        .padding(.leading, 44)
                    
                    SettingsRow(
                        icon: "clock.fill",
                        title: "Daily Reminder",
                        subtitle: "Time for daily check-in"
                    ) {
                        DatePicker("", selection: $dailyReminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    Divider()
                        .padding(.leading, 44)
                    
                    SettingsRow(
                        icon: "target",
                        title: "Weekly Goal Review",
                        subtitle: "Review progress weekly"
                    ) {
                        Toggle("", isOn: $weeklyGoalReview)
                            .tint(Color(hex: "#E70104"))
                    }
                    
                    Divider()
                        .padding(.leading, 44)
                    
                    SettingsRow(
                        icon: "flame.fill",
                        title: "Habit Streaks",
                        subtitle: "Celebrate your streaks"
                    ) {
                        Toggle("", isOn: $habitStreakNotifications)
                            .tint(Color(hex: "#E70104"))
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    private var dataManagementSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Data Management")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsButton(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Save your data as JSON",
                    action: exportData
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsButton(
                    icon: "icloud.and.arrow.up",
                    title: "Backup to iCloud",
                    subtitle: "Coming soon",
                    action: { },
                    isDisabled: true
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsButton(
                    icon: "arrow.clockwise",
                    title: "Sync Data",
                    subtitle: "Manual sync (local only)",
                    action: syncData
                )
            }
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("About")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsButton(
                    icon: "info.circle",
                    title: "App Version",
                    subtitle: "1.0.0 (Build 1)",
                    action: { }
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsButton(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Help us improve",
                    action: rateApp
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsButton(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    subtitle: "Get help and send feedback",
                    action: contactSupport
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsButton(
                    icon: "doc.text",
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    action: showPrivacyPolicy
                )
            }
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    private var resetSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Reset")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 0) {
                SettingsButton(
                    icon: "arrow.counterclockwise",
                    title: "Reset Onboarding",
                    subtitle: "Show welcome screens again",
                    action: resetOnboarding
                )
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsButton(
                    icon: "trash.fill",
                    title: "Reset All Data",
                    subtitle: "Delete everything permanently",
                    action: { showingResetConfirmation = true },
                    isDestructive: true
                )
            }
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Actions
    
    private func exportData() {
        let data = DataService.shared.exportData()
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            exportedData = jsonString
            showingDataExport = true
        }
    }
    
    private func syncData() {
        // Simulate sync - for now just a placeholder
        print("Sync data action")
    }
    
    private func rateApp() {
        // In a real app, this would open the App Store rating
        print("Rate app action")
    }
    
    private func contactSupport() {
        // In a real app, this would open mail or support system
        print("Contact support action")
    }
    
    private func showPrivacyPolicy() {
        // In a real app, this would show privacy policy
        print("Privacy policy action")
    }
    
    private func resetOnboarding() {
        hasCompletedOnboarding = false
    }
    
    private func resetAllData() {
        DataService.shared.clearAllData()
        hasCompletedOnboarding = false
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: Content
    
    init(icon: String, title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "#E70104"))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    var isDisabled: Bool = false
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : (isDisabled ? .gray : Color(hex: "#E70104")))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(isDestructive ? .red : (isDisabled ? .gray : .primary))
                    
                    Text(subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isDisabled {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .disabled(isDisabled)
    }
}

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    let data: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Your exported data is ready!")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Copy the data below or share it using the share button.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text(data)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.primary)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .textSelection(.enabled)
                        
                        Button(action: shareData) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Data")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "#E70104"))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareData() {
        let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    SettingsView()
}
