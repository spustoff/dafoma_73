//
//  AddGoalView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Goal) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = Goal.Category.personal
    @State private var targetValue: Double = 100
    @State private var unit = ""
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Title")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter goal title", text: $title)
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
                        
                        // Category
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(Goal.Category.allCases, id: \.self) { category in
                                    Button(action: { selectedCategory = category }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 16))
                                                .foregroundColor(selectedCategory == category ? .white : Color(category.color))
                                            
                                            Text(category.rawValue)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedCategory == category ? Color(category.color) : Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedCategory == category ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Target value and unit
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Target Value")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("100", value: $targetValue, format: .number)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unit")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("kg, hours, etc.", text: $unit)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        
                        // Target date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Date")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            DatePicker("Select target date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || unit.isEmpty)
                    .foregroundColor(title.isEmpty || unit.isEmpty ? .gray : Color(hex: "#E70104"))
                }
            }
        }
    }
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            description: description,
            category: selectedCategory,
            targetValue: targetValue,
            unit: unit,
            targetDate: targetDate
        )
        onSave(goal)
        dismiss()
    }
}

struct EditGoalView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    let onSave: (Goal) -> Void
    
    @State private var title: String
    @State private var description: String
    @State private var selectedCategory: Goal.Category
    @State private var targetValue: Double
    @State private var unit: String
    @State private var targetDate: Date
    
    init(goal: Goal, onSave: @escaping (Goal) -> Void) {
        self.goal = goal
        self.onSave = onSave
        _title = State(initialValue: goal.title)
        _description = State(initialValue: goal.description)
        _selectedCategory = State(initialValue: goal.category)
        _targetValue = State(initialValue: goal.targetValue)
        _unit = State(initialValue: goal.unit)
        _targetDate = State(initialValue: goal.targetDate)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Title")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter goal title", text: $title)
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
                        
                        // Category
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(Goal.Category.allCases, id: \.self) { category in
                                    Button(action: { selectedCategory = category }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 16))
                                                .foregroundColor(selectedCategory == category ? .white : Color(category.color))
                                            
                                            Text(category.rawValue)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedCategory == category ? Color(category.color) : Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedCategory == category ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        
                        // Target value and unit
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Target Value")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("100", value: $targetValue, format: .number)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .keyboardType(.decimalPad)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unit")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                TextField("kg, hours, etc.", text: $unit)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        
                        // Target date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Date")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            DatePicker("Select target date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || unit.isEmpty)
                    .foregroundColor(title.isEmpty || unit.isEmpty ? .gray : Color(hex: "#E70104"))
                }
            }
        }
    }
    
    private func saveGoal() {
        var updatedGoal = goal
        updatedGoal.title = title
        updatedGoal.description = description
        updatedGoal.category = selectedCategory
        updatedGoal.targetValue = targetValue
        updatedGoal.unit = unit
        updatedGoal.targetDate = targetDate
        
        onSave(updatedGoal)
        dismiss()
    }
}

struct UpdateProgressView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    let onSave: (Double) -> Void
    
    @State private var newValue: Double
    
    init(goal: Goal, onSave: @escaping (Double) -> Void) {
        self.goal = goal
        self.onSave = onSave
        _newValue = State(initialValue: goal.currentValue)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Goal info
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: goal.category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(Color(goal.category.color))
                                .frame(width: 48, height: 48)
                                .background(Color(goal.category.color).opacity(0.1))
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.title)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(goal.category.rawValue)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(goal.category.color))
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    
                    // Progress update
                    VStack(spacing: 20) {
                        Text("Update Progress")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Current Progress")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(Int(newValue))/\(Int(goal.targetValue)) \(goal.unit)")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#E70104"))
                            }
                            
                            TextField("Enter new value", value: $newValue, format: .number)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            // Progress visualization
                            VStack(spacing: 8) {
                                ProgressView(value: min(newValue / goal.targetValue, 1.0))
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#E70104")))
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                                
                                Text("\(Int(min(newValue / goal.targetValue, 1.0) * 100))% Complete")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(newValue)
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#E70104"))
                }
            }
        }
    }
}

#Preview {
    AddGoalView { _ in }
}
