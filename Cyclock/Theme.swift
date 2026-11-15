import SwiftUI

nonisolated extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// Terminal-style palette: a dark set and its inverted (light) counterpart.
nonisolated extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    /// Background.
    static let ink = Color(light: 0xD5D5D5, dark: 0x1A1A1A)
    /// Main text.
    static let paper = Color(light: 0x2A2830, dark: 0xE1E1E1)
    /// Comments and secondary text.
    static let dim = Color(light: 0x7E7E7E, dark: 0x898989)

    static let codePurple = Color(light: 0x6B1FA3, dark: 0xB462FF)
    static let codeFuchsia = Color(light: 0xF50777, dark: 0xFF45B4)
    static let codeBlue = Color(light: 0x0B8CFF, dark: 0x18B6FF)
    static let codeGreen = Color(light: 0x00A76C, dark: 0x1BEB9E)
    static let codeOrange = Color(light: 0xDD7200, dark: 0xFF9528)
    static let codeYellow = Color(light: 0x949700, dark: 0xDDDD25)
}

extension Font {
    /// Monospaced system font that still follows Dynamic Type.
    static func mono(_ style: Font.TextStyle = .body, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .monospaced, weight: weight)
    }
}

extension View {
    /// Soft glow behind text, like a CRT.
    func glow(_ color: Color) -> some View {
        shadow(color: color.opacity(0.45), radius: 6)
    }
}

/// Grey `// comment` line.
struct Comment: View {
    let text: Text

    init(_ key: LocalizedStringKey) {
        text = Text(key)
    }

    init(verbatim: String) {
        text = Text(verbatim: verbatim)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: "// ")
            text
        }
        .font(.mono(.footnote))
        .foregroundStyle(Color.dim)
        .fixedSize(horizontal: false, vertical: true)
    }
}

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

/// A row of links that stacks vertically when it does not fit (large text sizes).
struct LinkRow<Content: View>: View {
    var spacing: CGFloat = 14
    @ViewBuilder let content: Content

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: spacing) { content }
            VStack(alignment: .leading, spacing: 0) { content }
        }
    }
}

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

/// `key: value` line. The key column scales with the text size, and the value drops below the key
/// when both do not fit on one line.
struct KeyValue<Value: View>: View {
    let key: LocalizedStringKey
    @ViewBuilder let value: Value

    @ScaledMetric(relativeTo: .body) private var keyWidth: CGFloat = 112

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                keyLabel.frame(width: keyWidth, alignment: .leading)
                HStack(alignment: .firstTextBaseline, spacing: 0) { value }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack(alignment: .leading, spacing: 2) {
                keyLabel
                HStack(alignment: .firstTextBaseline, spacing: 0) { value }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var keyLabel: some View {
        HStack(spacing: 0) {
            Text(key)
            Text(verbatim: ":")
        }
        .lineLimit(1)
        .fixedSize()
        .foregroundStyle(Color.codeBlue)
    }
}

/// Scrolling page with a comment line and a big light title on top.
struct Screen<Content: View>: View {
    let comment: Comment
    let title: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 2) {
                    comment
                    Text(title)
                        .font(.mono(.largeTitle, weight: .ultraLight))
                        .foregroundStyle(Color.codePurple)
                        .glow(.codePurple)
                }
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 76)
        }
        .scrollIndicators(.hidden)
    }
}

/// One result line: `05: 11:16 p. m.` with a small note underneath and an alarm link on the right.
/// When `detail` is given the note ends with `+` / `-` to show the row expands.
struct TimeRow: View {
    let index: String
    let time: Date
    var hours: String?
    let tag: LocalizedStringKey
    var tagColor: Color = .dim
    var highlighted = false
    var detail: LocalizedStringKey?
    var isExpanded = false
    let kind: AlarmKind

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    indexLabel
                    summary
                    Spacer(minLength: 4)
                    SetAlarmButton(date: time, kind: kind)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        indexLabel
                        summary
                    }
                    SetAlarmButton(date: time, kind: kind)
                }
            }
            if isExpanded, let detail {
                Comment(detail)
                    .padding(.leading, 4)
            }
        }
    }

    private var indexLabel: some View {
        Text(verbatim: index + ":")
            .foregroundStyle(Color.codeOrange)
    }

    /// The alarm would ring tomorrow, not later today.
    private var isTomorrow: Bool {
        !Calendar.current.isDateInToday(SleepMath.nextOccurrence(of: time))
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: time.clock)
                    .font(.mono(.title2, weight: .light))
                    .foregroundStyle(highlighted ? Color.codeGreen : Color.paper)
                    .glow(highlighted ? .codeGreen : .clear)
                if isTomorrow {
                    Text("mañana")
                        .font(.mono(.caption))
                        .foregroundStyle(Color.dim)
                }
            }
            HStack(spacing: 0) {
                if let hours {
                    Text(verbatim: "\(hours) h · ")
                        .foregroundStyle(Color.dim)
                }
                Text(tag)
                    .foregroundStyle(tagColor)
                if detail != nil {
                    Text(verbatim: isExpanded ? " -" : " +")
                        .foregroundStyle(Color.codeOrange)
                }
            }
            .font(.mono(.caption))
        }
        .lineLimit(1)
        .fixedSize()
    }
}
