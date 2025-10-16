//
//  AddTaskView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Task) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority = Task.Priority.medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter task title", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter description", text: $description)
                                .lineLimit(4)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(Task.Priority.allCases, id: \.self) { priorityOption in
                                    Button(action: { priority = priorityOption }) {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(Color(priorityOption.color))
                                                .frame(width: 12, height: 12)
                                            
                                            Text(priorityOption.rawValue)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(priority == priorityOption ? Color(hex: "#E70104").opacity(0.1) : Color.white)
                                        .foregroundColor(priority == priorityOption ? Color(hex: "#E70104") : .primary)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(priority == priorityOption ? Color(hex: "#E70104") : Color.clear, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Due Date
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Due Date")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $hasDueDate)
                                    .tint(Color(hex: "#E70104"))
                            }
                            
                            if hasDueDate {
                                DatePicker("Select due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(title.isEmpty ? .gray : Color(hex: "#E70104"))
                }
            }
        }
    }
    
    private func saveTask() {
        let task = Task(
            title: title,
            description: description,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        onSave(task)
        dismiss()
    }
}

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let task: Task
    let onSave: (Task) -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var priority: Task.Priority
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    
    init(task: Task, onSave: @escaping (Task) -> Void) {
        self.task = task
        self.onSave = onSave
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description)
        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _hasDueDate = State(initialValue: task.dueDate != nil)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter task title", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter description", text: $description)
                                .lineLimit(4)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(Task.Priority.allCases, id: \.self) { priorityOption in
                                    Button(action: { priority = priorityOption }) {
                                        HStack(spacing: 8) {
                                            Circle()
                                                .fill(Color(priorityOption.color))
                                                .frame(width: 12, height: 12)
                                            
                                            Text(priorityOption.rawValue)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(priority == priorityOption ? Color(hex: "#E70104").opacity(0.1) : Color.white)
                                        .foregroundColor(priority == priorityOption ? Color(hex: "#E70104") : .primary)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(priority == priorityOption ? Color(hex: "#E70104") : Color.clear, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Due Date
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Due Date")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $hasDueDate)
                                    .tint(Color(hex: "#E70104"))
                            }
                            
                            if hasDueDate {
                                DatePicker("Select due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(title.isEmpty ? .gray : Color(hex: "#E70104"))
                }
            }
        }
    }
    
    private func saveTask() {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.description = description
        updatedTask.priority = priority
        updatedTask.dueDate = hasDueDate ? dueDate : nil
        
        onSave(updatedTask)
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .font(.system(size: 16, design: .rounded))
    }
}

#Preview {
    AddTaskView { _ in }
}
