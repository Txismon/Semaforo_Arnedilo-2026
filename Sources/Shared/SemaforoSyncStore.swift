import Foundation

/// Guarda y lee localmente el instante de referencia (greenStartTime) de cada sentido.
/// Sustituye a Base44Service: no depende de ningún backend ni requiere login.
/// La calibración es local a cada dispositivo; se corrige pulsando "Sincronizar"
/// en el instante exacto en que el semáforo real se pone en verde.
enum SemaforoSyncStore {
    private static func timeKey(_ direction: SemaforoActivityAttributes.Direction) -> String {
        "GreenStartTimeMs_\(direction.rawValue)"
    }

    private static func syncedAtKey(_ direction: SemaforoActivityAttributes.Direction) -> String {
        "GreenStartTimeSyncedAt_\(direction.rawValue)"
    }

    /// Instante de referencia (ms desde 1970) en el que el sentido dado estaba en verde.
    /// Si nunca se ha sincronizado en este dispositivo, usa el momento actual como
    /// arranque provisional para que la app funcione desde el primer lanzamiento.
    static func greenStartTimeMs(for direction: SemaforoActivityAttributes.Direction) -> Double {
        let defaults = UserDefaults.standard
        let key = timeKey(direction)
        let stored = defaults.double(forKey: key)
        if stored > 0 { return stored }

        let now = Date().timeIntervalSince1970 * 1000
        defaults.set(now, forKey: key)
        return now
    }

    static func lastSyncedAt(for direction: SemaforoActivityAttributes.Direction) -> Date? {
        let raw = UserDefaults.standard.double(forKey: syncedAtKey(direction))
        return raw > 0 ? Date(timeIntervalSince1970: raw) : nil
    }

    /// Marca `date` (por defecto, ahora) como el instante en que el sentido dado se puso en verde.
    static func sync(direction: SemaforoActivityAttributes.Direction, at date: Date = Date()) {
        let defaults = UserDefaults.standard
        defaults.set(date.timeIntervalSince1970 * 1000, forKey: timeKey(direction))
        defaults.set(date.timeIntervalSince1970, forKey: syncedAtKey(direction))
    }
}
