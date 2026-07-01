import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(AppSettings.self) private var settings
    @Query private var sessions: [FocusSession]

    private var stats: PlayerStats { StatsCalculator.stats(from: sessions) }

    private var week: [DayBar] {
        StatsCalculator.dailyFocusMinutes(from: sessions).map {
            DayBar(date: $0.date, label: weekdayLabel($0.date), minutes: $0.minutes)
        }
    }

    private var hasData: Bool { stats.completedSessions > 0 }

    var body: some View {
        ScrollView {
            if hasData {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        StatCard(value: focusTimeText(stats.totalFocusMinutes),
                                 label: settings.t("stats.totalFocus"))
                        StatCard(value: "\(stats.completedSessions)",
                                 label: settings.t("stats.sessions"))
                        StatCard(value: "\(stats.streakDays)",
                                 label: settings.t("stats.streak"))
                    }
                    weekChart
                }
                .padding(20)
            } else {
                ContentUnavailableView(settings.t("stats.title"),
                                       systemImage: "chart.bar",
                                       description: Text(settings.t("stats.empty")))
                    .frame(maxWidth: .infinity, minHeight: 400)
            }
        }
        .screenBackground()
        .navigationTitle(settings.t("stats.title"))
    }

    private var weekChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(settings.t("stats.week").uppercased())
                .font(.ui(11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Theme.textMuted)
            Chart(week) { day in
                BarMark(x: .value("day", day.label),
                        y: .value("min", day.minutes),
                        width: .ratio(0.55))
                    .foregroundStyle(Theme.xpGradient)
                    .cornerRadius(6)
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.08))
                    AxisValueLabel().foregroundStyle(Theme.textMuted)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel().foregroundStyle(Theme.textSecondary)
                }
            }
            .frame(height: 190)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: 20)
    }

    private func focusTimeText(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        if h > 0 { return "\(h)\(settings.t("unit.hourShort")) \(m)\(settings.t("unit.minShort"))" }
        return "\(m)\(settings.t("unit.minShort"))"
    }

    private func weekdayLabel(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: settings.language)
        f.setLocalizedDateFormatFromTemplate("EEE")
        return f.string(from: date)
    }
}

private struct DayBar: Identifiable {
    let date: Date
    let label: String
    let minutes: Int
    var id: Date { date }
}

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.display(22))
                .foregroundStyle(Theme.textPrimary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label.uppercased())
                .font(.ui(10, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(Theme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .glassCard(cornerRadius: 18)
    }
}

#Preview {
    NavigationStack {
        StatsView()
            .environment(AppSettings())
            .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                                  Achievement.self, Location.self], inMemory: true)
    }
}
