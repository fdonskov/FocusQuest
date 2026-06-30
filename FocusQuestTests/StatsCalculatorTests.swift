import Testing
import Foundation
@testable import FocusQuest

struct StatsCalculatorTests {
    private let calendar = Calendar(identifier: .gregorian)

    private func day(_ offset: Int, from base: Date) -> Date {
        calendar.date(byAdding: .day, value: offset, to: base)!
    }

    @Test func countsCompletedSessionsAndMinutes() {
        let base = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let sessions = [
            FocusSession(startDate: base, durationMinutes: 25, wasCompleted: true),
            FocusSession(startDate: base, durationMinutes: 25, wasCompleted: true),
            FocusSession(startDate: base, durationMinutes: 25, wasCompleted: false),
        ]
        let stats = StatsCalculator.stats(from: sessions, calendar: calendar, now: base)
        #expect(stats.completedSessions == 2)
        #expect(stats.totalFocusMinutes == 50)
    }

    @Test func streakCountsConsecutiveDaysWithGap() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let sessions = [
            FocusSession(startDate: day(0, from: now), durationMinutes: 25, wasCompleted: true),
            FocusSession(startDate: day(-1, from: now), durationMinutes: 25, wasCompleted: true),
            FocusSession(startDate: day(-2, from: now), durationMinutes: 25, wasCompleted: true),
            FocusSession(startDate: day(-4, from: now), durationMinutes: 25, wasCompleted: true),
        ]
        let stats = StatsCalculator.stats(from: sessions, calendar: calendar, now: now)
        #expect(stats.streakDays == 3)
    }

    @Test func streakIsZeroWhenNoRecentSessions() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let sessions = [
            FocusSession(startDate: day(-5, from: now), durationMinutes: 25, wasCompleted: true),
        ]
        let stats = StatsCalculator.stats(from: sessions, calendar: calendar, now: now)
        #expect(stats.streakDays == 0)
    }
}
