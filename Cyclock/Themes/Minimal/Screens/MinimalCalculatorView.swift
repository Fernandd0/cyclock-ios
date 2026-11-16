import SwiftUI

struct MinimalCalculatorView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        let mode = appState.calcMode

        TimelineView(.everyMinute) { timeline in
            List {
                modePicker
                if mode == .nap {
                    napSection(now: timeline.date)
                } else {
                    timeSection(mode: mode)
                    resultsSection(mode: mode)
                }
            }
        }
        .navigationTitle("Calcular")
    }

    private var modePicker: some View {
        Section {
            Picker("Modo", selection: Binding(get: { appState.calcMode }, set: { appState.selectCalcMode($0) })) {
                Text("Despertar").tag(CalcMode.wakeUp)
                Text("Dormir").tag(CalcMode.bedtime)
                Text("Siesta").tag(CalcMode.nap)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }

    private func timeSection(mode: CalcMode) -> some View {
        @Bindable var appState = appState

        return Section {
            DatePicker(
                mode == .wakeUp ? "Hora de despertar" : "Hora de dormir",
                selection: $appState.calcTime,
                displayedComponents: .hourAndMinute
            )
        }
    }

    private func resultsSection(mode: CalcMode) -> some View {
        Section {
            ForEach(CycleOptions.calculator, id: \.self) { cycles in
                let rating = SleepRating(cycles: cycles)

                MinimalTimeRow(
                    time: mode == .wakeUp
                        ? SleepMath.bedtime(wakingAt: appState.calcTime, cycles: cycles)
                        : SleepMath.wakeTime(sleepingAt: appState.calcTime, cycles: cycles),
                    cycles: cycles,
                    tag: rating.minimalLabel,
                    tagColor: rating.minimalColor,
                    detail: SleepCopy.cycleDetail(cycles),
                    kind: mode == .wakeUp ? .bedtime : .wake
                )
            }
        } header: {
            Text(mode == .wakeUp ? "Deberías dormirte a las" : "Deberías despertar a las")
        } footer: {
            Text("Ciclos de 90 min + 14 min para dormirte.")
        }
    }

    private func napSection(now: Date) -> some View {
        Section {
            ForEach(Nap.allCases) { nap in
                MinimalTimeRow(
                    time: SleepMath.napEnd(from: now, minutes: nap.minutes),
                    subtitle: Text("\(nap.minutes) min"),
                    tag: nap.minimalName,
                    detail: SleepCopy.napDetail(nap),
                    kind: .nap
                )
            }
        } header: {
            Text("Si te acuestas ahora, despierta a las")
        } footer: {
            Text("Incluye 5 min para dormirte.")
        }
    }
}
