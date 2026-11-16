import SwiftUI

/// Sentences about sleep that every theme shows as they are. Short labels (titles, tags) live in
/// each theme, because their casing is part of the look.
enum SleepCopy {
    static func goalSummary(cycles: Int) -> LocalizedStringKey {
        "\(cycles) ciclos = \(SleepMath.hoursText(cycles: cycles)) h de sueño. 5 es lo recomendado."
    }

    static func cycleDetail(_ cycles: Int) -> LocalizedStringKey {
        switch cycles {
        case 6...: "Sueño óptimo. Te despertarás renovado y con máxima alerta mental."
        case 5: "Sueño ideal. Cumple con la recomendación general de descanso saludable."
        case 4: "Sueño mínimo. Suficiente para funcionar, pero podrías sentir fatiga acumulada."
        default: "Sueño insuficiente. Es probable que tengas somnolencia durante el día."
        }
    }

    static func napDetail(_ nap: Nap) -> LocalizedStringKey {
        switch nap {
        case .power: "Sueño ligero. Recarga sin entrar en sueño profundo, así evitas el atontamiento."
        case .nasa: "Estudio de la NASA: mejora el rendimiento un 34% y la alerta mental un 54%."
        case .fullCycle: "Un ciclo entero con sueño REM. Consolida la memoria y la creatividad."
        }
    }

    struct FAQ: Identifiable {
        let id: Int
        let question: LocalizedStringKey
        let answer: LocalizedStringKey
    }

    static let faqs = [
        FAQ(
            id: 0,
            question: "¿Cómo funcionan los ciclos de 90 minutos?",
            answer: "Tu cerebro recorre 4 fases de sueño cada ~90 minutos. Despertar al final de un ciclo se siente natural y renovado."
        ),
        FAQ(
            id: 1,
            question: "¿Por qué la siesta NASA dura 26 minutos?",
            answer: "Estudios de la NASA con pilotos mostraron que 26 min mejora la alerta (+54%) y el rendimiento (+34%) justo antes de entrar en sueño profundo."
        ),
        FAQ(
            id: 2,
            question: "¿Por qué evitar siestas de 45 a 60 minutos?",
            answer: "Despertar en pleno sueño profundo causa 'inercia del sueño': desorientación, dolor de cabeza y más fatiga."
        ),
        FAQ(
            id: 3,
            question: "Consejos de higiene del sueño",
            answer: "Evita pantallas 1 h antes de dormir, mantén la habitación fresca (~18°C) y corta la cafeína 6 h antes de acostarte."
        ),
    ]
}
