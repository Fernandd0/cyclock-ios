import SwiftUI

/// The looks of the app. Each one has its own folder under `Themes/` with a root view, screens and
/// components. To add a theme: add a case here, give it a tint, build its root view and return it
/// from `RootView`; the theme pickers in both settings screens list every case.
nonisolated enum AppStyle: String, CaseIterable, Identifiable {
    /// Native iOS controls, system fonts and colors. The default.
    case minimal
    /// Monospaced, code-editor look.
    case terminal

    var id: Self { self }

    /// The style saved in UserDefaults, for code that runs outside SwiftUI.
    static var current: AppStyle {
        UserDefaults.standard.string(forKey: Prefs.style).flatMap(AppStyle.init) ?? .minimal
    }

    var tint: Color {
        switch self {
        case .minimal: .indigo
        case .terminal: .codeFuchsia
        }
    }
}

/// Light / dark preference. `system` follows the device.
nonisolated enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: Self { self }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

extension OpenURLAction {
    /// Opens this app's page in the Settings app (language, alarm permission).
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            self(url)
        }
    }
}
