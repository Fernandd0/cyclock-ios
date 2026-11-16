import SwiftUI

/// Terminal-style palette: a dark set and its inverted (light) counterpart.
nonisolated extension Color {
    /// Background.
    static let ink = Color(light: 0xD5D5D5, dark: 0x1A1A1A)
    /// Main text.
    static let paper = Color(light: 0x2A2830, dark: 0xE1E1E1)
    /// Comments and secondary text.
    static let dim = Color(light: 0x7E7E7E, dark: 0x898989)

    static let codePurple = Color(light: 0x6B1FA3, dark: 0xB462FF)
    static let codeFuchsia = Color(light: 0xF50777, dark: 0xFF45B4)
    static let codeBlue = Color(light: 0x0B8CFF, dark: 0x18B6FF)
    static let codeGreen = Color(light: 0x00A76C, dark: 0x1BEB9E)
    static let codeOrange = Color(light: 0xDD7200, dark: 0xFF9528)
    static let codeYellow = Color(light: 0x949700, dark: 0xDDDD25)
}

extension Font {
    /// Monospaced system font that still follows Dynamic Type.
    static func mono(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .monospaced, weight: weight)
    }
}

extension View {
    /// Soft glow behind text, like a CRT.
    func glow(_ color: Color) -> some View {
        shadow(color: color.opacity(0.45), radius: 6)
    }
}

// MARK: - Labels and colors of shared models

extension SleepRating {
    var terminalLabel: LocalizedStringKey {
        switch self {
        case .excellent: "excelente"
        case .sufficient: "suficiente"
        case .poor: "deficiente"
        }
    }

    var terminalColor: Color {
        switch self {
        case .excellent: .codeGreen
        case .sufficient: .codeYellow
        case .poor: .codeFuchsia
        }
    }
}

extension Nap {
    var terminalName: LocalizedStringKey {
        switch self {
        case .power: "power nap"
        case .nasa: "siesta nasa"
        case .fullCycle: "ciclo completo"
        }
    }

    var terminalColor: Color {
        switch self {
        case .power: .dim
        case .nasa: .codeYellow
        case .fullCycle: .codeGreen
        }
    }
}

extension AppStyle {
    var terminalName: LocalizedStringKey {
        switch self {
        case .minimal: "minimal"
        case .terminal: "consola"
        }
    }
}

extension AppearanceMode {
    var terminalName: LocalizedStringKey {
        switch self {
        case .system: "auto"
        case .light: "claro"
        case .dark: "oscuro"
        }
    }
}
