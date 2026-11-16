import SwiftUI

/// Text link in brackets: `[title]`. When selected it is drawn inverted, as a solid block.
/// The tappable area is at least 44 pt tall even though the text is smaller.
struct BracketButton: View {
    let title: Text
    var color: Color = .codeFuchsia
    var isSelected = false
    let action: () -> Void

    init(_ key: LocalizedStringKey, color: Color = .codeFuchsia, isSelected: Bool = false, action: @escaping () -> Void) {
        self.init(Text(key), color: color, isSelected: isSelected, action: action)
    }

    init(_ title: Text, color: Color = .codeFuchsia, isSelected: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text(verbatim: "[")
                title
                Text(verbatim: "]")
            }
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(isSelected ? Color.ink : color)
            .background(isSelected ? color : .clear)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
