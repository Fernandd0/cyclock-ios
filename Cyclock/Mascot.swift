import SwiftUI

/// Little pixel cat that stands on the navigation line. It blinks, wags its tail, hops and talks when
/// tapped, can be dragged around (it springs back), sleeps at night and reacts when alarms change.
struct Mascot: View {
    /// Smaller cat, used on the screens where it should stay out of the way.
    var compact = false

    @Environment(AlarmService.self) private var alarms

    @State private var phrase = 0
    @State private var speech: LocalizedStringKey?
    @State private var speechToken = 0
    @State private var awakeUntil = Date.distantPast
    @State private var hopping = false
    @State private var drag: CGSize = .zero

    private static let phrases: [LocalizedStringKey] = [
        "miau",
        "prrr…",
        "¿ya vas a dormir?",
        "5 ciclos y como nuevo",
        "no me toques la cola",
    ]

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
            let tick = Int(timeline.date.timeIntervalSinceReferenceDate * 2)
            let asleep = Self.isNight(timeline.date) && timeline.date > awakeUntil

            HStack(alignment: .bottom, spacing: 8) {
                Group {
                    if let speech {
                        Comment(speech)
                    } else if asleep {
                        Text(verbatim: ["z", "zZ", "zZz"][tick % 3])
                            .font(.mono(.footnote))
                            .foregroundStyle(Color.dim)
                    }
                }
                .padding(.bottom, compact ? 12 : 26)
                .allowsHitTesting(false)

                CatSprite(cell: compact ? 3 : 5, tailUp: !asleep && tick % 4 < 2, eyesClosed: asleep || tick % 9 == 0)
                    .offset(y: hopping ? -14 : 0)
                    .offset(drag)
                    .onTapGesture(perform: poke)
                    .gesture(
                        DragGesture()
                            .onChanged { drag = $0.translation }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.5)) { drag = .zero }
                            }
                    )
                    .sensoryFeedback(.impact(weight: .light), trigger: speechToken)
                    .accessibilityLabel("Gato")
                    .accessibilityAddTraits(.isButton)
            }
        }
        .onChange(of: alarms.event) { _, event in
            guard let event else { return }
            say(event.added ? "alarma lista. a dormir" : "alarma quitada")
            hop(times: event.added ? 2 : 1)
        }
    }

    private static func isNight(_ date: Date) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 22 || hour < 6
    }

    private func poke() {
        if Self.isNight(.now) && Date.now > awakeUntil {
            say("5 min más…")
        } else {
            phrase += 1
            say(Self.phrases[phrase % Self.phrases.count])
        }
        hop(times: 1)
    }

    /// Shows a line of speech for a few seconds; the cat stays awake while it talks.
    private func say(_ text: LocalizedStringKey) {
        speech = text
        speechToken += 1
        awakeUntil = Date.now.addingTimeInterval(5)
        let token = speechToken
        Task {
            try? await Task.sleep(for: .seconds(4))
            if token == speechToken {
                withAnimation(.easeOut(duration: 0.3)) { speech = nil }
            }
        }
    }

    private func hop(times: Int) {
        Task {
            for _ in 0..<times {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) { hopping = true }
                try? await Task.sleep(for: .milliseconds(160))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { hopping = false }
                try? await Task.sleep(for: .milliseconds(220))
            }
        }
    }
}

/// The cat itself, drawn as blocks on a 14x10 grid. Its feet are on the bottom edge.
private struct CatSprite: View {
    let cell: CGFloat
    let tailUp: Bool
    let eyesClosed: Bool

    // X body · o eye · n nose · T tail
    private static let tailUpRows = [
        "..X.....X.....",
        ".XXX...XXX....",
        ".XXXXXXXXX....",
        ".XXXXXXXXX....",
        ".XoXXXXXoX....",
        ".XXXXnXXXX..T.",
        ".XXXXXXXXX..T.",
        "..XXXXXXX...T.",
        "..XXXXXXX..TT.",
        "..XX...XXTTT..",
    ]

    private static let tailDownRows = [
        "..X.....X.....",
        ".XXX...XXX....",
        ".XXXXXXXXX....",
        ".XXXXXXXXX....",
        ".XoXXXXXoX....",
        ".XXXXnXXXX....",
        ".XXXXXXXXX....",
        "..XXXXXXX.....",
        "..XXXXXXX...TT",
        "..XX...XXTTTT.",
    ]

    var body: some View {
        Canvas { context, _ in
            for (y, row) in (tailUp ? Self.tailUpRows : Self.tailDownRows).enumerated() {
                for (x, symbol) in row.enumerated() where symbol != "." {
                    var rect = CGRect(x: CGFloat(x) * cell, y: CGFloat(y) * cell, width: cell, height: cell)
                    var color = Color.codeOrange
                    switch symbol {
                    case "o":
                        context.fill(Path(rect), with: .color(color))
                        color = .ink
                        if eyesClosed {
                            rect = rect.insetBy(dx: 0, dy: cell * 0.35)
                        }
                    case "n":
                        color = .codeFuchsia
                    case "T":
                        color = Color.codeOrange.opacity(0.75)
                    default:
                        break
                    }
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: cell * 14, height: cell * 10)
        .glow(.codeOrange)
        .contentShape(Rectangle())
    }
}
