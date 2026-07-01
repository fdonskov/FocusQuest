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

    @Test func dailyFocusMinutesBucketsByDayIncludingEmptyDays() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let sessions = [
            FocusSession(startDate: day(0, from: now), durationMinutes: 25, wasCompleted: true),
            FocusSession(startDate: day(0, from: now), durationMinutes: 15, wasCompleted: true),
            FocusSession(startDate: day(-2, from: now), durationMinutes: 50, wasCompleted: true),
            FocusSession(startDate: day(0, from: now), durationMinutes: 25, wasCompleted: false),
        ]
        let week = StatsCalculator.dailyFocusMinutes(from: sessions, days: 7, calendar: calendar, now: now)
        #expect(week.count == 7)
        #expect(week.last?.minutes == 40)   // today: 25 + 15, incomplete ignored
        #expect(week[4].minutes == 50)      // two days ago (index 6 - 2)
        #expect(week.first?.minutes == 0)   // six days ago, empty
    }

    @Test func dailyFocusMinutesIsOldestFirst() {
        let now = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let week = StatsCalculator.dailyFocusMinutes(from: [], days: 7, calendar: calendar, now: now)
        #expect(week.count == 7)
        #expect(week.allSatisfy { $0.minutes == 0 })
        for i in 1..<week.count {
            #expect(week[i - 1].date < week[i].date)
        }
    }
}
