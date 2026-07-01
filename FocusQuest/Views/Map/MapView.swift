import SwiftUI
import SwiftData

struct MapView: View {
    @Environment(AppSettings.self) private var settings
    @Query(sort: \Location.requiredLevel) private var locations: [Location]
    @Query private var characters: [Character]

    private var character: Character? { characters.first }
    private var currentID: String { character?.currentLocationID ?? "meadow" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(settings.t("map.sub"))
                        .font(.ui(15))
                        .foregroundStyle(Theme.textSecondary)
                    ForEach(locations) { location in
                        LocationCard(location: location,
                                     isCurrent: location.locationID == currentID,
                                     settings: settings) {
                            character?.currentLocationID = location.locationID
                            Haptics.impact()
                        }
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle(settings.t("map.title"))
        }
    }
}

private struct LocationCard: View {
    let location: Location
    let isCurrent: Bool
    let settings: AppSettings
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    private var reduceMotion: Bool { settings.reduceMotion || systemReduceMotion }

    private var seed: LocationSeed { LocationCatalog.seed(for: location.locationID) }
    private var tint: Color { Color(hue: seed.hue / 360, saturation: 0.55, brightness: 0.9) }

    var body: some View {
        ZStack {
            background
            if location.isUnlocked && !reduceMotion {
                LocationAmbianceView(locationID: location.locationID)
            }
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(settings.t(LocationCatalog.localizationKey(for: location.locationID)))
                            .font(.display(20))
                            .foregroundStyle(Theme.textPrimary)
                        if isCurrent {
                            Text(settings.t("map.here").uppercased())
                                .font(.ui(11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Theme.purpleDeep, in: Capsule())
                        }
                    }
                    statusRow
                }
                Spacer()
                Image(systemName: location.isUnlocked ? seed.iconName : "lock.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(location.isUnlocked ? tint : Theme.textMuted)
            }
            .padding(18)
        }
        .frame(height: 104)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
        .opacity(location.isUnlocked ? 1 : 0.85)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture { if location.isUnlocked { onTap() } }
    }

    @ViewBuilder
    private var background: some View {
        if location.isUnlocked {
            Image(LocationCatalog.sceneName(for: location.locationID))
                .resizable()
                .scaledToFill()
                .overlay(
                    LinearGradient(colors: [Theme.void.opacity(0.92), Theme.void.opacity(0.25)],
                                   startPoint: .leading, endPoint: .trailing)
                )
        } else {
            LinearGradient(colors: [Color(hex: 0x141021), Color(hex: 0x0C0A16)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var statusRow: some View {
        HStack(spacing: 6) {
            Image(systemName: statusIcon).font(.caption)
            Text(statusText).font(.ui(15, weight: .semibold))
        }
        .foregroundStyle(statusColor)
    }

    private var statusIcon: String {
        if isCurrent { return "mappin.circle.fill" }
        return location.isUnlocked ? "checkmark.seal.fill" : "lock.fill"
    }

    private var statusText: String {
        if isCurrent { return settings.t("map.current") }
        if location.isUnlocked { return settings.t("map.open") }
        return "\(settings.t("map.need")) \(location.requiredLevel)"
    }

    private var statusColor: Color {
        if isCurrent { return Theme.purple }
        return location.isUnlocked ? Theme.cyan : Theme.textMuted
    }
}

#Preview {
    MapView()
        .environment(AppSettings())
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
