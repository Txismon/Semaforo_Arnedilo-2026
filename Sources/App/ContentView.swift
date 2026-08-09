import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var activity = LiveActivityManager()
    @State private var direction: SemaforoActivityAttributes.Direction = .salida
    @State private var greenStartTimeMs: Double?
    @State private var lastSyncedAt: Date?

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                VStack(spacing: 5) {
                    Text("Semáforo Arnedillo")
                        .font(.largeTitle.bold())
                    Text("Contador para iPhone y CarPlay")
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)

                Picker("Sentido", selection: $direction) {
                    ForEach(SemaforoActivityAttributes.Direction.allCases) {
                        Text($0.title).tag($0)
                    }
                }
                .pickerStyle(.segmented)

                if let greenStartTimeMs {
                    PhoneTrafficView(greenStartTimeMs: greenStartTimeMs)
                        .frame(maxWidth: .infinity, minHeight: 250)
                } else {
                    ProgressView("Cargando…")
                        .frame(maxWidth: .infinity, minHeight: 250)
                }

                if let lastSyncedAt {
                    Text("Última sincronización: \(lastSyncedAt.formatted(date: .abbreviated, time: .standard))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Sin sincronizar todavía en este dispositivo")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Button {
                    sync()
                } label: {
                    Label("Sincronizar (pulsa justo al ponerse verde)", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task { await activity.start(direction: direction) }
                } label: {
                    Label("Mostrar en CarPlay", systemImage: "car.side")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if activity.isActive {
                    Button("Detener Live Activity", role: .destructive) {
                        Task { await activity.stop() }
                    }
                }

                if let error = activity.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .task {
                activity.restore()
                load()
            }
            .onChange(of: direction) { _, _ in
                load()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    load()
                    Task { await activity.refresh() }
                }
            }
        }
    }

    private func load() {
        greenStartTimeMs = SemaforoSyncStore.greenStartTimeMs(for: direction)
        lastSyncedAt = SemaforoSyncStore.lastSyncedAt(for: direction)
    }

    private func sync() {
        SemaforoSyncStore.sync(direction: direction)
        load()
        Task { await activity.refresh() }
    }
}

private struct PhoneTrafficView: View {
    let greenStartTimeMs: Double

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let s = SemaforoEngine.snapshot(at: timeline.date, greenStartTimeMs: greenStartTimeMs)
            VStack(spacing: 9) {
                Text(s.phase.symbol).font(.system(size: 74))
                Text(s.phase.label).font(.title2.bold())
                Text(s.countdownText)
                    .font(.system(size: 54, weight: .bold, design: .monospaced))
                Text(s.subtitle).foregroundStyle(.secondary)
            }
        }
    }
}
