import SwiftUI

/// List row for one time: big time, a line of context under it and the alarm button at the end.
struct MinimalTimeRow: View {
    let time: Date
    let subtitle: Text
    var tag: LocalizedStringKey?
    var tagColor: Color = .secondary
    var detail: LocalizedStringKey?
    /// Adds "Mañana" next to the time when it falls on the next day.
    var showsDay = true
    let kind: AlarmKind

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(verbatim: time.clock)
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                    if showsDay && SleepMath.isTomorrow(time) {
                        Text("Mañana")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                subtitleLine
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let detail {
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
            Spacer(minLength: 0)
            MinimalAlarmButton(date: time, kind: kind)
        }
        .accessibilityElement(children: .combine)
    }

    private var subtitleLine: Text {
        guard let tag else { return subtitle }
        return Text("\(subtitle) · \(Text(tag).foregroundStyle(tagColor).fontWeight(.medium))")
    }
}

extension MinimalTimeRow {
    /// Row for a night of `cycles` cycles: "7.5 h · 5 ciclos" plus an optional tag.
    init(
        time: Date,
        cycles: Int,
        tag: LocalizedStringKey? = nil,
        tagColor: Color = .secondary,
        detail: LocalizedStringKey? = nil,
        kind: AlarmKind
    ) {
        self.init(
            time: time,
            subtitle: Text("\(SleepMath.hoursText(cycles: cycles)) h · \(cycles) ciclos"),
            tag: tag,
            tagColor: tagColor,
            detail: detail,
            kind: kind
        )
    }
}
