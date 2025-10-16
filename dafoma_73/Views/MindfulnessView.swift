//
//  MindfulnessView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct MindfulnessView: View {
    @State private var selectedTab = 0
    @State private var showingJournalEntry = false
    @State private var journalEntries: [JournalEntry] = []
    @State private var dailyPrompt = DailyPrompt.randomPrompt()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Tab selector
                    Picker("Mindfulness Tab", selection: $selectedTab) {
                        Text("Reflect").tag(0)
                        Text("Meditate").tag(1)
                        Text("Journal").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        ReflectionView(dailyPrompt: dailyPrompt)
                            .tag(0)
                        
                        MeditationView()
                            .tag(1)
                        
                        JournalView(entries: $journalEntries, showingEntry: $showingJournalEntry)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Mindfulness")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                selectedTab == 2 ? 
                    AnyView(Button(action: { showingJournalEntry = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#E70104"))
                    }) : AnyView(EmptyView())
            )
        }
        .sheet(isPresented: $showingJournalEntry) {
            JournalEntryView { entry in
                journalEntries.append(entry)
            }
        }
        .onAppear {
            loadJournalEntries()
        }
    }
    
    private func loadJournalEntries() {
        // Load from UserDefaults or other storage
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let entries = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            journalEntries = entries
        }
    }
    
    private func saveJournalEntries() {
        if let data = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(data, forKey: "journalEntries")
        }
    }
}

struct ReflectionView: View {
    let dailyPrompt: DailyPrompt
    @State private var reflection = ""
    @State private var hasReflected = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Daily prompt card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        
                        Text("Daily Reflection")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text(dailyPrompt.prompt)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 8)
                    
                    if !hasReflected {
                        VStack(spacing: 12) {
                            TextField("Share your thoughts...", text: $reflection)
                                .lineLimit(5)
                                .textFieldStyle(CustomTextFieldStyle())
                            
                            Button(action: saveReflection) {
                                Text("Save Reflection")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color(hex: "#E70104"))
                                    .cornerRadius(12)
                            }
                            .disabled(reflection.isEmpty)
                        }
                    } else {
                        VStack(spacing: 8) {
                            Text("✨ Reflection completed for today!")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.green)
                            
                            Text(reflection)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(12)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                
                // Mindfulness tips
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#E70104"))
                        
                        Text("Mindfulness Tips")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    ForEach(MindfulnessTip.tips, id: \.title) { tip in
                        MindfulnessTipCard(tip: tip)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .onAppear {
            loadTodayReflection()
        }
    }
    
    private func saveReflection() {
        let key = "reflection_\(DateFormatter.dayKey.string(from: Date()))"
        UserDefaults.standard.set(reflection, forKey: key)
        hasReflected = true
    }
    
    private func loadTodayReflection() {
        let key = "reflection_\(DateFormatter.dayKey.string(from: Date()))"
        if let savedReflection = UserDefaults.standard.string(forKey: key) {
            reflection = savedReflection
            hasReflected = true
        }
    }
}

