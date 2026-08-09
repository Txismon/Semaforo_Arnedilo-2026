import Foundation

enum TrafficPhase: String {
    case green, amber, red

    var label: String {
        switch self {
        case .green: return "VERDE"
        case .amber: return "ÁMBAR"
        case .red: return "ROJO"
        }
    }

    var symbol: String {
        switch self {
        case .green: return "🟢"
        case .amber: return "🟡"
        case .red: return "🔴"
        }
    }
}

struct SemaforoSnapshot {
    let phase: TrafficPhase
    let remaining: TimeInterval

    var countdownText: String {
        let seconds = max(0, Int(remaining.rounded(.down)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var subtitle: String {
        switch phase {
        case .green: return "tiempo de paso"
        case .amber: return "cambio a rojo"
        case .red: return "hasta próximo verde"
        }
    }
}

enum SemaforoEngine {
    static let greenDuration: TimeInterval = 67
    static let amberDuration: TimeInterval = 3
    static let redDuration: TimeInterval = 590.03
    static let cycleDuration: TimeInterval = greenDuration + amberDuration + redDuration

    static func snapshot(at date: Date, greenStartTimeMs: Double) -> SemaforoSnapshot {
        var elapsed = date.timeIntervalSince1970 - (greenStartTimeMs / 1000)
        elapsed.formTruncatingRemainder(dividingBy: cycleDuration)
        if elapsed < 0 { elapsed += cycleDuration }

        if elapsed < greenDuration {
            return .init(phase: .green, remaining: greenDuration - elapsed)
        }
        if elapsed < greenDuration + amberDuration {
            return .init(phase: .amber, remaining: greenDuration + amberDuration - elapsed)
        }
        return .init(phase: .red, remaining: cycleDuration - elapsed)
    }
}
