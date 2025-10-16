//
//  PlannerViewModel.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import Foundation
import SwiftUI

class PlannerViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedDate = Date()
    @Published var showingAddTask = false
    @Published var editingTask: Task?
    
    private let dataService = DataService.shared
    
    init() {
        loadTasks()
    }
    
    // MARK: - Data Management
    
    func loadTasks() {
        tasks = dataService.loadTasks()
    }
    
    private func saveTasks() {
        dataService.saveTasks(tasks)
    }
    
    // MARK: - Task Operations
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].toggleCompletion()
            saveTasks()
        }
    }
    
    // MARK: - Computed Properties
    
    var todayTasks: [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            if let dueDate = task.dueDate {
                return calendar.isDate(dueDate, inSameDayAs: selectedDate)
            }
            return calendar.isDate(task.createdDate, inSameDayAs: selectedDate)
        }
    }
    
    var completedTasks: [Task] {
        todayTasks.filter { $0.isCompleted }
    }
    
    var pendingTasks: [Task] {
        todayTasks.filter { !$0.isCompleted }
    }
    
    var highPriorityTasks: [Task] {
        pendingTasks.filter { $0.priority == .high }
    }
    
    var overdueTasks: [Task] {
        let now = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < now && !task.isCompleted
        }
    }
    
    var completionRate: Double {
        let total = todayTasks.count
        guard total > 0 else { return 0 }
        let completed = completedTasks.count
        return Double(completed) / Double(total)
    }
    
    // MARK: - Filtering and Sorting
    
    func tasksByPriority() -> [Task] {
        todayTasks.sorted { task1, task2 in
            if task1.priority != task2.priority {
                return task1.priority.rawValue > task2.priority.rawValue
            }
            return task1.createdDate < task2.createdDate
        }
    }
    
    func tasksForDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return tasks.filter { task in
            if let dueDate = task.dueDate {
                return calendar.isDate(dueDate, inSameDayAs: date)
            }
            return calendar.isDate(task.createdDate, inSameDayAs: date)
        }
    }
}
