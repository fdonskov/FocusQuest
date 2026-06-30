import Foundation

struct LocationSeed {
    let id: String
    let name: String
    let requiredLevel: Int
    let iconName: String
}

enum LocationCatalog {
    static let all: [LocationSeed] = [
        LocationSeed(id: "meadow", name: "Луг", requiredLevel: 1, iconName: "leaf.fill"),
        LocationSeed(id: "forest", name: "Лес", requiredLevel: 2, iconName: "tree.fill"),
        LocationSeed(id: "caves", name: "Пещеры", requiredLevel: 4, iconName: "mountain.2.fill"),
        LocationSeed(id: "mountains", name: "Горы", requiredLevel: 6, iconName: "snowflake"),
        LocationSeed(id: "castle", name: "Замок", requiredLevel: 9, iconName: "building.columns.fill"),
        LocationSeed(id: "voidgate", name: "Врата Бездны", requiredLevel: 13, iconName: "sparkles"),
    ]

    static func icon(for id: String) -> String {
        all.first { $0.id == id }?.iconName ?? "mappin.and.ellipse"
    }
}
