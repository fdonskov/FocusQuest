import Testing
import SwiftData
@testable import FocusQuest

@MainActor
struct AchievementServiceTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Character.self, FocusSession.self, InventoryItem.self, Achievement.self, Location.self,
            configurations: config
        )
        return ModelContext(container)
    }

    @Test func seedsFullCatalogAndIsIdempotent() throws {
        let context = try makeContext()
        AchievementService.ensureSeeded(in: context, for: nil)
        AchievementService.ensureSeeded(in: context, for: nil)
        let records = try context.fetch(FetchDescriptor<Achievement>())
        #expect(records.count == AchievementCatalog.all.count)
    }

    @Test func unlocksSatisfiedAchievementsOnly() throws {
        let context = try makeContext()
        AchievementService.ensureSeeded(in: context, for: nil)
        let stats = PlayerStats(completedSessions: 1, totalFocusMinutes: 0, streakDays: 0)
        AchievementService.refresh(in: context, stats: stats)

        let records = try context.fetch(FetchDescriptor<Achievement>())
        let byID = Dictionary(records.map { ($0.achievementID, $0) }, uniquingKeysWith: { first, _ in first })
        #expect(byID["first_session"]?.isUnlocked == true)
        #expect(byID["ten_sessions"]?.isUnlocked == false)
    }
}
