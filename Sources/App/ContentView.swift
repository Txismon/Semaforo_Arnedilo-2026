import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var activity = LiveActivityManager()
    @State private var direction: SemaforoActivityAttributes.Direction = .salida
    @State private var greenStartTimeMs: Double?

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
                    ProgressView("Leyendo semáforo…")
                        .frame(maxWidth: .infinity, minHeight: 250)
                }

                Button {
                    Task { await load() }
                } label: {
                    Label("Actualizar", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await activity.start(direction: direction)
                        await load()
                    }
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
                await load()
            }
            .onChange(of: direction) { _, _ in
                Task { await load() }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task {
                        await activity.refresh()
                        await load()
                    }
                }
            }
        }
    }

    private func load() async {
        do {
            greenStartTimeMs = try await Base44Service.shared.greenStartTime(for: direction)
            activity.errorMessage = nil
        } catch {
            activity.errorMessage = error.localizedDescription
        }
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
