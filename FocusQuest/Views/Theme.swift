import SwiftUI

extension Color {
    init(hex: UInt) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}

enum Theme {
    static let void = Color(hex: 0x08060F)
    static let purple = Color(hex: 0x9B6BFF)
    static let purpleDeep = Color(hex: 0x7C4CFF)
    static let cyan = Color(hex: 0x46E6FF)

    static let textPrimary = Color(hex: 0xF1ECFF)
    static let textSecondary = Color(hex: 0xA99FC9)
    static let textMuted = Color(hex: 0x8B81AD)
    static let accentText = Color(hex: 0xCDBCFF)

    static let cardCornerRadius: CGFloat = 20

    static let mainGradient = LinearGradient(colors: [purple, cyan],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)

    static let xpGradient = LinearGradient(colors: [purpleDeep, cyan],
                                           startPoint: .leading, endPoint: .trailing)

    static let voidBackground = RadialGradient(
        colors: [Color(hex: 0x16122C), Color(hex: 0x0B0918), Color(hex: 0x060410)],
        center: .top, startRadius: 0, endRadius: 760
    )
}

extension View {
    func glassCard(cornerRadius: CGFloat = Theme.cardCornerRadius, tint: Color? = nil) -> some View {
        glassEffect(.regular.tint(tint), in: RoundedRectangle(cornerRadius: cornerRadius))
    }

    func glassCard(_ shape: some Shape, tint: Color? = nil) -> some View {
        glassEffect(.regular.tint(tint), in: shape)
    }

    func screenBackground() -> some View {
        background(Theme.voidBackground.ignoresSafeArea())
    }
}
