//
//  DataService.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation

class DataService: ObservableObject {
    static let shared = DataService()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private enum Keys {
        static let tasks = "tasks"
        static let habits = "habits"
        static let goals = "goals"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    private init() {}
    
    // MARK: - Onboarding
    
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { userDefaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    // MARK: - Tasks
    
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: Keys.tasks)
        }
    }
    
    func loadTasks() -> [Task] {
        guard let data = userDefaults.data(forKey: Keys.tasks),
              let tasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return []
        }
        return tasks
    }
    
    // MARK: - Habits
    
    func saveHabits(_ habits: [Habit]) {
        if let encoded = try? JSONEncoder().encode(habits) {
            userDefaults.set(encoded, forKey: Keys.habits)
        }
    }
    
    func loadHabits() -> [Habit] {
        guard let data = userDefaults.data(forKey: Keys.habits),
              let habits = try? JSONDecoder().decode([Habit].self, from: data) else {
            return []
        }
        return habits
    }
    
    // MARK: - Goals
    
    func saveGoals(_ goals: [Goal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: Keys.goals)
        }
    }
    
    func loadGoals() -> [Goal] {
        guard let data = userDefaults.data(forKey: Keys.goals),
              let goals = try? JSONDecoder().decode([Goal].self, from: data) else {
            return []
        }
        return goals
    }
    
    // MARK: - Backup & Restore
    
    func exportData() -> [String: Any] {
        return [
            "tasks": loadTasks(),
            "habits": loadHabits(),
            "goals": loadGoals(),
            "exportDate": Date()
        ]
    }
    
    func clearAllData() {
        userDefaults.removeObject(forKey: Keys.tasks)
        userDefaults.removeObject(forKey: Keys.habits)
        userDefaults.removeObject(forKey: Keys.goals)
        userDefaults.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
}
