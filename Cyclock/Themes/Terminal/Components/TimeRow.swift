import SwiftUI

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

    private var summary: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: time.clock)
                    .font(.mono(.title2, weight: .light))
                    .foregroundStyle(highlighted ? Color.codeGreen : Color.paper)
                    .glow(highlighted ? .codeGreen : .clear)
                if SleepMath.isTomorrow(time) {
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
