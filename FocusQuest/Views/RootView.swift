import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var settings

    init() {
        AppFonts.registerBundledFonts()
        #if canImport(UIKit)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.void)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        let titleColor = UIColor(Theme.textPrimary)
        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: UIFont(name: AppFonts.groteskBold, size: 18) ?? .systemFont(ofSize: 18, weight: .bold),
        ]
        nav.largeTitleTextAttributes = [
            .foregroundColor: titleColor,
            .font: UIFont(name: AppFonts.groteskBold, size: 30) ?? .systemFont(ofSize: 30, weight: .bold),
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        #endif
    }

    var body: some View {
        TabView {
            TimerView()
                .screenEntrance()
                .tabItem { Label(settings.t("tab.timer"), systemImage: "timer") }
            MapView()
                .screenEntrance()
                .tabItem { Label(settings.t("tab.map"), systemImage: "map") }
            InventoryView()
                .screenEntrance()
                .tabItem { Label(settings.t("tab.inv"), systemImage: "bag.fill") }
            AchievementsView()
                .screenEntrance()
                .tabItem { Label(settings.t("tab.ach"), systemImage: "trophy.fill") }
            SettingsView()
                .screenEntrance()
                .tabItem { Label(settings.t("tab.set"), systemImage: "gearshape.fill") }
        }
        .tint(Theme.purple)
        .preferredColorScheme(.dark)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .environment(\.locale, Locale(identifier: settings.language))
        .task {
            GameBootstrap.prepare(modelContext)
            if settings.notifications {
                NotificationService.requestAuthorization()
                NotificationService.scheduleStreakReminder()
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AppSettings())
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
