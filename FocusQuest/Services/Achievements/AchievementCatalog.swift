import Foundation

enum AchievementCondition {
    case sessionsCompleted(Int)
    case focusHours(Int)
    case streakDays(Int)

    var target: Int {
        switch self {
        case .sessionsCompleted(let n), .focusHours(let n), .streakDays(let n):
            return n
        }
    }

    func current(stats: PlayerStats) -> Int {
        switch self {
        case .sessionsCompleted: return stats.completedSessions
        case .focusHours: return stats.totalFocusMinutes / 60
        case .streakDays: return stats.streakDays
        }
    }

    func progress(stats: PlayerStats) -> (current: Int, target: Int) {
        (min(current(stats: stats), target), target)
    }

    func isSatisfied(stats: PlayerStats) -> Bool {
        current(stats: stats) >= target
    }
}

struct AchievementSeed {
    let id: String
    let title: String
    let detail: String
    let iconName: String
    let condition: AchievementCondition
}

enum AchievementCatalog {
    static let all: [AchievementSeed] = [
        AchievementSeed(id: "first_session", title: "Первый шаг", detail: "Завершите первую сессию",
                        iconName: "flag.fill", condition: .sessionsCompleted(1)),
        AchievementSeed(id: "ten_sessions", title: "Постоянство", detail: "Завершите 10 сессий",
                        iconName: "checkmark.seal.fill", condition: .sessionsCompleted(10)),
        AchievementSeed(id: "fifty_sessions", title: "Марафонец", detail: "Завершите 50 сессий",
                        iconName: "rosette", condition: .sessionsCompleted(50)),
        AchievementSeed(id: "focus_one_hour", title: "Час фокуса", detail: "Наберите 1 час концентрации",
                        iconName: "hourglass", condition: .focusHours(1)),
        AchievementSeed(id: "focus_ten_hours", title: "Глубокая работа", detail: "Наберите 10 часов концентрации",
                        iconName: "clock.badge.checkmark", condition: .focusHours(10)),
        AchievementSeed(id: "streak_3", title: "Три дня подряд", detail: "Занимайтесь 3 дня подряд",
                        iconName: "flame.fill", condition: .streakDays(3)),
        AchievementSeed(id: "streak_7", title: "Неделя силы", detail: "Занимайтесь 7 дней подряд",
                        iconName: "calendar.badge.checkmark", condition: .streakDays(7)),
    ]
}
