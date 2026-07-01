import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    var language: String { didSet { defaults.set(language, forKey: Keys.language) } }
    var demoMode: Bool { didSet { defaults.set(demoMode, forKey: Keys.demoMode) } }
    var sound: Bool { didSet { defaults.set(sound, forKey: Keys.sound) } }
    var notifications: Bool { didSet { defaults.set(notifications, forKey: Keys.notifications) } }
    var reduceMotion: Bool { didSet { defaults.set(reduceMotion, forKey: Keys.reduceMotion) } }
    var defaultPresetMinutes: Int { didSet { defaults.set(defaultPresetMinutes, forKey: Keys.preset) } }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let language = "appLanguage"
        static let demoMode = "demoMode"
        static let sound = "sound"
        static let notifications = "notifications"
        static let reduceMotion = "reduceMotion"
        static let preset = "defaultPresetMinutes"
    }

    init() {
        let d = UserDefaults.standard
        language = d.string(forKey: Keys.language) ?? AppSettings.defaultLanguage()
        // Demo toggle is hidden from the UI for now; keep the mode off regardless of any stored value.
        demoMode = false
        sound = d.object(forKey: Keys.sound) as? Bool ?? true
        notifications = d.object(forKey: Keys.notifications) as? Bool ?? true
        reduceMotion = d.object(forKey: Keys.reduceMotion) as? Bool ?? false
        defaultPresetMinutes = d.object(forKey: Keys.preset) as? Int ?? 25
    }

    // RU/BY/UA regions default to Russian, everything else to English.
    static func defaultLanguage() -> String {
        let region = Locale.current.region?.identifier ?? ""
        return ["RU", "BY", "UA"].contains(region) ? "ru" : "en"
    }

    // Resolves a String Catalog key against the chosen language bundle so switching is instant in-app.
    func t(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: key, table: nil)
        }
        return NSLocalizedString(key, comment: "")
    }
}
