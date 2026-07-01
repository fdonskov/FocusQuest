import Foundation

struct SessionReward: Identifiable {
    let id = UUID()
    let xpEarned: Int
    let leveledUp: Bool
    let newLevel: Int
    let unlockedLocationID: String?
    let drop: DropInfo?

    struct DropInfo {
        let itemID: String
        let iconName: String
        let rarity: Rarity
    }
}
