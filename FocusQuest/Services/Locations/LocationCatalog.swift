import Foundation

struct LocationSeed {
    let id: String
    let name: String
    let requiredLevel: Int
    let iconName: String
    let hue: Double
}

enum LocationCatalog {
    static let all: [LocationSeed] = [
        LocationSeed(id: "meadow", name: "Луг", requiredLevel: 1, iconName: "leaf.fill", hue: 140),
        LocationSeed(id: "forest", name: "Лес", requiredLevel: 2, iconName: "tree.fill", hue: 158),
        LocationSeed(id: "caves", name: "Пещеры", requiredLevel: 4, iconName: "mountain.2.fill", hue: 28),
        LocationSeed(id: "mountains", name: "Горы", requiredLevel: 6, iconName: "snowflake", hue: 206),
        LocationSeed(id: "castle", name: "Замок", requiredLevel: 9, iconName: "building.columns.fill", hue: 276),
        LocationSeed(id: "voidgate", name: "Врата Бездны", requiredLevel: 13, iconName: "sparkles", hue: 300),
    ]

    static func seed(for id: String) -> LocationSeed {
        all.first { $0.id == id } ?? all[0]
    }

    static func icon(for id: String) -> String {
        seed(for: id).iconName
    }

    static func sceneName(for id: String) -> String {
        "scene_\(id)"
    }

    static func localizationKey(for id: String) -> String {
        "loc.\(id)"
    }
}
