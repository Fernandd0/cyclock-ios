import SwiftUI

struct MinimalHomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(AlarmService.self) private var alarms
    private var schedule = SleepSchedule()

    var body: some View {
        TimelineView(.everyMinute) { timeline in
            List {
                scheduleSection
                sleepNowSection(now: timeline.date)
                if !alarms.upcoming.isEmpty {
                    alarmsSection
                }
            }
        }
        .navigationTitle(Text(verbatim: "Cyclock"))
    }

    private var scheduleSection: some View {
        Section {
            MinimalTimeRow(time: schedule.bedtime, subtitle: Text("Hora de dormir"), showsDay: false, kind: .bedtime)
            MinimalTimeRow(time: schedule.wake, subtitle: Text("Hora de despertar"), showsDay: false, kind: .wake)
            Button("Editar horario") {
                appState.tab = .settings
            }
        } header: {
            Text("Tu horario")
        } footer: {
            Text("Meta: \(schedule.hoursText) h · \(schedule.cycles) ciclos")
        }
    }

    private func sleepNowSection(now: Date) -> some View {
        Section {
            ForEach(CycleOptions.home, id: \.self) { cycles in
                MinimalTimeRow(
                    time: SleepMath.wakeTime(sleepingAt: now, cycles: cycles),
                    cycles: cycles,
                    tag: cycles == CycleOptions.recommended ? "Recomendado" : nil,
                    tagColor: .rateGood,
                    kind: .wake
                )
            }
        } header: {
            Text("Si te duermes ahora, despierta a las")
        } footer: {
            Text("Ciclos de 90 min + 14 min para dormirte.")
        }
    }

    private var alarmsSection: some View {
        Section {
            ForEach(alarms.upcoming) { alarm in
                LabeledContent {
                    Text(Calendar.current.isDateInToday(alarm.date) ? "Hoy" : "Mañana")
                } label: {
                    Text(verbatim: alarm.date.clock)
                        .monospacedDigit()
                    if let kind = alarm.kind {
                        Text(kind.alertTitle)
                    }
                }
                .swipeActions {
                    Button("Quitar", role: .destructive) {
                        withAnimation { alarms.cancel(alarm.date) }
                    }
                }
            }
        } header: {
            Text("Alarmas programadas")
        } footer: {
            Text("No aparecen en la app Reloj. Desliza una para quitarla.")
        }
    }
}
