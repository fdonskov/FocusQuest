import Foundation
import SwiftData

@Model
final class InventoryItem {
    var itemID: String = ""
    var name: String = ""
    var iconName: String = ""
    var rarity: Rarity = Rarity.common
    var obtainedDate: Date = Date()
    var owner: Character?

    init(itemID: String = "",
         name: String = "",
         iconName: String = "",
         rarity: Rarity = .common,
         obtainedDate: Date = Date()) {
        self.itemID = itemID
        self.name = name
        self.iconName = iconName
        self.rarity = rarity
        self.obtainedDate = obtainedDate
    }
}
