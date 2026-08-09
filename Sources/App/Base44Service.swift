import Foundation

struct SemaforoStateRecord: Decodable {
    let id: String?
    let type: String
    let greenStartTime: Double
}

enum SemaforoAPIError: LocalizedError {
    case invalidResponse(Int)
    case missingDirection(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse(let status):
            return "Base44 devolvió HTTP \(status)."
        case .missingDirection(let direction):
            return "No se encontró el estado \(direction)."
        }
    }
}

actor Base44Service {
    static let shared = Base44Service()

    private let appId = "696116e9de1cc82c27fd72e0"
    private let origin = "https://semaforoarnedillo.base44.app/"

    func fetchStates() async throws -> [SemaforoStateRecord] {
        guard let url = URL(string:
            "https://semaforoarnedillo.base44.app/api/apps/\(appId)/entities/SemaforoState"
        ) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(appId, forHTTPHeaderField: "X-App-Id")
        request.setValue(origin, forHTTPHeaderField: "X-Origin-URL")

        let key = "Base44AnonymousID"
        let anonymousID: String
        if let existing = UserDefaults.standard.string(forKey: key) {
            anonymousID = existing
        } else {
            anonymousID = UUID().uuidString
            UserDefaults.standard.set(anonymousID, forKey: key)
        }
        request.setValue(anonymousID, forHTTPHeaderField: "X-Base44-Anonymous-Id")

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(status) else {
            throw SemaforoAPIError.invalidResponse(status)
        }
        return try JSONDecoder().decode([SemaforoStateRecord].self, from: data)
    }

    func greenStartTime(for direction: SemaforoActivityAttributes.Direction) async throws -> Double {
        let records = try await fetchStates()
        guard let match = records.first(where: { $0.type == direction.rawValue }) else {
            throw SemaforoAPIError.missingDirection(direction.rawValue)
        }
        return match.greenStartTime
    }
}
