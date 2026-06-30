import Foundation
import SwiftData

@Model
final class Achievement {
    var achievementID: String = ""
    var title: String = ""
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var owner: Character?

    init(achievementID: String = "",
         title: String = "",
         isUnlocked: Bool = false,
         unlockedDate: Date? = nil) {
        self.achievementID = achievementID
        self.title = title
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}
