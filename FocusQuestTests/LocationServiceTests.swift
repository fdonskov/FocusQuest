import Testing
import SwiftData
@testable import FocusQuest

@MainActor
struct LocationServiceTests {
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
        LocationService.ensureSeeded(in: context)
        LocationService.ensureSeeded(in: context)
        let locations = try context.fetch(FetchDescriptor<Location>())
        #expect(locations.count == LocationCatalog.all.count)
    }

    @Test func onlyLevelOneLocationsUnlockedInitially() throws {
        let context = try makeContext()
        LocationService.ensureSeeded(in: context)
        let unlocked = try context.fetch(FetchDescriptor<Location>()).filter { $0.isUnlocked }
        let expected = LocationCatalog.all.filter { $0.requiredLevel <= 1 }.count
        #expect(unlocked.count == expected)
    }

    @Test func unlocksUpToGivenLevel() throws {
        let context = try makeContext()
        LocationService.ensureSeeded(in: context)
        LocationService.refreshUnlocks(forLevel: 6, in: context)
        let unlocked = try context.fetch(FetchDescriptor<Location>()).filter { $0.isUnlocked }
        let expected = LocationCatalog.all.filter { $0.requiredLevel <= 6 }.count
        #expect(unlocked.count == expected)
    }
}
