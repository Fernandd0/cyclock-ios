import SwiftUI

/// Shows the root view of the selected theme and owns what every theme shares: the alarm error
/// alert and refreshing the alarm list when the app comes back to the foreground.
struct RootView: View {
    @Environment(AlarmService.self) private var alarms
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @AppStorage(Prefs.style) private var style = AppStyle.minimal

    var body: some View {
        Group {
            switch style {
            case .minimal: MinimalRootView()
            case .terminal: TerminalRootView()
            }
        }
        .alert(
            "Alarma",
            isPresented: Binding(
                get: { alarms.errorMessage != nil },
                set: { if !$0 { alarms.errorMessage = nil } }
            )
        ) {
            if alarms.permissionDenied {
                Button("Abrir Ajustes") { openURL.openAppSettings() }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(alarms.errorMessage ?? "")
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { alarms.refresh() }
        }
    }
}
