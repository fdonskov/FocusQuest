import Foundation
import SwiftData

@Model
final class FocusSession {
    var startDate: Date = Date()
    var durationMinutes: Int = 0
    var wasCompleted: Bool = false
    var xpEarned: Int = 0
    var sessionType: SessionType = SessionType.focus

    init(startDate: Date = Date(),
         durationMinutes: Int = 0,
         wasCompleted: Bool = false,
         xpEarned: Int = 0,
         sessionType: SessionType = .focus) {
        self.startDate = startDate
        self.durationMinutes = durationMinutes
        self.wasCompleted = wasCompleted
        self.xpEarned = xpEarned
        self.sessionType = sessionType
    }
}
