import SwiftUI

/// `[4] [5] [6] ciclos` selector, shared by onboarding and settings.
struct GoalPicker: View {
    @Binding var goalCycles: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(CycleOptions.goal, id: \.self) { cycles in
                BracketButton(Text(verbatim: "\(cycles)"), color: .codeBlue, isSelected: goalCycles == cycles) {
                    goalCycles = cycles
                }
            }
            Text("ciclos")
                .foregroundStyle(Color.dim)
        }
    }
}
