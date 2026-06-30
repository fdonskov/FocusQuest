import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class TimerViewModel {
    private let engine: TimerEngine
    private var modelContext: ModelContext?

    init(focusDuration: TimeInterval = 25 * 60) {
        engine = TimerEngine(duration: focusDuration)
        engine.onFinish = { [weak self] in self?.handleFinish() }
    }

    func attach(_ context: ModelContext) {
        modelContext = context
    }

    var state: TimerState { engine.state }
    var progress: Double { engine.progress }

    var remainingText: String {
        let total = max(0, Int(engine.remaining.rounded(.up)))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    var primaryButtonTitle: String {
        switch engine.state {
        case .idle, .finished: return "Начать"
        case .running: return "Пауза"
        case .paused: return "Продолжить"
        }
    }

    var canReset: Bool { engine.state != .idle }

    func primaryAction() {
        switch engine.state {
        case .idle, .finished:
            engine.start()
            NotificationService.scheduleSessionEnd(after: engine.remaining)
        case .running:
            engine.pause()
            NotificationService.cancelSessionEnd()
        case .paused:
            engine.resume()
            NotificationService.scheduleSessionEnd(after: engine.remaining)
        }
    }

    func reset() {
        engine.stop()
        NotificationService.cancelSessionEnd()
    }

    func refresh() {
        engine.refresh()
    }

    private func handleFinish() {
        NotificationService.cancelSessionEnd()
        guard let modelContext else { return }
        let minutes = Int(engine.duration / 60)
        let xp = LevelSystem.xpForSession(durationMinutes: minutes,
                                          completedWithoutInterruption: !engine.wasInterrupted)
        modelContext.insert(FocusSession(startDate: Date(),
                                         durationMinutes: minutes,
                                         wasCompleted: true,
                                         xpEarned: xp,
                                         sessionType: .focus))
        if let character = try? modelContext.fetch(FetchDescriptor<Character>()).first {
            Progression.award(xp, to: character)
            LocationService.refreshUnlocks(forLevel: character.level, in: modelContext)

            var generator = SystemRandomNumberGenerator()
            if let drop = LootService.makeDrop(using: &generator) {
                let item = InventoryItem(itemID: drop.id, name: drop.name, iconName: drop.iconName,
                                         rarity: drop.rarity, obtainedDate: Date())
                item.owner = character
                modelContext.insert(item)
            }
        }

        let sessions = (try? modelContext.fetch(FetchDescriptor<FocusSession>())) ?? []
        let stats = StatsCalculator.stats(from: sessions)
        AchievementService.refresh(in: modelContext, stats: stats)
    }
}
