#if canImport(ActivityKit)
import ActivityKit
import Foundation

// Shared between the app and the widget extension.
// Add this file to BOTH the FocusQuest and the widget extension targets (Target Membership).
struct FocusActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        // Absolute end used for a live countdown while running.
        var endDate: Date
        var paused: Bool
        // Frozen remaining seconds, shown while paused (no live countdown).
        var pausedRemaining: TimeInterval
        var statusLabel: String
    }

    var locationName: String
}
#endif
