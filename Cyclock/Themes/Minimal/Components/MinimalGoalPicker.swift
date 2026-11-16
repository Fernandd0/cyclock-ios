import SwiftUI

/// Picker for the sleep goal in cycles. Use `.pickerStyle` to choose how it is drawn.
struct MinimalGoalPicker: View {
    @Binding var cycles: Int
    /// Shows only the number ("5") instead of "5 ciclos"; for segmented pickers.
    var compact = false

    var body: some View {
        Picker("Meta", selection: $cycles) {
            ForEach(CycleOptions.goal, id: \.self) { option in
                if compact {
                    Text(verbatim: "\(option)").tag(option)
                } else {
                    Text("\(option) ciclos").tag(option)
                }
            }
        }
    }
}
