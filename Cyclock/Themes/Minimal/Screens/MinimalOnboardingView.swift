import SwiftUI

/// Shown once, on first launch: asks for the usual wake-up time and the sleep goal.
struct MinimalOnboardingView: View {
    @AppStorage(Prefs.didOnboard) private var didOnboard = false
    private var schedule = SleepSchedule()

    var body: some View {
        Form {
            Section {
                hero
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }

            Section {
                DatePicker("Hora de despertar", selection: schedule.wakeBinding, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            } header: {
                Text("¿A qué hora despiertas normalmente?")
            }

            Section {
                MinimalGoalPicker(cycles: schedule.cyclesBinding, compact: true)
                    .pickerStyle(.segmented)
                    .labelsHidden()
            } header: {
                Text("¿Cuántos ciclos de 90 min quieres dormir?")
            } footer: {
                Text(SleepCopy.goalSummary(cycles: schedule.cycles))
            }

            Section {
                LabeledContent("Hora de dormir", value: schedule.bedtime.clock)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) { startBar }
    }

    private var hero: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text(verbatim: "Cyclock")
                .font(.largeTitle.bold())
            Text("Duerme por ciclos, despierta descansado.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var startBar: some View {
        VStack(spacing: 8) {
            Button {
                didOnboard = true
            } label: {
                Text("Empezar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Text("Luego puedes cambiarlo en Ajustes.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
    }
}
