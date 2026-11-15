import SwiftUI

/// Sleep goal, appearance and the sleep-science FAQ. Everything is stored on device.
struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage(Prefs.theme) private var theme = "dark"
    @AppStorage(Prefs.goalCycles) private var goalCycles = 5
    @AppStorage(Prefs.wakeMinutes) private var wakeMinutes = 420
    @State private var openFAQ: Int?

    private var wakeTime: Binding<Date> {
        Binding(
            get: { SleepMath.today(minutes: wakeMinutes) },
            set: { wakeMinutes = SleepMath.minutesSinceMidnight($0) }
        )
    }

    var body: some View {
        Screen(comment: Comment("todo se guarda en tu iPhone"), title: "ajustes") {
            VStack(alignment: .leading, spacing: 0) {
                KeyValue(key: "meta") {
                    GoalPicker(goalCycles: $goalCycles)
                }
                KeyValue(key: "despertar") {
                    TimeField(label: "Hora de despertar", time: wakeTime)
                }
                Comment("\(goalCycles) ciclos = \(SleepMath.hoursText(cycles: goalCycles)) h de sueño. 5 es lo recomendado.")
                    .padding(.top, 6)
            }

            DashedRule()

            VStack(alignment: .leading, spacing: 0) {
                KeyValue(key: "tema") {
                    LinkRow(spacing: 12) {
                        themeLink("oscuro", "dark")
                        themeLink("claro", "light")
                        themeLink("auto", "system")
                    }
                    .font(.mono(.subheadline))
                }
                KeyValue(key: "idioma") {
                    BracketButton("cambiar en iOS", color: .codeBlue) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .font(.mono(.subheadline))
                }
            }

            DashedRule()

            VStack(alignment: .leading, spacing: 4) {
                Comment("ciencia del sueño")
                    .padding(.bottom, 6)
                ForEach(Array(faqs.enumerated()), id: \.offset) { index, faq in
                    faqRow(index: index, question: faq.question, answer: faq.answer)
                }
            }
        }
    }

    private func themeLink(_ title: LocalizedStringKey, _ value: String) -> some View {
        BracketButton(title, color: .codeBlue, isSelected: theme == value) {
            theme = value
        }
    }

    private func faqRow(index: Int, question: LocalizedStringKey, answer: LocalizedStringKey) -> some View {
        let isOpen = openFAQ == index

        return Button {
            withAnimation(.snappy) { openFAQ = isOpen ? nil : index }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(verbatim: isOpen ? "-" : "+")
                        .foregroundStyle(Color.codeOrange)
                    Text(question)
                        .foregroundStyle(isOpen ? Color.codeYellow : Color.paper)
                        .multilineTextAlignment(.leading)
                }
                .font(.mono(.subheadline))
                if isOpen {
                    Text(answer)
                        .font(.mono(.footnote))
                        .foregroundStyle(Color.dim)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 18)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var faqs: [(question: LocalizedStringKey, answer: LocalizedStringKey)] {
        [
            (
                "¿Cómo funcionan los ciclos de 90 minutos?",
                "Tu cerebro recorre 4 fases de sueño cada ~90 minutos. Despertar al final de un ciclo se siente natural y renovado."
            ),
            (
                "¿Por qué la siesta NASA dura 26 minutos?",
                "Estudios de la NASA con pilotos mostraron que 26 min mejora la alerta (+54%) y el rendimiento (+34%) justo antes de entrar en sueño profundo."
            ),
            (
                "¿Por qué evitar siestas de 45 a 60 minutos?",
                "Despertar en pleno sueño profundo causa 'inercia del sueño': desorientación, dolor de cabeza y más fatiga."
            ),
            (
                "Consejos de higiene del sueño",
                "Evita pantallas 1 h antes de dormir, mantén la habitación fresca (~18°C) y corta la cafeína 6 h antes de acostarte."
            ),
        ]
    }
}
