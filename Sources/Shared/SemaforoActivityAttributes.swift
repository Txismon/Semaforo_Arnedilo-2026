import Foundation
import ActivityKit

struct SemaforoActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var greenStartTimeMs: Double
        var syncedAt: Date
    }

    enum Direction: String, Codable, Hashable, CaseIterable, Identifiable {
        case entrada
        case salida

        var id: String { rawValue }

        var origin: String {
            switch self {
            case .entrada: return "Arnedo"
            case .salida: return "Arnedillo"
            }
        }

        var destination: String {
            switch self {
            case .entrada: return "Arnedillo"
            case .salida: return "Arnedo"
            }
        }

        var title: String { "\(origin) → \(destination)" }
    }

    var direction: Direction
}
