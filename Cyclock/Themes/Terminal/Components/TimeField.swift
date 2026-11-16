import SwiftUI

/// Editable time shown as a link, e.g. `[7:00 a. m.]`; tapping it opens a wheel picker.
struct TimeField: View {
    let label: LocalizedStringKey
    @Binding var time: Date
    @State private var isEditing = false

    var body: some View {
        BracketButton(Text(verbatim: time.clock), color: .codeYellow) {
            isEditing = true
        }
        .accessibilityLabel(label)
        .accessibilityValue(time.clock)
        .sheet(isPresented: $isEditing) {
            VStack(spacing: 4) {
                DatePicker(label, selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                BracketButton("listo") { isEditing = false }
            }
            .font(.mono())
            .padding(20)
            .presentationDetents([.height(320)])
            .presentationBackground(Color.ink)
        }
    }
}
