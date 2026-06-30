import SwiftUI
import SwiftData

struct InventoryView: View {
    @Query(sort: \InventoryItem.obtainedDate, order: .reverse) private var items: [InventoryItem]
    @State private var filter: Rarity?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

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
            .navigationTitle("Инвентарь")
        }
    }

    @ViewBuilder
    private var content: some View {
        if filtered.isEmpty {
            ContentUnavailableView("Пока пусто", systemImage: "bag",
                                   description: Text("Завершайте фокус-сессии, чтобы находить предметы"))
                .frame(maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filtered) { item in
                        ItemCard(item: item)
                    }
                }
                .padding()
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "Все", isSelected: filter == nil) { filter = nil }
                ForEach(Rarity.allCases, id: \.self) { rarity in
                    FilterChip(title: rarity.title, isSelected: filter == rarity) { filter = rarity }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
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
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.ultraThinMaterial),
                            in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

private struct ItemCard: View {
    let item: InventoryItem

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: item.iconName)
                .font(.system(size: 34))
                .foregroundStyle(item.rarity.color)
                .frame(height: 44)
            Text(item.name)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
            Text(item.rarity.title)
                .font(.caption)
                .foregroundStyle(item.rarity.color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(item.rarity.color.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    InventoryView()
        .modelContainer(for: [Character.self, FocusSession.self, InventoryItem.self,
                              Achievement.self, Location.self], inMemory: true)
}
