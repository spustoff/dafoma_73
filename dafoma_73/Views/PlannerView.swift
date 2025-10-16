//
//  PlannerView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var viewModel: PlannerViewModel
    @State private var showingAddTask = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with date and stats
                    headerView
                    
                    // Task list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.todayTasks.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(viewModel.tasksByPriority()) { task in
                                    TaskRowView(task: task) {
                                        viewModel.toggleTaskCompletion(task)
                                    } onEdit: {
                                        selectedTask = task
                                    } onDelete: {
                                        viewModel.deleteTask(task)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Daily Planner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#E70104"))
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView { task in
                viewModel.addTask(task)
            }
        }
        .sheet(item: $selectedTask) { task in
            EditTaskView(task: task) { updatedTask in
                viewModel.updateTask(updatedTask)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Date selector
            HStack {
                Button(action: { 
                    viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "#E70104"))
                }
                
                Spacer()
                
                Text(viewModel.selectedDate, style: .date)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Button(action: { 
                    viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) ?? viewModel.selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "#E70104"))
                }
            }
            .padding(.horizontal, 20)
            
            // Progress stats
            HStack(spacing: 20) {
                StatCard(
                    title: "Completed",
                    value: "\(viewModel.completedTasks.count)",
                    subtitle: "of \(viewModel.todayTasks.count) tasks"
                )
                
                StatCard(
                    title: "Progress",
                    value: "\(Int(viewModel.completionRate * 100))%",
                    subtitle: "completion rate"
                )
                
                StatCard(
                    title: "Priority",
                    value: "\(viewModel.highPriorityTasks.count)",
                    subtitle: "high priority"
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
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#E70104").opacity(0.6))
            
            Text("No tasks for today")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Tap the + button to add your first task")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddTask = true }) {
                Text("Add Task")
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

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? Color(hex: "#E70104") : .gray)
            }
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    // Priority indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(task.priority.color))
                            .frame(width: 8, height: 8)
                        Text(task.priority.rawValue)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Due date
                    if let dueDate = task.dueDate {
                        Text(dueDate, style: .time)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Actions
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

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#E70104"))
            
            Text(subtitle)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: "#F0F1F3"))
        .cornerRadius(8)
    }
}

#Preview {
    PlannerView()
        .environmentObject(PlannerViewModel())
}