struct MeditationView: View {
    @State private var selectedDuration = 5
    @State private var isPlaying = false
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    
    private let durations = [1, 3, 5, 10, 15, 20]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Meditation timer
                VStack(spacing: 20) {
                    Text("Guided Meditation")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Timer display
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: isPlaying ? CGFloat(1.0 - Double(timeRemaining) / Double(selectedDuration * 60)) : 0)
                            .stroke(Color(hex: "#E70104"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timeRemaining)
                        
                        VStack(spacing: 8) {
                            Text(timeString(timeRemaining))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(isPlaying ? "Breathe deeply" : "Ready to start?")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Duration selector
                    if !isPlaying {
                        VStack(spacing: 12) {
                            Text("Duration")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 8) {
                                ForEach(durations, id: \.self) { duration in
                                    Button(action: { selectedDuration = duration }) {
                                        Text("\(duration)m")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(selectedDuration == duration ? .white : Color(hex: "#E70104"))
                                            .frame(width: 44, height: 32)
                                            .background(selectedDuration == duration ? Color(hex: "#E70104") : Color.white)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color(hex: "#E70104"), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Control buttons
                    HStack(spacing: 16) {
                        if isPlaying {
                            Button(action: stopMeditation) {
                                Text("Stop")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 48)
                                    .background(Color.gray)
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: isPlaying ? pauseMeditation : startMeditation) {
                            Text(isPlaying ? "Pause" : "Start")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 48)
                                .background(Color(hex: "#E70104"))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                
                // Meditation guides
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        
                        Text("Meditation Guides")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    ForEach(MeditationGuide.guides, id: \.title) { guide in
                        MeditationGuideCard(guide: guide)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
    
    private func startMeditation() {
        isPlaying = true
        timeRemaining = selectedDuration * 60
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopMeditation()
            }
        }
    }
    
    private func pauseMeditation() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopMeditation() {
        isPlaying = false
        timeRemaining = 0
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct JournalView: View {
    @Binding var entries: [JournalEntry]
    @Binding var showingEntry: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if entries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#E70104").opacity(0.6))
                        
                        Text("No journal entries yet")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Start journaling to track your thoughts and feelings")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showingEntry = true }) {
                            Text("Write Entry")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 44)
                                .background(Color(hex: "#E70104"))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 60)
                } else {
                    ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                        JournalEntryCard(entry: entry)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}

// Supporting models and views
struct JournalEntry: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var mood: Mood
    var date: Date
    
    enum Mood: String, CaseIterable, Codable {
        case happy = "😊"
        case sad = "😢"
        case excited = "🤩"
        case calm = "😌"
        case anxious = "😰"
        case grateful = "🙏"
        case angry = "😠"
        case neutral = "😐"
    }
}

struct DailyPrompt {
    let prompt: String
    
    static let prompts = [
        "What are three things you're grateful for today?",
        "Describe a moment today when you felt truly present.",
        "What challenge did you overcome recently, and how did it make you grow?",
        "Write about someone who made a positive impact on your day.",
        "What's one thing you learned about yourself this week?",
        "Describe your ideal peaceful moment.",
        "What would you tell your younger self?",
        "What small act of kindness could you do tomorrow?",
        "How do you want to feel at the end of this week?",
        "What's something you're looking forward to?"
    ]
    
    static func randomPrompt() -> DailyPrompt {
        let prompt = prompts.randomElement() ?? prompts[0]
        return DailyPrompt(prompt: prompt)
    }
}

struct MindfulnessTip {
    let title: String
    let description: String
    let icon: String
    
    static let tips = [
        MindfulnessTip(title: "Deep Breathing", description: "Take 5 deep breaths, focusing on the sensation of air entering and leaving your body.", icon: "wind"),
        MindfulnessTip(title: "Body Scan", description: "Notice any tension in your body from head to toe, and consciously relax each area.", icon: "figure.stand"),
        MindfulnessTip(title: "Present Moment", description: "Focus on what you can see, hear, smell, taste, or touch right now.", icon: "eye"),
        MindfulnessTip(title: "Gratitude Practice", description: "Think of three things you're grateful for, no matter how small.", icon: "heart.fill")
    ]
}

struct MeditationGuide {
    let title: String
    let description: String
    let duration: String
    let icon: String
    
    static let guides = [
        MeditationGuide(title: "Breathing Focus", description: "Simple breath awareness meditation for beginners", duration: "5-10 min", icon: "lungs.fill"),
        MeditationGuide(title: "Body Relaxation", description: "Progressive muscle relaxation to release tension", duration: "10-15 min", icon: "figure.stand"),
        MeditationGuide(title: "Loving Kindness", description: "Cultivate compassion for yourself and others", duration: "10-20 min", icon: "heart.fill"),
        MeditationGuide(title: "Mindful Walking", description: "Meditation in motion, perfect for active minds", duration: "5-30 min", icon: "figure.walk")
    ]
}

// Supporting view components
struct MindfulnessTipCard: View {
    let tip: MindfulnessTip
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tip.icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#E70104"))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(tip.description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(hex: "#F0F1F3"))
        .cornerRadius(8)
    }
}

struct MeditationGuideCard: View {
    let guide: MeditationGuide
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: guide.icon)
                .font(.system(size: 20))
                .foregroundColor(.green)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(guide.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(guide.description)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(guide.duration)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(hex: "#F0F1F3"))
        .cornerRadius(8)
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.mood.rawValue)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(entry.date, style: .date)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(entry.content)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(3)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct JournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (JournalEntry) -> Void
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood = JournalEntry.Mood.neutral
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F0F1F3")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Mood selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How are you feeling?")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                                ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                                    Button(action: { selectedMood = mood }) {
                                        Text(mood.rawValue)
                                            .font(.system(size: 32))
                                            .frame(width: 60, height: 60)
                                            .background(selectedMood == mood ? Color(hex: "#E70104").opacity(0.1) : Color.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedMood == mood ? Color(hex: "#E70104") : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("What's on your mind?", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your thoughts")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            TextField("Write your thoughts and feelings...", text: $content)
                                .lineLimit(10)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveEntry()
                }
                .disabled(title.isEmpty || content.isEmpty)
                .foregroundColor(title.isEmpty || content.isEmpty ? .gray : Color(hex: "#E70104"))
            )
        }
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            title: title,
            content: content,
            mood: selectedMood,
            date: Date()
        )
        onSave(entry)
        dismiss()
    }
}

extension DateFormatter {
    static let dayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

#Preview {
    MindfulnessView()
}
