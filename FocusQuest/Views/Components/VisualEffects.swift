import SwiftUI

// Subtle screen entrance on tab switch: content rises 12pt and fades in.
// Applied per tab so it replays on every reappearance without recreating the view.
struct ScreenEntrance: ViewModifier {
    @Environment(AppSettings.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .offset(y: shown ? 0 : 12)
            .opacity(shown ? 1 : 0)
            .onAppear {
                if settings.reduceMotion || systemReduceMotion {
                    shown = true
                    return
                }
                shown = false
                withAnimation(.easeOut(duration: 0.35)) { shown = true }
            }
            .onDisappear { shown = false }
    }
}

extension View {
    func screenEntrance() -> some View { modifier(ScreenEntrance()) }
}

struct PulsingAura: View {
    var color: Color
    var maxRadius: CGFloat = 90
    var reduceMotion: Bool = false

    @State private var animate = false

    var body: some View {
        Circle()
            .fill(RadialGradient(colors: [color.opacity(0.55), .clear],
                                 center: .center, startRadius: 2, endRadius: maxRadius))
            .scaleEffect(animate ? 1.18 : 0.9)
            .opacity(animate ? 0.95 : 0.55)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
            .allowsHitTesting(false)
    }
}
