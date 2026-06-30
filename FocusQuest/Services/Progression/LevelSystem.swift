import Foundation

enum LevelSystem {
    // xpToNextLevel = 100 * level^1.3
    static func xpToNextLevel(for level: Int) -> Int {
        Int((100.0 * pow(Double(max(1, level)), 1.3)).rounded())
    }

    // Two XP per focus minute; an uninterrupted session adds a 20% bonus.
    static func xpForSession(durationMinutes: Int, completedWithoutInterruption: Bool) -> Int {
        let base = max(0, durationMinutes) * 2
        guard completedWithoutInterruption else { return base }
        return Int((Double(base) * 1.2).rounded())
    }
}
