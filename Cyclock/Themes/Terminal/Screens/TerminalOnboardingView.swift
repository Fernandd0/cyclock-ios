import SwiftUI

/// Shown once, on first launch: asks for the usual wake-up time and the sleep goal.
struct TerminalOnboardingView: View {
    @AppStorage(Prefs.didOnboard) private var didOnboard = false
    private var schedule = SleepSchedule()

    var body: some View {
        let bedtime = schedule.bedtime

        Screen(comment: Comment("primera vez por aquí"), title: "cyclock") {
            VStack(alignment: .leading, spacing: 0) {
                Comment("¿a qué hora despiertas normalmente?")
                DatePicker("Hora de despertar", selection: schedule.wakeBinding, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 0) {
                Comment("¿cuántos ciclos de 90 min quieres dormir?")
                GoalPicker(goalCycles: schedule.cyclesBinding)
                Comment(SleepCopy.goalSummary(cycles: schedule.cycles))
            }

            DashedRule()

            VStack(alignment: .leading, spacing: 0) {
                KeyValue(key: "dormir") {
                    Text(verbatim: bedtime.clock)
                        .foregroundStyle(Color.codeGreen)
                        .glow(.codeGreen)
                }
                BracketButton("empezar") {
                    didOnboard = true
                }
                Comment("luego puedes cambiarlo en ajustes")
            }
        }
    }
}
