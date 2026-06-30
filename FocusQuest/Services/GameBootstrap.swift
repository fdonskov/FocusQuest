import Foundation
import SwiftData

enum GameBootstrap {
    static func prepare(_ context: ModelContext) {
        ensureCharacter(in: context)
        LocationService.ensureSeeded(in: context)
        let character = try? context.fetch(FetchDescriptor<Character>()).first
        AchievementService.ensureSeeded(in: context, for: character)
    }

    private static func ensureCharacter(in context: ModelContext) {
        let existing = (try? context.fetch(FetchDescriptor<Character>())) ?? []
        guard existing.isEmpty else { return }
        context.insert(Character(name: "Герой", level: 1, currentXP: 0, xpToNextLevel: 100))
    }
}
