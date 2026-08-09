import ActivityKit
import WidgetKit
import SwiftUI

struct SemaforoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SemaforoActivityAttributes.self) { context in
            HStack(spacing: 12) {
                PhaseView(start: context.state.greenStartTimeMs, large: true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.direction.title)
                        .font(.headline)
                    StatusView(start: context.state.greenStartTimeMs)
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.direction.origin).font(.caption.bold())
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.direction.destination).font(.caption.bold())
                }
                DynamicIslandExpandedRegion(.center) {
                    StatusView(start: context.state.greenStartTimeMs)
                }
            } compactLeading: {
                PhaseView(start: context.state.greenStartTimeMs, large: false)
            } compactTrailing: {
                CountdownView(start: context.state.greenStartTimeMs)
            } minimal: {
                PhaseView(start: context.state.greenStartTimeMs, large: false)
            }
        }
    }
}

private struct PhaseView: View {
    let start: Double
    let large: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { t in
            let s = SemaforoEngine.snapshot(at: t.date, greenStartTimeMs: start)
            Text(s.phase.symbol)
                .font(large ? .system(size: 34) : .body)
        }
    }
}

private struct CountdownView: View {
    let start: Double

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { t in
            let s = SemaforoEngine.snapshot(at: t.date, greenStartTimeMs: start)
            Text(s.countdownText)
                .font(.system(.caption, design: .monospaced).bold())
        }
    }
}

private struct StatusView: View {
    let start: Double

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { t in
            let s = SemaforoEngine.snapshot(at: t.date, greenStartTimeMs: start)
            HStack(spacing: 7) {
                Text(s.phase.label).bold()
                Text(s.countdownText)
                    .font(.system(.body, design: .monospaced).bold())
            }
        }
    }
}

@main
struct SemaforoWidgets: WidgetBundle {
    var body: some Widget {
        SemaforoLiveActivity()
    }
}
