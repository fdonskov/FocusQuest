import Foundation

enum LootService {
    // Drop weights: 70% common, 20% rare, 8% epic, 2% legendary over a 0..<100 roll.
    static func rarity(forRoll roll: Int) -> Rarity {
        switch roll {
        case ..<70: return .common
        case ..<90: return .rare
        case ..<98: return .epic
        default: return .legendary
        }
    }

    static func rollRarity<G: RandomNumberGenerator>(using generator: inout G) -> Rarity {
        rarity(forRoll: Int.random(in: 0..<100, using: &generator))
    }

    static func makeDrop<G: RandomNumberGenerator>(using generator: inout G) -> ItemSeed? {
        let rarity = rollRarity(using: &generator)
        return ItemCatalog.items(of: rarity).randomElement(using: &generator)
    }
}
