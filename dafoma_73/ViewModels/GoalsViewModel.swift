//
//  GoalsViewModel.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation
import SwiftUI

class GoalsViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var showingAddGoal = false
    @Published var editingGoal: Goal?
    @Published var selectedCategory: Goal.Category?
    
    private let dataService = DataService.shared
    
    init() {
        loadGoals()
    }
    
    // MARK: - Data Management
    
    func loadGoals() {
        goals = dataService.loadGoals()
    }
    
    private func saveGoals() {
        dataService.saveGoals(goals)
    }
    
    // MARK: - Goal Operations
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func updateGoalProgress(_ goal: Goal, newValue: Double) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].updateProgress(newValue)
            saveGoals()
        }
    }
    
    func addMilestone(to goal: Goal, milestone: Goal.Milestone) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].addMilestone(milestone)
            saveGoals()
        }
    }
    
    // MARK: - Computed Properties
    
    var activeGoals: [Goal] {
        goals.filter { !$0.isCompleted }
    }
    
    var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }
    }
    
    var overdueGoals: [Goal] {
        goals.filter { $0.isOverdue }
    }
    
    var upcomingDeadlines: [Goal] {
        let calendar = Calendar.current
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        
        return activeGoals.filter { goal in
            goal.targetDate <= nextWeek && goal.targetDate >= Date()
        }.sorted { $0.targetDate < $1.targetDate }
    }
    
    var overallProgress: Double {
        guard !goals.isEmpty else { return 0 }
        let totalProgress = goals.map { $0.progress }.reduce(0, +)
        return totalProgress / Double(goals.count)
    }
    
    var completionRate: Double {
        guard !goals.isEmpty else { return 0 }
        return Double(completedGoals.count) / Double(goals.count)
    }
    
    // MARK: - Filtering and Sorting
    
    func goalsByCategory() -> [Goal.Category: [Goal]] {
        var categorizedGoals: [Goal.Category: [Goal]] = [:]
        
        for category in Goal.Category.allCases {
            categorizedGoals[category] = goals.filter { $0.category == category }
        }
        
        return categorizedGoals
    }
    
    func filteredGoals() -> [Goal] {
        if let selectedCategory = selectedCategory {
            return goals.filter { $0.category == selectedCategory }
        }
        return goals
    }
    
    func goalsSortedByProgress() -> [Goal] {
        activeGoals.sorted { $0.progress > $1.progress }
    }
    
    func goalsSortedByDeadline() -> [Goal] {
        activeGoals.sorted { $0.targetDate < $1.targetDate }
    }
    
    // MARK: - Statistics
    
    func categoryProgress() -> [Goal.Category: Double] {
        var categoryProgress: [Goal.Category: Double] = [:]
        
        for category in Goal.Category.allCases {
            let categoryGoals = goals.filter { $0.category == category }
            if !categoryGoals.isEmpty {
                let totalProgress = categoryGoals.map { $0.progress }.reduce(0, +)
                categoryProgress[category] = totalProgress / Double(categoryGoals.count)
            } else {
                categoryProgress[category] = 0
            }
        }
        
        return categoryProgress
    }
    
    func monthlyProgress() -> [String: Double] {
        let calendar = Calendar.current
        var monthlyProgress: [String: Double] = [:]
        
        // Get last 6 months
        for i in 0..<6 {
            let date = calendar.date(byAdding: .month, value: -i, to: Date()) ?? Date()
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: date) - 1]
            
            let monthGoals = goals.filter { goal in
                calendar.isDate(goal.createdDate, equalTo: date, toGranularity: .month)
            }
            
            if !monthGoals.isEmpty {
                let totalProgress = monthGoals.map { $0.progress }.reduce(0, +)
                monthlyProgress[monthName] = totalProgress / Double(monthGoals.count)
            } else {
                monthlyProgress[monthName] = 0
            }
        }
        
        return monthlyProgress
    }
    
    func recentAchievements() -> [Goal] {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        
        return completedGoals.filter { goal in
            goal.targetDate >= lastWeek
        }.sorted { $0.targetDate > $1.targetDate }
    }
}
