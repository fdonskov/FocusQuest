import Testing
import Foundation
@testable import FocusQuest

@MainActor
struct TimerEngineTests {
    final class Clock {
        var date: Date
        init(_ date: Date) { self.date = date }
    }

    private func makeEngine(duration: TimeInterval, clock: Clock) -> TimerEngine {
        TimerEngine(duration: duration, now: { clock.date })
    }

    @Test func startsIdleWithFullDuration() {
        let engine = TimerEngine(duration: 300)
        #expect(engine.state == .idle)
        #expect(engine.remaining == 300)
    }

    @Test func countsDownFromAbsoluteEnd() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let engine = makeEngine(duration: 60, clock: clock)
        engine.start()
        #expect(engine.state == .running)
        clock.date.addTimeInterval(25)
        engine.refresh()
        #expect(engine.remaining == 35)
    }

    @Test func pauseFreezesRemaining() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let engine = makeEngine(duration: 60, clock: clock)
        engine.start()
        clock.date.addTimeInterval(20)
        engine.pause()
        #expect(engine.state == .paused)
        clock.date.addTimeInterval(100)
        #expect(engine.remaining == 40)
    }

    @Test func resumeContinuesFromFrozenRemaining() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let engine = makeEngine(duration: 60, clock: clock)
        engine.start()
        clock.date.addTimeInterval(20)
        engine.pause()
        clock.date.addTimeInterval(100)
        engine.resume()
        clock.date.addTimeInterval(10)
        engine.refresh()
        #expect(engine.remaining == 30)
    }

    @Test func finishesWhenElapsedPastDuration() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let engine = makeEngine(duration: 60, clock: clock)
        var finished = false
        engine.onFinish = { finished = true }
        engine.start()
        clock.date.addTimeInterval(61)
        engine.refresh()
        #expect(engine.state == .finished)
        #expect(engine.remaining == 0)
        #expect(finished)
    }

    @Test func stopResetsToIdle() {
        let engine = TimerEngine(duration: 120)
        engine.start()
        engine.stop()
        #expect(engine.state == .idle)
        #expect(engine.remaining == 120)
    }
}
