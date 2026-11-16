import SwiftUI

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
