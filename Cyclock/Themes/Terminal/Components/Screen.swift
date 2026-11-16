import SwiftUI

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
