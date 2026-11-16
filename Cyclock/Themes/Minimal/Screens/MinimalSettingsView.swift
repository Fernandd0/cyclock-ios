import SwiftUI

/// Sleep goal, appearance and the sleep-science FAQ. Everything is stored on device.
struct MinimalSettingsView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage(Prefs.style) private var style = AppStyle.minimal
    @AppStorage(Prefs.theme) private var appearance = AppearanceMode.system
    private var schedule = SleepSchedule()

    var body: some View {
        Form {
            sleepSection
            appearanceSection
            faqSection
        }
        .navigationTitle("Ajustes")
    }

    private var sleepSection: some View {
        Section {
            MinimalGoalPicker(cycles: schedule.cyclesBinding)
            DatePicker("Hora de despertar", selection: schedule.wakeBinding, displayedComponents: .hourAndMinute)
        } header: {
            Text("Sueño")
        } footer: {
            Text(SleepCopy.goalSummary(cycles: schedule.cycles))
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("Tema", selection: $style) {
                ForEach(AppStyle.allCases) { option in
                    Text(option.minimalName).tag(option)
                }
            }
            Picker("Modo", selection: $appearance) {
                ForEach(AppearanceMode.allCases) { option in
                    Text(option.minimalName).tag(option)
                }
            }
            Button {
                openURL.openAppSettings()
            } label: {
                LabeledContent("Idioma") {
                    Image(systemName: "arrow.up.forward")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.primary)
        } header: {
            Text("Apariencia")
        }
    }

    private var faqSection: some View {
        Section {
            ForEach(SleepCopy.faqs) { faq in
                DisclosureGroup {
                    Text(faq.answer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } label: {
                    Text(faq.question)
                }
            }
        } header: {
            Text("Ciencia del sueño")
        } footer: {
            Text("Todo se guarda en tu iPhone.")
        }
    }
}
