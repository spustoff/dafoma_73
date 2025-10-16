//
//  HabitTrackerView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct HabitTrackerView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    headerView
                    
                    // Habit list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.activeHabits.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(viewModel.activeHabits) { habit in
                                    HabitRowView(habit: habit) {
                                        viewModel.toggleHabitCompletion(habit)
                                    } onEdit: {
                                        selectedHabit = habit
                                    } onDelete: {
                                        viewModel.deleteHabit(habit)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Habit Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#E70104"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView { habit in
                viewModel.addHabit(habit)
            }
        }
        .sheet(item: $selectedHabit) { habit in
            EditHabitView(habit: habit) { updatedHabit in
                viewModel.updateHabit(updatedHabit)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Today's progress
            HStack {
                Text("Today's Progress")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Text("\(viewModel.completedTodayCount)/\(viewModel.totalActiveHabits)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#E70104"))
            }
            .padding(.horizontal, 20)
            
            // Progress bar
            ProgressView(value: viewModel.todayCompletionRate)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#E70104")))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 20)
            
            // Stats cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Streak",
                    value: "\(viewModel.longestCurrentStreak)",
                    subtitle: "days"
                )
                
                StatCard(
                    title: "Average",
                    value: String(format: "%.1f", viewModel.averageStreak),
                    subtitle: "streak"
                )
                
                StatCard(
                    title: "Completion",
                    value: "\(Int(viewModel.todayCompletionRate * 100))%",
                    subtitle: "today"
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#E70104").opacity(0.6))
            
            Text("No habits yet")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Start building positive habits by adding your first one")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddHabit = true }) {
                Text("Add Habit")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(Color(hex: "#E70104"))
                    .cornerRadius(12)
            }
        }
        .padding(.top, 60)
    }
}

struct HabitRowView: View {
    let habit: Habit
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: habit.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: habit.color))
                .frame(width: 40, height: 40)
                .background(Color(hex: habit.color).opacity(0.1))
                .cornerRadius(10)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 16) {
                    // Streak
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("\(habit.currentStreak) day streak")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Weekly progress
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        Text("\(Int(habit.weeklyProgress * 100))% this week")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Completion button
            Button(action: onToggle) {
                Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundColor(habit.isCompletedToday() ? Color(hex: "#E70104") : .gray)
            }
            
            // Menu
            Menu {
                Button("Edit", action: onEdit)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HabitTrackerView()
        .environmentObject(HabitViewModel())
}
