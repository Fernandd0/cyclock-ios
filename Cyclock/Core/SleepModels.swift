import Foundation

/// How good a night of `cycles` full cycles is.
nonisolated enum SleepRating {
    case excellent, sufficient, poor

    init(cycles: Int) {
        switch cycles {
        case 5...: self = .excellent
        case 4: self = .sufficient
        default: self = .poor
        }
    }
}

/// The nap lengths the app offers; the raw value is the nap in minutes.
nonisolated enum Nap: Int, CaseIterable, Identifiable {
    case power = 20
    case nasa = 26
    case fullCycle = 90

    var id: Self { self }
    var minutes: Int { rawValue }
}

/// Cycle counts offered on each screen, best option first.
nonisolated enum CycleOptions {
    static let goal = [4, 5, 6]
    static let home = [5, 6, 4]
    static let calculator = [5, 6, 4, 3]
    static let recommended = 5
}
