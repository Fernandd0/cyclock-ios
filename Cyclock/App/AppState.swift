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

    /// Switches the calculator mode and resets the time to a sensible default for it.
    func selectCalcMode(_ mode: CalcMode) {
        guard calcMode != mode else { return }
        calcMode = mode
        if mode == .wakeUp { calcTime = SleepMath.today(minutes: 420) }
        if mode == .bedtime { calcTime = SleepMath.today(minutes: 1350) }
    }
}
