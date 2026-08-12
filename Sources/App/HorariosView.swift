import SwiftUI

struct HorariosView: View {
    private let horizon: TimeInterval = 2 * 60 * 60

    @State private var direction: SemaforoActivityAttributes.Direction
    @State private var greenStartTimeMs: Double?
    @State private var loadedAt: Date?
    @State private var errorMessage: String?
    @State private var isLoading = false

    init(initialDirection: SemaforoActivityAttributes.Direction) {
        _direction = State(initialValue: initialDirection)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                headerCard
                directionPicker
                routeCard

                if isLoading && greenStartTimeMs == nil {
                    ProgressView("Calculando horarios…")
                        .frame(maxWidth: .infinity, minHeight: 220)
                } else if let greenStartTimeMs {
                    scheduleContent(greenStartTimeMs: greenStartTimeMs)
                } else if let errorMessage {
                    errorCard(errorMessage)
                }
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await load()
        }
        .onChange(of: direction) { _, _ in
            Task { await load() }
        }
        .refreshable {
            await load()
        }
    }

    private var headerCard: some View {
        VStack(spacing: 5) {
            Text("Horarios")
                .font(.title2.bold())

            Text("Próximos cambios a verde")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var directionPicker: some View {
        Picker("Sentido", selection: $direction) {
            Text("ENTRADA")
                .tag(SemaforoActivityAttributes.Direction.entrada)

            Text("SALIDA")
                .tag(SemaforoActivityAttributes.Direction.salida)
        }
        .pickerStyle(.segmented)
        .padding(6)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var routeCard: some View {
        HStack {
            routePoint(
                title: direction.origin,
                subtitle: "ORIGEN",
                filled: true
            )

            Spacer(minLength: 12)

            HStack(spacing: 5) {
                ForEach(0..<5, id: \.self) { _ in
                    Capsule()
                        .fill(Color.green.opacity(0.35))
                        .frame(width: 9, height: 2)
                }

                Image(systemName: "arrow.right")
                    .foregroundStyle(.green)
            }

            Spacer(minLength: 12)

            routePoint(
                title: direction.destination,
                subtitle: "DESTINO",
                filled: false
            )
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func routePoint(
        title: String,
        subtitle: String,
        filled: Bool
    ) -> some View {
        VStack(spacing: 5) {
            Circle()
                .fill(filled ? Color.green : Color.clear)
                .overlay(
                    Circle()
                        .stroke(Color.green, lineWidth: 3)
                )
                .frame(width: 14, height: 14)

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.caption2.bold())
                .tracking(1.4)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func scheduleContent(greenStartTimeMs: Double) -> some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let openings = SemaforoEngine.nextGreenStarts(
                from: timeline.date,
                greenStartTimeMs: greenStartTimeMs,
                horizon: horizon
            )

            VStack(spacing: 14) {
                summaryCard(now: timeline.date)

                if openings.isEmpty {
                    Text("No hay aperturas calculadas en las próximas 2 horas.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    ForEach(Array(openings.enumerated()), id: \.element) { index, opening in
                        OpeningRow(
                            opening: opening,
                            now: timeline.date,
                            isNext: index == 0
                        )
                    }
                }

                if let loadedAt {
                    HStack(spacing: 9) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(.green)

                        Text("Sincronizado a las \(loadedAt.formatted(date: .omitted, time: .standard))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }

    private func summaryCard(now: Date) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "clock")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text("Próximos verdes")
                    .font(.headline)
                    .foregroundStyle(.green)

                Text("Desde ahora hasta \(now.addingTimeInterval(horizon).formatted(date: .omitted, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("2 h")
                .font(.subheadline.bold())
                .foregroundStyle(.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.10))
                .clipShape(Capsule())
        }
        .padding(18)
        .background(Color.green.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.green.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)

            Text("No se pudieron cargar los horarios")
                .font(.headline)

            Text(message)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Reintentar") {
                Task { await load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    @MainActor
    private func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            greenStartTimeMs = try await Base44Service.shared.greenStartTime(for: direction)
            loadedAt = Date()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            if greenStartTimeMs == nil {
                loadedAt = nil
            }
        }
    }
}

private struct OpeningRow: View {
    let opening: Date
    let now: Date
    let isNext: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: isNext ? "trafficlight.fill" : "clock")
                .font(.title3)
                .foregroundStyle(isNext ? .white : .secondary)
                .frame(width: 46, height: 46)
                .background(isNext ? Color.green : Color(uiColor: .tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                if isNext {
                    Text("Próximo cambio a verde")
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                Text(opening.formatted(date: .omitted, time: .standard))
                    .font(.system(.title3, design: .monospaced).weight(.semibold))

                Text(relativeText)
                    .font(.subheadline)
                    .foregroundStyle(isNext ? .green : .secondary)
            }

            Spacer()

            if isNext {
                Text("PRÓXIMO")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(
            isNext
                ? Color.green.opacity(0.07)
                : Color(uiColor: .secondarySystemGroupedBackground)
        )
        .overlay {
            if isNext {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 1.5)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var relativeText: String {
        let totalSeconds = max(0, Int(opening.timeIntervalSince(now).rounded(.down)))

        if totalSeconds < 60 {
            return "En \(totalSeconds)s"
        }

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "En \(hours)h \(minutes)m \(seconds)s"
        }

        return "En \(minutes)m \(seconds)s"
    }
}
