import Foundation
import ActivityKit

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published var errorMessage: String?
    @Published private(set) var isActive = false

    func restore() {
        isActive = !Activity<SemaforoActivityAttributes>.activities.isEmpty
    }

    func start(direction: SemaforoActivityAttributes.Direction) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            errorMessage = "Activa Live Activities para esta app en Ajustes."
            return
        }

        await stop()

        let start = SemaforoSyncStore.greenStartTimeMs(for: direction)
        let attrs = SemaforoActivityAttributes(direction: direction)
        let state = SemaforoActivityAttributes.ContentState(
            greenStartTimeMs: start,
            syncedAt: Date()
        )
        let content = ActivityContent(
            state: state,
            staleDate: Date().addingTimeInterval(1800)
        )

        do {
            _ = try Activity<SemaforoActivityAttributes>.request(
                attributes: attrs,
                content: content,
                pushType: nil
            )
            isActive = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        guard let activity = Activity<SemaforoActivityAttributes>.activities.first else {
            isActive = false
            return
        }
        let start = SemaforoSyncStore.greenStartTimeMs(for: activity.attributes.direction)
        let state = SemaforoActivityAttributes.ContentState(
            greenStartTimeMs: start,
            syncedAt: Date()
        )
        await activity.update(
            ActivityContent(
                state: state,
                staleDate: Date().addingTimeInterval(1800)
            )
        )
        isActive = true
    }

    func stop() async {
        for activity in Activity<SemaforoActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        isActive = false
    }
}
