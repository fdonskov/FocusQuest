import Foundation
import SwiftData

enum AchievementService {
    static func ensureSeeded(in context: ModelContext, for owner: Character?) {
        let existing = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        let existingIDs = Set(existing.map(\.achievementID))
        for seed in AchievementCatalog.all where !existingIDs.contains(seed.id) {
            let achievement = Achievement(achievementID: seed.id, title: seed.title,
                                          isUnlocked: false, unlockedDate: nil)
            achievement.owner = owner
            context.insert(achievement)
        }
    }

    static func refresh(in context: ModelContext, stats: PlayerStats, now: Date = Date()) {
        let records = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        let byID = Dictionary(records.map { ($0.achievementID, $0) }, uniquingKeysWith: { first, _ in first })
        for seed in AchievementCatalog.all {
            guard let record = byID[seed.id], !record.isUnlocked else { continue }
            if seed.condition.isSatisfied(stats: stats) {
                record.isUnlocked = true
                record.unlockedDate = now
            }
        }
    }
}
