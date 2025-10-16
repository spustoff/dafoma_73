//
//  Task.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation

struct Task: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var createdDate: Date
    var completedDate: Date?
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: String {
            switch self {
            case .low: return "green"
            case .medium: return "orange"
            case .high: return "red"
            }
        }
    }
    
    init(title: String, description: String = "", priority: Priority = .medium, dueDate: Date? = nil) {
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.dueDate = dueDate
        self.createdDate = Date()
        self.completedDate = nil
    }
    
    mutating func toggleCompletion() {
        isCompleted.toggle()
        completedDate = isCompleted ? Date() : nil
    }
}
