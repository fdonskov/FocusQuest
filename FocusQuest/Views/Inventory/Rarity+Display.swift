import SwiftUI

extension Rarity {
    var color: Color {
        switch self {
        case .common: return Color(hex: 0x9AA0B8)
        case .rare: return Color(hex: 0x5BA8FF)
        case .epic: return Color(hex: 0xC084FC)
        case .legendary: return Color(hex: 0xFFB23E)
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: [color.opacity(0.9), color.opacity(0.4)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
