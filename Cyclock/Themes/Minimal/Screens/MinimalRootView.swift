import SwiftUI

/// Root of the minimal style: onboarding on first launch, then the system tab bar.
struct MinimalRootView: View {
    @Environment(AppState.self) private var appState
    @AppStorage(Prefs.didOnboard) private var didOnboard = false

    var body: some View {
        @Bindable var appState = appState

        if didOnboard {
            TabView(selection: $appState.tab) {
                Tab("Inicio", systemImage: "moon.stars.fill", value: AppTab.home) {
                    NavigationStack { MinimalHomeView() }
                }
                Tab("Calcular", systemImage: "clock.fill", value: AppTab.calculator) {
                    NavigationStack { MinimalCalculatorView() }
                }
                Tab("Ajustes", systemImage: "gearshape.fill", value: AppTab.settings) {
                    NavigationStack { MinimalSettingsView() }
                }
            }
        } else {
            MinimalOnboardingView()
        }
    }
}
