import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class TimerViewModel {
    private let engine: TimerEngine
    private var modelContext: ModelContext?
    private var settings: AppSettings?

    private(set) var lastReward: SessionReward?
    private(set) var selectedMinutes: Int = 25

    let presets = [15, 25, 50]

    init() {
        engine = TimerEngine(duration: 25 * 60)
        engine.onFinish = { [weak self] in self?.handleFinish() }
    }

    func attach(context: ModelContext, settings: AppSettings) {
        self.modelContext = context
        self.settings = settings
        if engine.state == .idle {
            selectedMinutes = settings.defaultPresetMinutes
            engine.duration = duration(for: selectedMinutes)
        }
    }

    var state: TimerState { engine.state }
    var progress: Double { engine.progress }
    var isRunning: Bool { engine.state == .running }
    var canReset: Bool { engine.state != .idle }

    var remainingText: String {
        let total = max(0, Int(engine.remaining.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    func selectPreset(_ minutes: Int) {
        guard engine.state == .idle else { return }
        selectedMinutes = minutes
        engine.duration = duration(for: minutes)
    }

    func primaryAction() {
        Haptics.impact()
        switch engine.state {
        case .idle, .finished:
            engine.duration = duration(for: selectedMinutes)
            engine.start()
            startAmbientAndNotification()
            startLiveActivity()
        case .running:
            engine.pause()
            stopAmbient()
            NotificationService.cancelSessionEnd()
            pauseLiveActivity()
        case .paused:
            engine.resume()
            startAmbientAndNotification()
            startLiveActivity()
        }
    }

    func reset() {
        Haptics.impact()
        engine.stop()
        stopAmbient()
        NotificationService.cancelSessionEnd()
        endLiveActivity()
    }

    // Reacts to the Sound toggle flipping mid-session.
    func syncAmbient() {
        guard isRunning else { return }
        if settings?.sound == true {
            AudioService.shared.start(locationID: currentLocationID, presetMinutes: selectedMinutes)
        } else {
            AudioService.shared.stop()
        }
    }

    func refresh() {
        engine.refresh()
    }

    func clearReward() {
        lastReward = nil
    }

    // Demo mode compresses minutes into seconds so a session finishes quickly for preview.
    private func duration(for minutes: Int) -> TimeInterval {
        (settings?.demoMode ?? false) ? TimeInterval(minutes) : TimeInterval(minutes * 60)
    }

    private func startAmbientAndNotification() {
        NotificationService.scheduleSessionEnd(after: engine.remaining)
        if settings?.sound == true {
            AudioService.shared.start(locationID: currentLocationID, presetMinutes: selectedMinutes)
        }
    }

    private func stopAmbient() {
        AudioService.shared.stop()
    }

    private var currentLocationName: String {
        settings?.t(LocationCatalog.localizationKey(for: currentLocationID)) ?? currentLocationID
    }

    private func startLiveActivity() {
        #if canImport(ActivityKit)
        LiveActivityController.start(locationName: currentLocationName,
                                     endDate: Date().addingTimeInterval(engine.remaining),
                                     status: settings?.t("timer.running") ?? "")
        #endif
    }

    private func pauseLiveActivity() {
        #if canImport(ActivityKit)
        LiveActivityController.update(endDate: Date().addingTimeInterval(engine.remaining),
                                      paused: true, pausedRemaining: engine.remaining,
                                      status: settings?.t("timer.paused") ?? "")
        #endif
    }

    private func endLiveActivity() {
        #if canImport(ActivityKit)
        LiveActivityController.end()
        #endif
    }

    private var currentLocationID: String {
        guard let modelContext,
              let character = try? modelContext.fetch(FetchDescriptor<Character>()).first
        else { return "meadow" }
        return character.currentLocationID.isEmpty ? "meadow" : character.currentLocationID
    }

    private func handleFinish() {
        NotificationService.cancelSessionEnd()
        stopAmbient()
        endLiveActivity()
        guard let modelContext else { return }
        let minutes = selectedMinutes
        let xp = LevelSystem.xpForSession(durationMinutes: minutes,
                                          completedWithoutInterruption: !engine.wasInterrupted)
        modelContext.insert(FocusSession(startDate: Date(), durationMinutes: minutes,
                                         wasCompleted: true, xpEarned: xp, sessionType: .focus))

        var leveledUp = false
        var newLevel = 0
        var dropInfo: SessionReward.DropInfo?
        var unlockedID: String?

        if let character = try? modelContext.fetch(FetchDescriptor<Character>()).first {
            let levelBefore = character.level
            Progression.award(xp, to: character)
            newLevel = character.level
            leveledUp = character.level > levelBefore

            let before = unlockedLocationIDs(in: modelContext)
            LocationService.refreshUnlocks(forLevel: character.level, in: modelContext)
            let after = unlockedLocationIDs(in: modelContext)
            unlockedID = after.subtracting(before).max { lhs, rhs in
                LocationCatalog.seed(for: lhs).requiredLevel < LocationCatalog.seed(for: rhs).requiredLevel
            }

            var generator = SystemRandomNumberGenerator()
            if let drop = LootService.makeDrop(using: &generator) {
                let item = InventoryItem(itemID: drop.id, name: drop.name, iconName: drop.iconName,
                                         rarity: drop.rarity, obtainedDate: Date())
                item.owner = character
                modelContext.insert(item)
                dropInfo = SessionReward.DropInfo(itemID: drop.id, iconName: drop.iconName, rarity: drop.rarity)
            }
        }

        let sessions = (try? modelContext.fetch(FetchDescriptor<FocusSession>())) ?? []
        AchievementService.refresh(in: modelContext, stats: StatsCalculator.stats(from: sessions))

        lastReward = SessionReward(xpEarned: xp, leveledUp: leveledUp, newLevel: newLevel,
                                   unlockedLocationID: unlockedID, drop: dropInfo)
        Haptics.success()

        // Reset back to a fresh idle session (full time, empty ring) as if stop was pressed.
        engine.stop()
    }

    private func unlockedLocationIDs(in context: ModelContext) -> Set<String> {
        let locations = (try? context.fetch(FetchDescriptor<Location>())) ?? []
        return Set(locations.filter { $0.isUnlocked }.map { $0.locationID })
    }
}
