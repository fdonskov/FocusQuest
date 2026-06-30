//
//  ContentView.swift
//  FocusQuest
//
//  Created by Fedor Donskov on 30.06.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
