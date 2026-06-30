import Testing
@testable import FocusQuest

struct LootServiceTests {
    @Test func rarityRollBoundaries() {
        #expect(LootService.rarity(forRoll: 0) == .common)
        #expect(LootService.rarity(forRoll: 69) == .common)
        #expect(LootService.rarity(forRoll: 70) == .rare)
        #expect(LootService.rarity(forRoll: 89) == .rare)
        #expect(LootService.rarity(forRoll: 90) == .epic)
        #expect(LootService.rarity(forRoll: 97) == .epic)
        #expect(LootService.rarity(forRoll: 98) == .legendary)
        #expect(LootService.rarity(forRoll: 99) == .legendary)
    }

    @Test func catalogHasItemsForEveryRarity() {
        for rarity in Rarity.allCases {
            #expect(!ItemCatalog.items(of: rarity).isEmpty)
        }
    }
}
