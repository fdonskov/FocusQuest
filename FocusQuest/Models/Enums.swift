import Foundation

enum SessionType: String, Codable, CaseIterable {
    case focus
    case shortBreak
    case longBreak
}

enum Rarity: String, Codable, CaseIterable {
    case common
    case rare
    case epic
    case legendary
}
