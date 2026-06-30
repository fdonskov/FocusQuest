import Foundation

enum Progression {
    static func award(_ xp: Int, to character: Character) {
        guard xp > 0 else { return }
        character.currentXP += xp
        while character.xpToNextLevel > 0, character.currentXP >= character.xpToNextLevel {
            character.currentXP -= character.xpToNextLevel
            character.level += 1
            character.xpToNextLevel = LevelSystem.xpToNextLevel(for: character.level)
        }
    }
}
