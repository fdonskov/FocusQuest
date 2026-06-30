import Foundation
import Observation

enum TimerState {
    case idle
    case running
    case paused
    case finished
}

@MainActor
@Observable
final class TimerEngine {
    private(set) var state: TimerState = .idle
    private(set) var remaining: TimeInterval

    // True if the run was paused at least once; used to decide the no-interruption bonus.
    private(set) var wasInterrupted = false

    var duration: TimeInterval {
        didSet {
            guard state == .idle else { return }
            remaining = duration
        }
    }

    var onFinish: (() -> Void)?

    // Remaining time is derived from this absolute end point, not from accumulated ticks,
    // so the countdown stays correct after the app is suspended or the device sleeps.
    private var endDate: Date?
    private var ticker: Timer?
    private let now: () -> Date

    init(duration: TimeInterval, now: @escaping () -> Date = { Date() }) {
        self.duration = duration
        self.remaining = duration
        self.now = now
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, (duration - remaining) / duration))
    }

    func start() {
        guard state == .idle || state == .finished else { return }
        remaining = duration
        wasInterrupted = false
        endDate = now().addingTimeInterval(duration)
        state = .running
        startTicker()
    }

    func pause() {
        guard state == .running else { return }
        wasInterrupted = true
        remaining = remainingFromEndDate()
        endDate = nil
        state = .paused
        stopTicker()
    }

    func resume() {
        guard state == .paused else { return }
        endDate = now().addingTimeInterval(remaining)
        state = .running
        startTicker()
    }

    func stop() {
        endDate = nil
        remaining = duration
        state = .idle
        stopTicker()
    }

    // Call when returning to the foreground; the ticker does not fire while suspended.
    func refresh() {
        guard state == .running else { return }
        tick()
    }

    private func remainingFromEndDate() -> TimeInterval {
        guard let endDate else { return remaining }
        return max(0, endDate.timeIntervalSince(now()))
    }

    private func tick() {
        remaining = remainingFromEndDate()
        if remaining <= 0 {
            finish()
        }
    }

    private func finish() {
        remaining = 0
        endDate = nil
        state = .finished
        stopTicker()
        onFinish?()
    }

    private func startTicker() {
        stopTicker()
        let timer = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in self.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }
}
