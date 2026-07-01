#if canImport(ActivityKit)
import ActivityKit
import Foundation

// App-side control of the focus session Live Activity. No-op when unsupported/disabled.
@MainActor
enum LiveActivityController {
    static func start(locationName: String, endDate: Date, status: String) {
        guard #available(iOS 16.2, *) else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        end()
        let attributes = FocusActivityAttributes(locationName: locationName)
        let state = FocusActivityAttributes.ContentState(endDate: endDate, paused: false,
                                                         pausedRemaining: 0, statusLabel: status)
        _ = try? Activity.request(attributes: attributes,
                                  content: .init(state: state, staleDate: endDate))
    }

    static func update(endDate: Date, paused: Bool, pausedRemaining: TimeInterval, status: String) {
        guard #available(iOS 16.2, *) else { return }
        let state = FocusActivityAttributes.ContentState(endDate: endDate, paused: paused,
                                                         pausedRemaining: pausedRemaining, statusLabel: status)
        Task {
            for activity in Activity<FocusActivityAttributes>.activities {
                await activity.update(.init(state: state, staleDate: paused ? nil : endDate))
            }
        }
    }

    static func end() {
        guard #available(iOS 16.2, *) else { return }
        Task {
            for activity in Activity<FocusActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
#endif
