import SwiftUI

/// Sleep goal, appearance and the sleep-science FAQ. Everything is stored on device.
struct TerminalSettingsView: View {
    @Environment(\.openURL) private var openURL
    @AppStorage(Prefs.theme) private var appearance = AppearanceMode.system
    @AppStorage(Prefs.style) private var style = AppStyle.minimal
    @State private var openFAQ: Int?
    private var schedule = SleepSchedule()

    var body: some View {
        Screen(comment: Comment("todo se guarda en tu iPhone"), title: "ajustes") {
            VStack(alignment: .leading, spacing: 0) {
                KeyValue(key: "meta") {
                    GoalPicker(goalCycles: schedule.cyclesBinding)
                }
                KeyValue(key: "despertar") {
                    TimeField(label: "Hora de despertar", time: schedule.wakeBinding)
                }
                Comment(SleepCopy.goalSummary(cycles: schedule.cycles))
                    .padding(.top, 6)
            }

            DashedRule()

            VStack(alignment: .leading, spacing: 0) {
                KeyValue(key: "tema") {
                    LinkRow(spacing: 12) {
                        ForEach(AppStyle.allCases) { option in
                            BracketButton(option.terminalName, color: .codeBlue, isSelected: style == option) {
                                style = option
                            }
                        }
                    }
                    .font(.mono(.subheadline))
                }
                KeyValue(key: "modo") {
                    LinkRow(spacing: 12) {
                        ForEach([AppearanceMode.dark, .light, .system]) { option in
                            BracketButton(option.terminalName, color: .codeBlue, isSelected: appearance == option) {
                                appearance = option
                            }
                        }
                    }
                    .font(.mono(.subheadline))
                }
                KeyValue(key: "idioma") {
                    BracketButton("cambiar en iOS", color: .codeBlue) {
                        openURL.openAppSettings()
                    }
                    .font(.mono(.subheadline))
                }
            }

            DashedRule()

            VStack(alignment: .leading, spacing: 4) {
                Comment("ciencia del sueño")
                    .padding(.bottom, 6)
                ForEach(SleepCopy.faqs) { faq in
                    faqRow(faq)
                }
            }
        }
    }

    private func faqRow(_ faq: SleepCopy.FAQ) -> some View {
        let isOpen = openFAQ == faq.id

        return Button {
            withAnimation(.snappy) { openFAQ = isOpen ? nil : faq.id }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(verbatim: isOpen ? "-" : "+")
                        .foregroundStyle(Color.codeOrange)
                    Text(faq.question)
                        .foregroundStyle(isOpen ? Color.codeYellow : Color.paper)
                        .multilineTextAlignment(.leading)
                }
                .font(.mono(.subheadline))
                if isOpen {
                    Text(faq.answer)
                        .font(.mono(.footnote))
                        .foregroundStyle(Color.dim)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 18)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
