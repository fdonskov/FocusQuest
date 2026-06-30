import Foundation

struct PlayerStats {
    let completedSessions: Int
    let totalFocusMinutes: Int
    let streakDays: Int
}

enum StatsCalculator {
    static func stats(from sessions: [FocusSession],
                      calendar: Calendar = .current,
                      now: Date = Date()) -> PlayerStats {
        let completed = sessions.filter { $0.wasCompleted }
        let totalMinutes = completed.reduce(0) { $0 + $1.durationMinutes }
        return PlayerStats(completedSessions: completed.count,
                           totalFocusMinutes: totalMinutes,
                           streakDays: streakDays(from: completed, calendar: calendar, now: now))
    }

    // Consecutive days with at least one completed session, ending today or yesterday.
    static func streakDays(from completed: [FocusSession], calendar: Calendar, now: Date) -> Int {
        guard !completed.isEmpty else { return 0 }
        let days = Set(completed.map { calendar.startOfDay(for: $0.startDate) })
        var day = calendar.startOfDay(for: now)
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
                  days.contains(yesterday) else { return 0 }
            day = yesterday
        }
        var streak = 0
        while days.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}
