import SwiftUI

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
