import SwiftUI

/// Shown once, on first launch: asks for the usual wake-up time and the sleep goal.
struct OnboardingView: View {
    @AppStorage(Prefs.didOnboard) private var didOnboard = false
    @AppStorage(Prefs.goalCycles) private var goalCycles = 5
    @AppStorage(Prefs.wakeMinutes) private var wakeMinutes = 420

    private var wakeTime: Binding<Date> {
        Binding(
            get: { SleepMath.today(minutes: wakeMinutes) },
            set: { wakeMinutes = SleepMath.minutesSinceMidnight($0) }
        )
    }

    var body: some View {
        let bedtime = SleepMath.bedtime(wakingAt: SleepMath.today(minutes: wakeMinutes), cycles: goalCycles)

        Screen(comment: Comment("primera vez por aquí"), title: "cyclock") {
            VStack(alignment: .leading, spacing: 0) {
                Comment("¿a qué hora despiertas normalmente?")
                DatePicker("Hora de despertar", selection: wakeTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 0) {
                Comment("¿cuántos ciclos de 90 min quieres dormir?")
                GoalPicker(goalCycles: $goalCycles)
                Comment("\(goalCycles) ciclos = \(SleepMath.hoursText(cycles: goalCycles)) h de sueño. 5 es lo recomendado.")
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

/// `[4] [5] [6] ciclos` selector, shared by onboarding and settings.
struct GoalPicker: View {
    @Binding var goalCycles: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach([4, 5, 6], id: \.self) { cycles in
                BracketButton(Text(verbatim: "\(cycles)"), color: .codeBlue, isSelected: goalCycles == cycles) {
                    goalCycles = cycles
                }
            }
            Text("ciclos")
                .foregroundStyle(Color.dim)
        }
    }
}
