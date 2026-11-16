import SwiftUI

/// `[alarma]` link used on every result row; drawn as a solid green block once the alarm is set.
struct SetAlarmButton: View {
    let date: Date
    let kind: AlarmKind

    @Environment(AlarmService.self) private var alarms

    var body: some View {
        let isSet = alarms.isSet(date)

        BracketButton(isSet ? "✓ alarma" : "alarma", color: isSet ? .codeGreen : .codeBlue, isSelected: isSet) {
            Task { await alarms.toggle(at: date, kind: kind) }
        }
        .font(.mono(.subheadline))
        .sensoryFeedback(.success, trigger: isSet)
    }
}
