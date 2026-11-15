import SwiftUI

struct CalculatorView: View {
    @Environment(AppState.self) private var appState
    @State private var expanded: Int?

    var body: some View {
        @Bindable var appState = appState
        let mode = appState.calcMode

        Screen(comment: Comment("ciclos de 90 min + 14 min para dormirte"), title: "calcular") {
            LinkRow {
                modeLink("despertar", .wakeUp)
                modeLink("dormir", .bedtime)
                modeLink("siesta", .nap)
            }

            if mode == .nap {
                NapList(expanded: $expanded)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    KeyValue(key: mode == .wakeUp ? "despertar" : "dormir") {
                        TimeField(
                            label: mode == .wakeUp ? "Hora de despertar" : "Hora de dormir",
                            time: $appState.calcTime
                        )
                    }
                    LinkRow(spacing: 12) {
                        ForEach(mode == .wakeUp ? [390, 420, 450] : [1320, 1350, 1380], id: \.self) { minutes in
                            BracketButton(
                                Text(verbatim: SleepMath.today(minutes: minutes).clock),
                                color: .codeBlue,
                                isSelected: SleepMath.minutesSinceMidnight(appState.calcTime) == minutes
                            ) {
                                appState.calcTime = SleepMath.today(minutes: minutes)
                            }
                        }
                    }
                    .font(.mono(.footnote))
                }

                DashedRule()

                VStack(alignment: .leading, spacing: 10) {
                    Comment(mode == .wakeUp ? "deberías dormirte a las" : "deberías despertar a las")
                    ForEach([5, 6, 4, 3], id: \.self) { cycles in
                        cycleRow(cycles: cycles, mode: mode)
                    }
                }
            }
        }
    }

    private func modeLink(_ title: LocalizedStringKey, _ mode: CalcMode) -> some View {
        BracketButton(title, isSelected: appState.calcMode == mode) {
            guard appState.calcMode != mode else { return }
            appState.calcMode = mode
            expanded = nil
            if mode == .wakeUp { appState.calcTime = SleepMath.today(minutes: 420) }
            if mode == .bedtime { appState.calcTime = SleepMath.today(minutes: 1350) }
        }
    }

    private func cycleRow(cycles: Int, mode: CalcMode) -> some View {
        let result = mode == .wakeUp
            ? SleepMath.bedtime(wakingAt: appState.calcTime, cycles: cycles)
            : SleepMath.wakeTime(sleepingAt: appState.calcTime, cycles: cycles)

        return TimeRow(
            index: String(format: "%02d", cycles),
            time: result,
            hours: SleepMath.hoursText(cycles: cycles),
            tag: rating(for: cycles),
            tagColor: ratingColor(for: cycles),
            highlighted: cycles == 5,
            detail: details(for: cycles),
            isExpanded: expanded == cycles,
            kind: mode == .wakeUp ? .bedtime : .wake
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.snappy) { expanded = expanded == cycles ? nil : cycles }
        }
    }

    private func rating(for cycles: Int) -> LocalizedStringKey {
        switch cycles {
        case 5...: "excelente"
        case 4: "suficiente"
        default: "deficiente"
        }
    }

    private func ratingColor(for cycles: Int) -> Color {
        switch cycles {
        case 5...: .codeGreen
        case 4: .codeYellow
        default: .codeFuchsia
        }
    }

    private func details(for cycles: Int) -> LocalizedStringKey {
        switch cycles {
        case 6...: "Sueño óptimo. Te despertarás renovado y con máxima alerta mental."
        case 5: "Sueño ideal. Cumple con la recomendación general de descanso saludable."
        case 4: "Sueño mínimo. Suficiente para funcionar, pero podrías sentir fatiga acumulada."
        default: "Sueño insuficiente. Es probable que tengas somnolencia durante el día."
        }
    }
}

// MARK: - Naps

private struct Nap: Identifiable {
    let minutes: Int
    let name: LocalizedStringKey
    let detail: LocalizedStringKey
    let color: Color

    var id: Int { minutes }

    static let all: [Nap] = [
        Nap(
            minutes: 20,
            name: "power nap",
            detail: "Sueño ligero. Recarga sin entrar en sueño profundo, así evitas el atontamiento.",
            color: .dim
        ),
        Nap(
            minutes: 26,
            name: "siesta nasa",
            detail: "Estudio de la NASA: mejora el rendimiento un 34% y la alerta mental un 54%.",
            color: .codeYellow
        ),
        Nap(
            minutes: 90,
            name: "ciclo completo",
            detail: "Un ciclo entero con sueño REM. Consolida la memoria y la creatividad.",
            color: .codeGreen
        ),
    ]
}

/// Nap end times counted from the current time; refreshes every minute.
private struct NapList: View {
    @Binding var expanded: Int?

    var body: some View {
        TimelineView(.everyMinute) { timeline in
            VStack(alignment: .leading, spacing: 10) {
                DashedRule()
                Comment("desde ahora + 5 min para dormirte, despierta a las")
                    .padding(.top, 12)
                ForEach(Nap.all) { nap in
                    TimeRow(
                        index: String(nap.minutes),
                        time: SleepMath.napEnd(from: timeline.date, minutes: nap.minutes),
                        tag: nap.name,
                        tagColor: nap.color,
                        highlighted: nap.minutes == 26,
                        detail: nap.detail,
                        isExpanded: expanded == nap.minutes,
                        kind: .nap
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.snappy) { expanded = expanded == nap.minutes ? nil : nap.minutes }
                    }
                }
            }
        }
    }
}
