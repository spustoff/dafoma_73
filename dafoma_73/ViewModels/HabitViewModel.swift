//
//  HabitViewModel.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation
import SwiftUI

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var showingAddHabit = false
    @Published var editingHabit: Habit?
    
    private let dataService = DataService.shared
    
    init() {
        loadHabits()
    }
    
    // MARK: - Data Management
    
    func loadHabits() {
        habits = dataService.loadHabits()
    }
    
    private func saveHabits() {
        dataService.saveHabits(habits)
    }
    
    // MARK: - Habit Operations
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    func toggleHabitCompletion(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            if habits[index].isCompletedToday() {
                habits[index].removeCompletion()
            } else {
                habits[index].markCompleted()
            }
            saveHabits()
        }
    }
    
    func markHabitCompleted(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].markCompleted()
            saveHabits()
        }
    }
    
    // MARK: - Computed Properties
    
    var activeHabits: [Habit] {
        habits.filter { $0.isActive }
    }
    
    var completedTodayCount: Int {
        activeHabits.filter { $0.isCompletedToday() }.count
    }
    
    var totalActiveHabits: Int {
        activeHabits.count
    }
    
    var todayCompletionRate: Double {
        guard totalActiveHabits > 0 else { return 0 }
        return Double(completedTodayCount) / Double(totalActiveHabits)
    }
    
    var averageStreak: Double {
        let streaks = activeHabits.map { $0.currentStreak }
        guard !streaks.isEmpty else { return 0 }
        return Double(streaks.reduce(0, +)) / Double(streaks.count)
    }
    
    var longestCurrentStreak: Int {
        activeHabits.map { $0.currentStreak }.max() ?? 0
    }
    
    // MARK: - Statistics
    
    func weeklyStats() -> [String: Int] {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        var stats: [String: Int] = [:]
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStart) ?? Date()
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            let completedCount = activeHabits.filter { habit in
                habit.completions.contains { calendar.isDate($0, inSameDayAs: date) }
            }.count
            
            stats[dayName] = completedCount
        }
        
        return stats
    }
    
    func habitsByCategory() -> [String: [Habit]] {
        var categories: [String: [Habit]] = [:]
        
        for habit in activeHabits {
            let category = categorizeHabit(habit)
            if categories[category] == nil {
                categories[category] = []
            }
            categories[category]?.append(habit)
        }
        
        return categories
    }
    
    private func categorizeHabit(_ habit: Habit) -> String {
        // Simple categorization based on habit name/icon
        let name = habit.name.lowercased()
        
        if name.contains("exercise") || name.contains("workout") || name.contains("run") {
            return "Fitness"
        } else if name.contains("read") || name.contains("learn") || name.contains("study") {
            return "Learning"
        } else if name.contains("meditat") || name.contains("mindful") || name.contains("journal") {
            return "Wellness"
        } else if name.contains("water") || name.contains("sleep") || name.contains("eat") {
            return "Health"
        } else {
            return "Other"
        }
    }
}
