import SwiftUI

struct TerminalHomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(AlarmService.self) private var alarms
    private var schedule = SleepSchedule()

    var body: some View {
        let wake = schedule.wake
        let bedtime = schedule.bedtime

        Screen(comment: Comment(verbatim: Self.todayText), title: "cyclock") {
            VStack(alignment: .leading, spacing: 0) {
                KeyValue(key: "meta") {
                    Text("\(schedule.hoursText) h · \(schedule.cycles) ciclos")
                }
                .padding(.bottom, 6)
                KeyValue(key: "dormir") {
                    Text(verbatim: bedtime.clock)
                        .foregroundStyle(Color.codeGreen)
                        .glow(.codeGreen)
                    Spacer(minLength: 8)
                    SetAlarmButton(date: bedtime, kind: .bedtime)
                }
                KeyValue(key: "despertar") {
                    Text(verbatim: wake.clock)
                    Spacer(minLength: 8)
                    SetAlarmButton(date: wake, kind: .wake)
                }
                BracketButton("editar", color: .codeBlue) {
                    appState.tab = .settings
                }
            }

            DashedRule()

            TimelineView(.everyMinute) { timeline in
                VStack(alignment: .leading, spacing: 10) {
                    Comment("si te duermes ahora, despierta a las")
                    ForEach(CycleOptions.home, id: \.self) { cycles in
                        TimeRow(
                            index: String(format: "%02d", cycles),
                            time: SleepMath.wakeTime(sleepingAt: timeline.date, cycles: cycles),
                            hours: SleepMath.hoursText(cycles: cycles),
                            tag: cycles == CycleOptions.recommended ? "recomendado" : "\(cycles) ciclos",
                            tagColor: cycles == CycleOptions.recommended ? .codeGreen : .dim,
                            highlighted: cycles == CycleOptions.recommended,
                            kind: .wake
                        )
                    }
                }
            }

            if !alarms.upcoming.isEmpty {
                DashedRule()
                scheduledAlarms
            }

            DashedRule()

            LinkRow(spacing: 18) {
                BracketButton("otra hora") {
                    appState.calcMode = .wakeUp
                    appState.tab = .calculator
                }
                BracketButton("siestas") {
                    appState.calcMode = .nap
                    appState.tab = .calculator
                }
            }
        }
    }

    private var scheduledAlarms: some View {
        VStack(alignment: .leading, spacing: 0) {
            Comment("alarmas programadas (no salen en la app Reloj)")
            ForEach(alarms.upcoming) { alarm in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(verbatim: alarm.date.clock)
                        .foregroundStyle(Color.codeGreen)
                    HStack(spacing: 0) {
                        if let kind = alarm.kind {
                            Text(kind.label)
                            Text(verbatim: " · ")
                        }
                        Text(Calendar.current.isDateInToday(alarm.date) ? "hoy" : "mañana")
                    }
                    .font(.mono(.footnote))
                    .foregroundStyle(Color.dim)
                    .lineLimit(1)
                    Spacer(minLength: 4)
                    BracketButton("quitar", color: .codeOrange) {
                        withAnimation(.snappy) { alarms.cancel(alarm.date) }
                    }
                    .font(.mono(.subheadline))
                }
            }
        }
    }

    /// Today's date in lowercase, e.g. "domingo, 15 de noviembre".
    private static var todayText: String {
        Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)).lowercased()
    }
}
