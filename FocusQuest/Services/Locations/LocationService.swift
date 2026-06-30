import Foundation
import SwiftData

enum LocationService {
    static func ensureSeeded(in context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Location>())) ?? []
        let existingIDs = Set(existing.map(\.locationID))
        for seed in LocationCatalog.all where !existingIDs.contains(seed.id) {
            context.insert(Location(locationID: seed.id,
                                    name: seed.name,
                                    requiredLevel: seed.requiredLevel,
                                    isUnlocked: seed.requiredLevel <= 1))
        }
    }

    static func refreshUnlocks(forLevel level: Int, in context: ModelContext) {
        let locations = (try? context.fetch(FetchDescriptor<Location>())) ?? []
        for location in locations where !location.isUnlocked && location.requiredLevel <= level {
            location.isUnlocked = true
        }
    }
}
