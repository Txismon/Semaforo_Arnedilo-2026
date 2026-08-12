import ActivityKit
import WidgetKit
import SwiftUI

struct SemaforoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SemaforoActivityAttributes.self) { context in
            HStack(spacing: 12) {
                PhaseView(
                    start: context.state.greenStartTimeMs,
                    large: true
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.direction.title)
                        .font(.headline)
                        .foregroundStyle(.white)

                    StatusView(
                        start: context.state.greenStartTimeMs,
                        forceWhiteText: true
                    )
                }

                Spacer(minLength: 0)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.92))
            .activitySystemActionForegroundColor(.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.direction.origin)
                        .font(.caption.bold())
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.direction.destination)
                        .font(.caption.bold())
                }

                DynamicIslandExpandedRegion(.center) {
                    StatusView(
                        start: context.state.greenStartTimeMs,
                        forceWhiteText: false
                    )
                }

            } compactLeading: {
                PhaseView(
                    start: context.state.greenStartTimeMs,
                    large: false
                )

            } compactTrailing: {
                CountdownView(
                    start: context.state.greenStartTimeMs
                )

            } minimal: {
                PhaseView(
                    start: context.state.greenStartTimeMs,
                    large: false
                )
            }
        }
    }
}

private struct PhaseView: View {
    let start: Double
    let large: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let snapshot = SemaforoEngine.snapshot(
                at: timeline.date,
                greenStartTimeMs: start
            )

            Text(snapshot.phase.symbol)
                .font(large ? .system(size: 34) : .body)
                .accessibilityLabel(snapshot.phase.label)
        }
    }
}

private struct CountdownView: View {
    let start: Double

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let snapshot = SemaforoEngine.snapshot(
                at: timeline.date,
                greenStartTimeMs: start
            )

            Text(snapshot.countdownText)
                .font(.system(.caption, design: .monospaced).bold())
        }
    }
}

private struct StatusView: View {
    let start: Double
    let forceWhiteText: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let snapshot = SemaforoEngine.snapshot(
                at: timeline.date,
                greenStartTimeMs: start
            )

            HStack(spacing: 7) {
                Text(snapshot.phase.label)
                    .bold()
                    .foregroundStyle(phaseColor(snapshot.phase))

                Text(snapshot.countdownText)
                    .font(.system(.body, design: .monospaced).bold())
                    .foregroundStyle(forceWhiteText ? Color.white : Color.primary)
            }
        }
    }

    private func phaseColor(_ phase: TrafficPhase) -> Color {
        switch phase {
        case .green:
            return .green
        case .amber:
            return .yellow
        case .red:
            return .red
        }
    }
}

@main
struct SemaforoWidgets: WidgetBundle {
    var body: some Widget {
        SemaforoLiveActivity()
    }
}
