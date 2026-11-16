import SwiftUI

/// Root of the terminal style: monospaced text, bracket links and the cat on the navigation line.
struct TerminalRootView: View {
    @Environment(AppState.self) private var appState
    @AppStorage(Prefs.didOnboard) private var didOnboard = false

    var body: some View {
        Group {
            if didOnboard {
                tabs
            } else {
                TerminalOnboardingView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ink.ignoresSafeArea())
        .font(.mono())
        .foregroundStyle(Color.paper)
        // The layout reflows for large text, but beyond this size the big times stop fitting.
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    private var tabs: some View {
        Group {
            switch appState.tab {
            case .home: TerminalHomeView()
            case .calculator: TerminalCalculatorView()
            case .settings: TerminalSettingsView()
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
