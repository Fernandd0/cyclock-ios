import SwiftUI

/// Status colors for the minimal style. Everything else uses the system colors. The light variants
/// are the darker, accessible system tones, so small colored text keeps its contrast on a white row.
nonisolated extension Color {
    static let rateGood = Color(light: 0x248A3D, dark: 0x30D158)
    static let rateFair = Color(light: 0xC93400, dark: 0xFF9F0A)
    static let ratePoor = Color(light: 0xD70015, dark: 0xFF453A)
}

extension SleepRating {
    var minimalLabel: LocalizedStringKey {
        switch self {
        case .excellent: "Excelente"
        case .sufficient: "Suficiente"
        case .poor: "Deficiente"
        }
    }

    var minimalColor: Color {
        switch self {
        case .excellent: .rateGood
        case .sufficient: .rateFair
        case .poor: .ratePoor
        }
    }
}

extension Nap {
    var minimalName: LocalizedStringKey {
        switch self {
        case .power: "Power nap"
        case .nasa: "Siesta NASA"
        case .fullCycle: "Ciclo completo"
        }
    }
}

extension AppStyle {
    var minimalName: LocalizedStringKey {
        switch self {
        case .minimal: "Minimal"
        case .terminal: "Consola"
        }
    }
}

extension AppearanceMode {
    var minimalName: LocalizedStringKey {
        switch self {
        case .system: "Automático"
        case .light: "Claro"
        case .dark: "Oscuro"
        }
    }
}
