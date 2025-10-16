//
//  AddHabitView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Habit) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "#E70104"
    @State private var targetFrequency = 7
    
    private let availableIcons = [
        "star.fill", "heart.fill", "flame.fill", "leaf.fill", "drop.fill",
        "book.fill", "dumbbell.fill", "figure.walk", "bed.double.fill", "cup.and.saucer.fill",
        "brain.head.profile", "lungs.fill", "eye.fill", "ear.fill", "hand.raised.fill"
    ]
    
    private let availableColors = [
        "#E70104", "#FF6B35", "#F7931E", "#FFD23F", "#06D6A0",
        "#118AB2", "#073B4C", "#8E44AD", "#E91E63", "#795548"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        VStack(spacing: 16) {
                            Text("Preview")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: selectedColor))
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: selectedColor).opacity(0.1))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name.isEmpty ? "Habit Name" : name)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(description.isEmpty ? "Description" : description)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Habit Name")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter habit name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter description", text: $description)
                                .lineLimit(3)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Icon selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedIcon == icon ? .white : Color(hex: selectedColor))
                                            .frame(width: 44, height: 44)
                                            .background(selectedIcon == icon ? Color(hex: selectedColor) : Color(hex: selectedColor).opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Color selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        
                        // Target frequency
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Target Frequency")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("\(targetFrequency) times per week")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#E70104"))
                                    
                                    Spacer()
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(targetFrequency) },
                                    set: { targetFrequency = Int($0) }
                                ), in: 1...7, step: 1)
                                .tint(Color(hex: "#E70104"))
                            }
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
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(name.isEmpty ? .gray : Color(hex: "#E70104"))
                }
            }
        }
    }
    
    private func saveHabit() {
        let habit = Habit(
            name: name,
            description: description,
            icon: selectedIcon,
            color: selectedColor,
            targetFrequency: targetFrequency
        )
        onSave(habit)
        dismiss()
    }
}

struct EditHabitView: View {
    @Environment(\.dismiss) private var dismiss
    let habit: Habit
    let onSave: (Habit) -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var targetFrequency: Int
    
    private let availableIcons = [
        "star.fill", "heart.fill", "flame.fill", "leaf.fill", "drop.fill",
        "book.fill", "dumbbell.fill", "figure.walk", "bed.double.fill", "cup.and.saucer.fill",
        "brain.head.profile", "lungs.fill", "eye.fill", "ear.fill", "hand.raised.fill"
    ]
    
    private let availableColors = [
        "#E70104", "#FF6B35", "#F7931E", "#FFD23F", "#06D6A0",
        "#118AB2", "#073B4C", "#8E44AD", "#E91E63", "#795548"
    ]
    
    init(habit: Habit, onSave: @escaping (Habit) -> Void) {
        self.habit = habit
        self.onSave = onSave
        _name = State(initialValue: habit.name)
        _description = State(initialValue: habit.description)
        _selectedIcon = State(initialValue: habit.icon)
        _selectedColor = State(initialValue: habit.color)
        _targetFrequency = State(initialValue: habit.targetFrequency)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        VStack(spacing: 16) {
                            Text("Preview")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 16) {
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: selectedColor))
                                    .frame(width: 50, height: 50)
                                    .background(Color(hex: selectedColor).opacity(0.1))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name.isEmpty ? "Habit Name" : name)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(description.isEmpty ? "Description" : description)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Habit Name")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter habit name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Enter description", text: $description)
                                .lineLimit(3)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Icon selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedIcon == icon ? .white : Color(hex: selectedColor))
                                            .frame(width: 44, height: 44)
                                            .background(selectedIcon == icon ? Color(hex: selectedColor) : Color(hex: selectedColor).opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Color selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                                ForEach(availableColors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                        
                        // Target frequency
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Target Frequency")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("\(targetFrequency) times per week")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#E70104"))
                                    
                                    Spacer()
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(targetFrequency) },
                                    set: { targetFrequency = Int($0) }
                                ), in: 1...7, step: 1)
                                .tint(Color(hex: "#E70104"))
                            }
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
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(name.isEmpty ? .gray : Color(hex: "#E70104"))
                }
            }
        }
    }
    
    private func saveHabit() {
        var updatedHabit = habit
        updatedHabit.name = name
        updatedHabit.description = description
        updatedHabit.icon = selectedIcon
        updatedHabit.color = selectedColor
        updatedHabit.targetFrequency = targetFrequency
        
        onSave(updatedHabit)
        dismiss()
    }
}

#Preview {
    AddHabitView { _ in }
}
