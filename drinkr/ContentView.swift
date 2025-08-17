//
//  ContentView.swift
//  drinkr
//
//  Created by Sukhman Singh on 8/14/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.black.withAlphaComponent(0.3)
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(3)
            
            MenuView()
                .tabItem {
                    Label("Menu", systemImage: "line.3.horizontal")
                }
                .tag(4)
        }
        .accentColor(.cyan)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
