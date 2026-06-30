import Testing
@testable import FocusQuest

struct ProgressionTests {
    @Test func xpToNextLevelFollowsFormula() {
        #expect(LevelSystem.xpToNextLevel(for: 1) == 100)
        #expect(LevelSystem.xpToNextLevel(for: 2) == 246)
    }

    @Test func sessionXPBaseAndBonus() {
        #expect(LevelSystem.xpForSession(durationMinutes: 25, completedWithoutInterruption: false) == 50)
        #expect(LevelSystem.xpForSession(durationMinutes: 25, completedWithoutInterruption: true) == 60)
    }

    @Test func awardLevelsUpAndCarriesRemainder() {
        let hero = Character(name: "Test", level: 1, currentXP: 0, xpToNextLevel: 100)
        Progression.award(120, to: hero)
        #expect(hero.level == 2)
        #expect(hero.currentXP == 20)
        #expect(hero.xpToNextLevel == 246)
    }

    @Test func awardCascadesMultipleLevels() {
        let hero = Character(name: "Test", level: 1, currentXP: 0, xpToNextLevel: 100)
        Progression.award(1000, to: hero)
        #expect(hero.level >= 3)
        #expect(hero.currentXP < hero.xpToNextLevel)
    }
}
