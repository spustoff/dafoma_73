//
//  GoalsView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var viewModel: GoalsViewModel
    @State private var showingAddGoal = false
    @State private var selectedGoal: Goal?
    @State private var showingProgressUpdate: Goal?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with stats
                    headerView
                    
                    // Goals list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.goals.isEmpty {
                                emptyStateView
                            } else {
                                // Active goals
                                if !viewModel.activeGoals.isEmpty {
                                    sectionHeader("Active Goals")
                                    ForEach(viewModel.activeGoals) { goal in
                                        GoalRowView(goal: goal) {
                                            showingProgressUpdate = goal
                                        } onEdit: {
                                            selectedGoal = goal
                                        } onDelete: {
                                            viewModel.deleteGoal(goal)
                                        }
                                    }
                                }
                                
                                // Completed goals
                                if !viewModel.completedGoals.isEmpty {
                                    sectionHeader("Completed Goals")
                                    ForEach(viewModel.completedGoals) { goal in
                                        GoalRowView(goal: goal) {
                                            // No action for completed goals
                                        } onEdit: {
                                            selectedGoal = goal
                                        } onDelete: {
                                            viewModel.deleteGoal(goal)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#E70104"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView { goal in
                viewModel.addGoal(goal)
            }
        }
        .sheet(item: $selectedGoal) { goal in
            EditGoalView(goal: goal) { updatedGoal in
                viewModel.updateGoal(updatedGoal)
            }
        }
        .sheet(item: $showingProgressUpdate) { goal in
            UpdateProgressView(goal: goal) { newValue in
                viewModel.updateGoalProgress(goal, newValue: newValue)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Overall progress
            HStack {
                Text("Overall Progress")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Text("\(Int(viewModel.overallProgress * 100))%")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#E70104"))
            }
            .padding(.horizontal, 20)
            
            // Progress bar
            ProgressView(value: viewModel.overallProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#E70104")))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.horizontal, 20)
            
            // Stats cards
            HStack(spacing: 16) {
                StatCard(
                    title: "Active",
                    value: "\(viewModel.activeGoals.count)",
                    subtitle: "goals"
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(viewModel.completedGoals.count)",
                    subtitle: "goals"
                )
                
                StatCard(
                    title: "Overdue",
                    value: "\(viewModel.overdueGoals.count)",
                    subtitle: "goals"
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#E70104").opacity(0.6))
            
            Text("No goals yet")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Set your first goal and start your journey to success")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddGoal = true }) {
                Text("Add Goal")
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

struct GoalRowView: View {
    let goal: Goal
    let onUpdateProgress: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack(spacing: 12) {
                // Category icon
                Image(systemName: goal.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(goal.category.color))
                    .frame(width: 36, height: 36)
                    .background(Color(goal.category.color).opacity(0.1))
                    .cornerRadius(8)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(goal.category.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(goal.category.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(goal.category.color).opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                // Progress percentage
                Text("\(goal.progressPercentage)%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(goal.isCompleted ? .green : Color(hex: "#E70104"))
                
                // Menu
                Menu {
                    if !goal.isCompleted {
                        Button("Update Progress", action: onUpdateProgress)
                    }
                    Button("Edit", action: onEdit)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Progress bar
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: goal.isCompleted ? .green : Color(hex: "#E70104")))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
            
            // Details
            HStack {
                // Current/Target values
                Text("\(Int(goal.currentValue))/\(Int(goal.targetValue)) \(goal.unit)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Days remaining or status
                if goal.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("Completed")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.green)
                    }
                } else if goal.isOverdue {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                        Text("Overdue")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("\(goal.daysRemaining) days left")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    GoalsView()
        .environmentObject(GoalsViewModel())
}
