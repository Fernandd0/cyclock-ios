import Foundation

/// UserDefaults keys used with @AppStorage.
nonisolated enum Prefs {
    /// Color scheme: "system", "light" or "dark".
    static let theme = "theme"
    /// Look of the app, an `AppStyle` raw value.
    static let style = "style"
    static let didOnboard = "didOnboard"
    static let goalCycles = "goalCycles"
    static let wakeMinutes = "wakeMinutes"
}
