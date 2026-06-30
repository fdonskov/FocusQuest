import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            TimerView()
                .tabItem { Label("Таймер", systemImage: "timer") }
            MapView()
                .tabItem { Label("Карта", systemImage: "map") }
            InventoryView()
                .tabItem { Label("Инвентарь", systemImage: "bag.fill") }
            AchievementsView()
                .tabItem { Label("Достижения", systemImage: "trophy.fill") }
        }
        .task {
            GameBootstrap.prepare(modelContext)
            NotificationService.requestAuthorization()
            NotificationService.scheduleStreakReminder()
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
