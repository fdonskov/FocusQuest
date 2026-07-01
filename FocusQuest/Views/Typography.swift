import SwiftUI
import CoreText
#if canImport(UIKit)
import UIKit
#endif

// Design typography: Space Grotesk for display/numbers/titles, Manrope for UI text.
// Font files are added by the project owner (Google Fonts, OFL). When they are present
// in the bundle they get registered at launch and the helpers below pick them up;
// otherwise everything falls back to the matching system font so the UI stays intact.
enum AppFonts {
    static let groteskMedium = "SpaceGrotesk-Medium"
    static let groteskSemibold = "SpaceGrotesk-SemiBold"
    static let groteskBold = "SpaceGrotesk-Bold"

    static let manropeRegular = "Manrope-Regular"
    static let manropeMedium = "Manrope-Medium"
    static let manropeSemibold = "Manrope-SemiBold"
    static let manropeBold = "Manrope-Bold"

    // Register any .otf/.ttf shipped in the bundle so Info.plist UIAppFonts is optional.
    static func registerBundledFonts() {
        for ext in ["otf", "ttf"] {
            for url in Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [] {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    static func isAvailable(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIFont(name: name, size: 12) != nil
        #else
        return NSFont(name: name, size: 12) != nil
        #endif
    }
}

extension Font {
    // Display/headings/numbers. Falls back to the rounded system font.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        let name: String
        switch weight {
        case .medium: name = AppFonts.groteskMedium
        case .semibold: name = AppFonts.groteskSemibold
        default: name = AppFonts.groteskBold
        }
        if AppFonts.isAvailable(name) { return .custom(name, size: size, relativeTo: .body) }
        return .system(size: size, weight: weight, design: .rounded)
    }

    // Interface text. Falls back to the default system font.
    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold, .heavy, .black: name = AppFonts.manropeBold
        case .semibold: name = AppFonts.manropeSemibold
        case .medium: name = AppFonts.manropeMedium
        default: name = AppFonts.manropeRegular
        }
        // .custom(...relativeTo:) scales with Dynamic Type; the named font falls back
        // to the system font when missing, so UI text scales even before the .ttf is added.
        let font = Font.custom(name, size: size, relativeTo: .body)
        return AppFonts.isAvailable(name) ? font : font.weight(weight)
    }
}
