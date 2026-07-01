// Live Activity UI for the focus session.
//
// This file belongs to the WIDGET EXTENSION target, not the app.
// Setup (Xcode):
//   1. File > New > Target… > Widget Extension, name e.g. "FocusQuestWidget",
//      check "Include Live Activity". Embed in the FocusQuest app.
//   2. Add this file and FocusActivityAttributes.swift to the widget target.
//      For FocusActivityAttributes.swift also keep the app target checked
//      (Target Membership: both FocusQuest and the widget).
//   3. In the FocusQuest app target Info, add: Supports Live Activities (NSSupportsLiveActivities) = YES.
//   4. Add `FocusQuestLiveActivity()` to the generated `@main` WidgetBundle.

#if canImport(ActivityKit)
import ActivityKit
import WidgetKit
import SwiftUI

private let accent = Color(red: 0.61, green: 0.42, blue: 1.0)      // #9B6BFF
private let cyan = Color(red: 0.27, green: 0.90, blue: 1.0)        // #46E6FF
private let voidColor = Color(red: 0.03, green: 0.02, blue: 0.06)  // #08060F

private func mmss(_ t: TimeInterval) -> String {
    let s = max(0, Int(t.rounded()))
    return String(format: "%02d:%02d", s / 60, s % 60)
}

@ViewBuilder
private func countdown(_ state: FocusActivityAttributes.ContentState, font: Font) -> some View {
    if state.paused {
        Text(mmss(state.pausedRemaining)).font(font).monospacedDigit()
    } else {
        Text(timerInterval: Date()...state.endDate, countsDown: true)
            .font(font).monospacedDigit()
    }
}

struct FocusQuestLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            HStack(spacing: 14) {
                Image(systemName: "timer")
                    .font(.title2)
                    .foregroundStyle(accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.locationName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(context.state.statusLabel)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                countdown(context.state, font: .system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding()
            .activityBackgroundTint(voidColor)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.locationName, systemImage: "timer")
                        .font(.caption)
                        .foregroundStyle(accent)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    countdown(context.state, font: .system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.statusLabel)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            } compactLeading: {
                Image(systemName: "timer").foregroundStyle(accent)
            } compactTrailing: {
                countdown(context.state, font: .caption2)
                    .foregroundStyle(.white)
            } minimal: {
                Image(systemName: "timer").foregroundStyle(accent)
            }
            .keylineTint(accent)
        }
    }
}
#endif
