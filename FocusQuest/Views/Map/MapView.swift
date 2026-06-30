import SwiftUI
import SwiftData

struct MapView: View {
    @Query(sort: \Location.requiredLevel) private var locations: [Location]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(locations) { location in
                        LocationCard(location: location)
                    }
                }
                .padding()
            }
            .navigationTitle("Карта")
        }
    }
}

private struct LocationCard: View {
    let location: Location

    private var icon: String {
        location.isUnlocked ? LocationCatalog.icon(for: location.locationID) : "lock.fill"
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 44)
                .foregroundStyle(location.isUnlocked ? Color.accentColor : .secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                Text(location.isUnlocked ? "Открыто" : "Откроется на уровне \(location.requiredLevel)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .opacity(location.isUnlocked ? 1 : 0.6)
    }
}

#Preview {
    MapView()
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
