import SwiftUI

enum AppTab: Hashable {
    case home, calculator, settings
}

enum CalcMode: Hashable {
    /// The user picks a wake-up time and gets bedtimes.
    case wakeUp
    /// The user picks a bedtime and gets wake-up times.
    case bedtime
    /// Nap end times counted from now.
    case nap
}

/// Navigation and calculator state shared across screens.
@Observable
final class AppState {
    var tab: AppTab = .home
    var calcMode: CalcMode = .wakeUp
    var calcTime = SleepMath.today(minutes: 7 * 60)

    init() {
        #if DEBUG
        // Debug builds accept `-startTab calculator|naps|settings` as a launch argument (handy for screenshots).
        switch UserDefaults.standard.string(forKey: "startTab") {
        case "calculator": tab = .calculator
        case "naps": tab = .calculator; calcMode = .nap
        case "settings": tab = .settings
        default: break
        }
        #endif
    }
}

@main
struct CyclockApp: App {
    @State private var appState = AppState()
    @State private var alarms = AlarmService()
    @AppStorage(Prefs.theme) private var theme = "dark"

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(alarms)
                .preferredColorScheme(theme == "dark" ? .dark : theme == "light" ? .light : nil)
                .tint(.codeFuchsia)
        }
    }
}

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AlarmService.self) private var alarms
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @AppStorage(Prefs.didOnboard) private var didOnboard = false

    var body: some View {
        Group {
            if didOnboard {
                tabs
            } else {
                OnboardingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ink.ignoresSafeArea())
        .font(.mono())
        .foregroundStyle(Color.paper)
        // The layout reflows for large text, but beyond this size the big times stop fitting.
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .alert(
            "Alarma",
            isPresented: Binding(
                get: { alarms.errorMessage != nil },
                set: { if !$0 { alarms.errorMessage = nil } }
            )
        ) {
            if alarms.permissionDenied {
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(alarms.errorMessage ?? "")
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { alarms.refresh() }
        }
    }

    private var tabs: some View {
        Group {
            switch appState.tab {
            case .home: HomeView()
            case .calculator: CalculatorView()
            case .settings: SettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) { navigation }
    }

    private var navigation: some View {
        VStack(spacing: 0) {
            DashedRule()
            HStack(spacing: 18) {
                link("inicio", .home)
                link("calcular", .calculator)
                link("ajustes", .settings)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
            // Three links must stay on one line, so the bar does not grow with the text size.
            .dynamicTypeSize(...DynamicTypeSize.large)
        }
        .background(Color.ink)
        // The cat stands on the dashed line, at the right: full size at home, small elsewhere.
        .overlay(alignment: .topTrailing) {
            Mascot(compact: appState.tab != .home)
                .alignmentGuide(.top) { $0[.bottom] }
                .padding(.trailing, 20)
        }
    }

    private func link(_ title: LocalizedStringKey, _ tab: AppTab) -> some View {
        BracketButton(title, isSelected: appState.tab == tab) {
            appState.tab = tab
        }
    }
}
