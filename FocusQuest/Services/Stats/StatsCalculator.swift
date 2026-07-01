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

    // Completed focus minutes per day for the last `days` days, oldest first (includes empty days).
    static func dailyFocusMinutes(from sessions: [FocusSession], days: Int = 7,
                                  calendar: Calendar = .current,
                                  now: Date = Date()) -> [(date: Date, minutes: Int)] {
        let completed = sessions.filter { $0.wasCompleted }
        let today = calendar.startOfDay(for: now)
        var result: [(date: Date, minutes: Int)] = []
        for offset in stride(from: days - 1, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let minutes = completed
                .filter { calendar.isDate($0.startDate, inSameDayAs: day) }
                .reduce(0) { $0 + $1.durationMinutes }
            result.append((date: day, minutes: minutes))
        }
        return result
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
