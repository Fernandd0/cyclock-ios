import SwiftUI

struct TerminalCalculatorView: View {
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
                    ForEach(CycleOptions.calculator, id: \.self) { cycles in
                        cycleRow(cycles: cycles, mode: mode)
                    }
                }
            }
        }
    }

    private func modeLink(_ title: LocalizedStringKey, _ mode: CalcMode) -> some View {
        BracketButton(title, isSelected: appState.calcMode == mode) {
            guard appState.calcMode != mode else { return }
            appState.selectCalcMode(mode)
            expanded = nil
        }
    }

    private func cycleRow(cycles: Int, mode: CalcMode) -> some View {
        let result = mode == .wakeUp
            ? SleepMath.bedtime(wakingAt: appState.calcTime, cycles: cycles)
            : SleepMath.wakeTime(sleepingAt: appState.calcTime, cycles: cycles)

        let rating = SleepRating(cycles: cycles)

        return TimeRow(
            index: String(format: "%02d", cycles),
            time: result,
            hours: SleepMath.hoursText(cycles: cycles),
            tag: rating.terminalLabel,
            tagColor: rating.terminalColor,
            highlighted: cycles == CycleOptions.recommended,
            detail: SleepCopy.cycleDetail(cycles),
            isExpanded: expanded == cycles,
            kind: mode == .wakeUp ? .bedtime : .wake
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.snappy) { expanded = expanded == cycles ? nil : cycles }
        }
    }
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
                ForEach(Nap.allCases) { nap in
                    TimeRow(
                        index: String(nap.minutes),
                        time: SleepMath.napEnd(from: timeline.date, minutes: nap.minutes),
                        tag: nap.terminalName,
                        tagColor: nap.terminalColor,
                        highlighted: nap == .nasa,
                        detail: SleepCopy.napDetail(nap),
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
