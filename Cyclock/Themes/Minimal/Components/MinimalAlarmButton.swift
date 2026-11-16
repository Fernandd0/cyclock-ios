import SwiftUI

/// Alarm icon at the end of a row: outlined and grey when off, filled and tinted when the alarm is set.
struct MinimalAlarmButton: View {
    let date: Date
    let kind: AlarmKind

    @Environment(AlarmService.self) private var alarms

    var body: some View {
        let isSet = alarms.isSet(date)

        Button {
            Task { await alarms.toggle(at: date, kind: kind) }
        } label: {
            Label(isSet ? "Quitar alarma" : "Poner alarma", systemImage: isSet ? "alarm.fill" : "alarm")
                .labelStyle(.iconOnly)
                .font(.title3)
                .contentTransition(.symbolEffect(.replace))
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        // Borderless, so only the icon is tappable instead of the whole list row.
        .buttonStyle(.borderless)
        .tint(isSet ? nil : Color.secondary)
        .sensoryFeedback(.success, trigger: isSet)
    }
}
