//
//  Goal.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation

struct Goal: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var category: Category
    var targetValue: Double
    var currentValue: Double
    var unit: String
    var targetDate: Date
    var createdDate: Date
    var isCompleted: Bool
    var milestones: [Milestone]
    
    enum Category: String, CaseIterable, Codable {
        case health = "Health"
        case fitness = "Fitness"
        case learning = "Learning"
        case career = "Career"
        case personal = "Personal"
        case financial = "Financial"
        case social = "Social"
        
        var icon: String {
            switch self {
            case .health: return "heart.fill"
            case .fitness: return "figure.run"
            case .learning: return "book.fill"
            case .career: return "briefcase.fill"
            case .personal: return "person.fill"
            case .financial: return "dollarsign.circle.fill"
            case .social: return "person.2.fill"
            }
        }
        
        var color: String {
            switch self {
            case .health: return "red"
            case .fitness: return "orange"
            case .learning: return "blue"
            case .career: return "purple"
            case .personal: return "green"
            case .financial: return "yellow"
            case .social: return "pink"
            }
        }
    }
    
    struct Milestone: Identifiable, Codable, Hashable {
        let id = UUID()
        var title: String
        var targetValue: Double
        var isCompleted: Bool
        var completedDate: Date?
        
        init(title: String, targetValue: Double) {
            self.title = title
            self.targetValue = targetValue
            self.isCompleted = false
            self.completedDate = nil
        }
        
        mutating func markCompleted() {
            isCompleted = true
            completedDate = Date()
        }
    }
    
    init(title: String, description: String = "", category: Category, targetValue: Double, unit: String, targetDate: Date) {
        self.title = title
        self.description = description
        self.category = category
        self.targetValue = targetValue
        self.currentValue = 0
        self.unit = unit
        self.targetDate = targetDate
        self.createdDate = Date()
        self.isCompleted = false
        self.milestones = []
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: targetDate)
        
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }
    
    var isOverdue: Bool {
        return Date() > targetDate && !isCompleted
    }
    
    mutating func updateProgress(_ value: Double) {
        currentValue = min(value, targetValue)
        if currentValue >= targetValue {
            isCompleted = true
        }
        
        // Check and update milestones
        for i in milestones.indices {
            if !milestones[i].isCompleted && currentValue >= milestones[i].targetValue {
                milestones[i].markCompleted()
            }
        }
    }
    
    mutating func addMilestone(_ milestone: Milestone) {
        milestones.append(milestone)
        milestones.sort { $0.targetValue < $1.targetValue }
    }
}
