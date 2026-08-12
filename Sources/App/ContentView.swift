import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var activity = LiveActivityManager()
    @State private var direction: SemaforoActivityAttributes.Direction = .salida
    @State private var greenStartTimeMs: Double?
    @State private var lastSyncedAt: Date?

    var body: some View {
        NavigationStack {
            ScrollView {
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

                    NavigationLink {
                        HorariosView(initialDirection: direction)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "clock")
                                .font(.title3.bold())
                                .frame(width: 34, height: 34)
                                .background(.green.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Horarios")
                                    .font(.headline)
                                Text("Próximos verdes · 2 horas")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)

                    VStack(spacing: 8) {
                        Button {
                            sync()
                        } label: {
                            Label(
                                "Sincronizar (pulsa al ponerse verde)",
                                systemImage: "checkmark.circle"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        if let lastSyncedAt {
                            Text("Última sincronización: \(lastSyncedAt.formatted(date: .abbreviated, time: .standard))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Sin sincronizar todavía en este dispositivo")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

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
                }
                .padding()
            }
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
            let snapshot = SemaforoEngine.snapshot(
                at: timeline.date,
                greenStartTimeMs: greenStartTimeMs
            )

            VStack(spacing: 9) {
                Text(snapshot.phase.symbol)
                    .font(.system(size: 74))

                Text(snapshot.phase.label)
                    .font(.title2.bold())

                Text(snapshot.countdownText)
                    .font(.system(size: 54, weight: .bold, design: .monospaced))

                Text(snapshot.subtitle)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
