import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Query private var achievements: [Achievement]
    @Query private var sessions: [FocusSession]

    private var stats: PlayerStats {
        StatsCalculator.stats(from: sessions)
    }

    private var unlockedByID: [String: Bool] {
        Dictionary(achievements.map { ($0.achievementID, $0.isUnlocked) },
                   uniquingKeysWith: { first, _ in first })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(AchievementCatalog.all, id: \.id) { seed in
                        AchievementRow(seed: seed,
                                       isUnlocked: unlockedByID[seed.id] ?? false,
                                       progress: seed.condition.progress(stats: stats))
                    }
                }
                .padding()
            }
            .navigationTitle("Достижения")
        }
    }
}

private struct AchievementRow: View {
    let seed: AchievementSeed
    let isUnlocked: Bool
    let progress: (current: Int, target: Int)

    private var fraction: Double {
        progress.target > 0 ? Double(progress.current) / Double(progress.target) : 0
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: isUnlocked ? seed.iconName : "lock.fill")
                .font(.title2)
                .frame(width: 40)
                .foregroundStyle(isUnlocked ? Color.accentColor : .secondary)
            VStack(alignment: .leading, spacing: 6) {
                Text(seed.title)
                    .font(.headline)
                Text(seed.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !isUnlocked {
                    ProgressView(value: min(1, fraction))
                        .tint(Color.accentColor)
                    Text("\(progress.current) / \(progress.target)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .opacity(isUnlocked ? 1 : 0.85)
    }
}

#Preview {
    AchievementsView()
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
