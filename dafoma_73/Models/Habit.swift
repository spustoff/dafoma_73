//
//  Habit.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation

struct Habit: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var description: String
    var icon: String
    var color: String
    var targetFrequency: Int // times per week
    var createdDate: Date
    var completions: [Date]
    var isActive: Bool
    
    init(name: String, description: String = "", icon: String = "star.fill", color: String = "#E70104", targetFrequency: Int = 7) {
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.targetFrequency = targetFrequency
        self.createdDate = Date()
        self.completions = []
        self.isActive = true
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today
        
        while completions.contains(where: { calendar.isDate($0, inSameDayAs: checkDate) }) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        return streak
    }
    
    var longestStreak: Int {
        guard !completions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedCompletions = completions.sorted()
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedCompletions.count {
            let previousDate = calendar.startOfDay(for: sortedCompletions[i-1])
            let currentDate = calendar.startOfDay(for: sortedCompletions[i])
            
            if calendar.dateInterval(of: .day, for: previousDate)?.end == currentDate {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
    
    var weeklyProgress: Double {
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let weekEnd = calendar.dateInterval(of: .weekOfYear, for: Date())?.end ?? Date()
        
        let weekCompletions = completions.filter { completion in
            completion >= weekStart && completion <= weekEnd
        }.count
        
        return min(Double(weekCompletions) / Double(targetFrequency), 1.0)
    }
    
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return completions.contains { calendar.isDateInToday($0) }
    }
    
    mutating func markCompleted() {
        let calendar = Calendar.current
        let today = Date()
        
        // Remove any existing completion for today
        completions.removeAll { calendar.isDate($0, inSameDayAs: today) }
        
        // Add new completion
        completions.append(today)
    }
    
    mutating func removeCompletion() {
        let calendar = Calendar.current
        let today = Date()
        
        completions.removeAll { calendar.isDate($0, inSameDayAs: today) }
    }
}
