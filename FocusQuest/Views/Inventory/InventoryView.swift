import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(AppSettings.self) private var settings
    @Query(sort: \InventoryItem.obtainedDate, order: .reverse) private var items: [InventoryItem]
    @State private var filter: Rarity?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var filtered: [InventoryItem] {
        guard let filter else { return items }
        return items.filter { $0.rarity == filter }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                content
            }
            .screenBackground()
            .navigationTitle(settings.t("inv.title"))
        }
    }

    @ViewBuilder
    private var content: some View {
        if filtered.isEmpty {
            ContentUnavailableView(settings.t(items.isEmpty ? "inv.empty" : "inv.filterEmpty"),
                                   systemImage: items.isEmpty ? "bag" : "line.3.horizontal.decrease.circle",
                                   description: Text(items.isEmpty ? settings.t("inv.emptyHint") : ""))
                .frame(maxHeight: .infinity)
        } else {
            ScrollView {
                Text("\(items.count) \(settings.t("inv.items"))")
                    .font(.ui(12))
                    .foregroundStyle(Theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filtered) { item in
                        ItemCard(item: item, settings: settings)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: settings.t("filter.all"), isSelected: filter == nil) { filter = nil }
                ForEach(Rarity.allCases, id: \.self) { rarity in
                    FilterChip(title: settings.t("filter.\(rarity.rawValue)"),
                               isSelected: filter == rarity) { filter = rarity }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.ui(15, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : Theme.textSecondary)
        }
        .buttonStyle(.plain)
        .glassCard(Capsule(), tint: isSelected ? Theme.purpleDeep : nil)
    }
}

private struct ItemCard: View {
    let item: InventoryItem
    let settings: AppSettings

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [item.rarity.color.opacity(0.45), .clear],
                                         center: .center, startRadius: 1, endRadius: 38))
                    .frame(width: 72, height: 72)
                Image(systemName: item.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(item.rarity.color)
            }
            .frame(height: 48)

            Text(settings.t("item.\(item.itemID)"))
                .font(.ui(15, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(settings.t("rarity.\(item.rarity.rawValue)").uppercased())
                .font(.ui(11, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(item.rarity.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(item.rarity.color.opacity(0.16), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .glassCard(cornerRadius: 18)
        .overlay(RoundedRectangle(cornerRadius: 18)
            .strokeBorder(item.rarity.color.opacity(0.3), lineWidth: 1))
    }
}

#Preview {
    InventoryView()
        .environment(AppSettings())
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
