import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(AppSettings.self) private var settings
    @Query private var achievements: [Achievement]
    @Query private var sessions: [FocusSession]

    private var stats: PlayerStats {
        StatsCalculator.stats(from: sessions)
    }

    private var unlockedByID: [String: Bool] {
        Dictionary(achievements.map { ($0.achievementID, $0.isUnlocked) },
                   uniquingKeysWith: { first, _ in first })
    }

    private var unlockedCount: Int {
        AchievementCatalog.all.filter { unlockedByID[$0.id] ?? false }.count
    }

    private var summary: String {
        "\(settings.t("ach.sum")) \(unlockedCount) \(settings.t("ach.of")) \(AchievementCatalog.all.count)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(summary)
                        .font(.ui(15))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.bottom, 2)
                    ForEach(AchievementCatalog.all, id: \.id) { seed in
                        AchievementRow(seed: seed,
                                       isUnlocked: unlockedByID[seed.id] ?? false,
                                       progress: seed.condition.progress(stats: stats),
                                       settings: settings)
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle(settings.t("ach.title"))
        }
    }
}

private struct AchievementRow: View {
    let seed: AchievementSeed
    let isUnlocked: Bool
    let progress: (current: Int, target: Int)
    let settings: AppSettings

    private var fraction: Double {
        if isUnlocked { return 1 }
        return progress.target > 0 ? Double(progress.current) / Double(progress.target) : 0
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            icon
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(settings.t("ach.\(seed.id).title"))
                            .font(.ui(17, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(settings.t("ach.\(seed.id).detail"))
                            .font(.ui(15))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    Spacer(minLength: 8)
                    status
                }
                progressBar
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
        .opacity(isUnlocked ? 1 : 0.9)
    }

    private var icon: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(isUnlocked ? AnyShapeStyle(Theme.mainGradient)
                             : AnyShapeStyle(Color.white.opacity(0.06)))
            .frame(width: 52, height: 52)
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.1)))
            .overlay(
                Image(systemName: isUnlocked ? seed.iconName : "lock.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isUnlocked ? .white : Theme.textMuted)
                    .symbolEffect(.bounce, value: isUnlocked)
            )
            .overlay(alignment: .bottomTrailing) {
                if isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.cyan)
                        .background(Circle().fill(Theme.void))
                        .offset(x: 5, y: 5)
                }
            }
    }

    @ViewBuilder
    private var status: some View {
        if isUnlocked {
            Text(settings.t("ach.earned"))
                .font(.ui(12, weight: .bold))
                .foregroundStyle(Theme.accentText)
        } else {
            Text("\(progress.current) / \(progress.target)")
                .font(.ui(12, weight: .semibold).monospacedDigit())
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(Theme.xpGradient)
                    .frame(width: geo.size.width * fraction)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    AchievementsView()
        .environment(AppSettings())
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
