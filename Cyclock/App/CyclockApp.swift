import SwiftUI

@main
struct CyclockApp: App {
    @State private var appState = AppState()
    @State private var alarms = AlarmService()
    @AppStorage(Prefs.theme) private var appearance = AppearanceMode.system
    @AppStorage(Prefs.style) private var style = AppStyle.minimal

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(alarms)
                .preferredColorScheme(appearance.colorScheme)
                .tint(style.tint)
        }
    }
}
