import SwiftUI

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
