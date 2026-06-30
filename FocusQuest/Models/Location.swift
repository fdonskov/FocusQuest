import Foundation
import SwiftData

@Model
final class Location {
    var locationID: String = ""
    var name: String = ""
    var requiredLevel: Int = 0
    var isUnlocked: Bool = false

    init(locationID: String = "",
         name: String = "",
         requiredLevel: Int = 0,
         isUnlocked: Bool = false) {
        self.locationID = locationID
        self.name = name
        self.requiredLevel = requiredLevel
        self.isUnlocked = isUnlocked
    }
}
