import Foundation

struct ItemSeed {
    let id: String
    let name: String
    let iconName: String
    let rarity: Rarity
}

enum ItemCatalog {
    static let all: [ItemSeed] = [
        ItemSeed(id: "copper_coin", name: "Медная монета", iconName: "circle.fill", rarity: .common),
        ItemSeed(id: "cloth_robe", name: "Тряпичная мантия", iconName: "tshirt.fill", rarity: .common),
        ItemSeed(id: "minor_potion", name: "Малое зелье", iconName: "drop.fill", rarity: .common),
        ItemSeed(id: "silver_dagger", name: "Серебряный кинжал", iconName: "bolt.fill", rarity: .rare),
        ItemSeed(id: "oak_shield", name: "Дубовый щит", iconName: "shield.fill", rarity: .rare),
        ItemSeed(id: "swift_boots", name: "Сапоги скорости", iconName: "hare.fill", rarity: .rare),
        ItemSeed(id: "flame_staff", name: "Посох пламени", iconName: "flame.fill", rarity: .epic),
        ItemSeed(id: "storm_blade", name: "Клинок бури", iconName: "bolt.horizontal.fill", rarity: .epic),
        ItemSeed(id: "guardian_amulet", name: "Амулет стража", iconName: "seal.fill", rarity: .epic),
        ItemSeed(id: "crown_of_focus", name: "Корона фокуса", iconName: "crown.fill", rarity: .legendary),
        ItemSeed(id: "void_relic", name: "Реликвия Бездны", iconName: "sparkles", rarity: .legendary),
    ]

    static func items(of rarity: Rarity) -> [ItemSeed] {
        all.filter { $0.rarity == rarity }
    }
}
