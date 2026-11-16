import SwiftUI

/// Dashed horizontal separator.
struct DashedRule: View {
    var body: some View {
        HorizontalLine()
            .stroke(Color.dim.opacity(0.7), style: StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
            .frame(height: 1.5)
            .accessibilityHidden(true)
    }
}

private nonisolated struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
