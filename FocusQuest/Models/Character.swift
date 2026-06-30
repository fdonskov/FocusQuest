import Foundation
import SwiftData

@Model
final class Character {
    var name: String = ""
    var level: Int = 1
    var currentXP: Int = 0
    var xpToNextLevel: Int = 100
    var currentLocationID: String = ""

    // Relationships are optional and properties carry defaults to stay CloudKit-compatible.
    @Relationship(deleteRule: .cascade, inverse: \InventoryItem.owner)
    var inventory: [InventoryItem]? = []

    @Relationship(deleteRule: .cascade, inverse: \Achievement.owner)
    var achievements: [Achievement]? = []

    init(name: String = "",
         level: Int = 1,
         currentXP: Int = 0,
         xpToNextLevel: Int = 100,
         currentLocationID: String = "") {
        self.name = name
        self.level = level
        self.currentXP = currentXP
        self.xpToNextLevel = xpToNextLevel
        self.currentLocationID = currentLocationID
    }
}
