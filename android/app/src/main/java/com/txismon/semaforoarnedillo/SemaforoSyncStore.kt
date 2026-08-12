package com.txismon.semaforoarnedillo

import android.content.Context

/**
 * Equivalente a SemaforoSyncStore.swift: guarda localmente el instante de
 * referencia (greenStartTime) de cada sentido. No depende de ningún backend
 * ni requiere inicio de sesión.
 */
object SemaforoSyncStore {

    private const val PREFS = "semaforo_sync"

    private fun timeKey(direction: Direction) = "green_start_ms_${direction.key}"
    private fun syncedAtKey(direction: Direction) = "green_start_synced_at_${direction.key}"

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /**
     * Instante de referencia (epoch ms) en que el sentido dado estaba en verde.
     * Si nunca se ha sincronizado en este dispositivo, usa el momento actual
     * como arranque provisional para que la app funcione desde el primer uso.
     */
    fun greenStartTimeMs(context: Context, direction: Direction): Double {
        val p = prefs(context)
        val key = timeKey(direction)
        val stored = p.getLong(key, 0L)
        if (stored > 0L) return stored.toDouble()

        val now = System.currentTimeMillis()
        p.edit().putLong(key, now).apply()
        return now.toDouble()
    }

    /** Epoch ms de la última sincronización manual, o null si nunca se hizo. */
    fun lastSyncedAt(context: Context, direction: Direction): Long? {
        val raw = prefs(context).getLong(syncedAtKey(direction), 0L)
        return if (raw > 0L) raw else null
    }

    /** Marca [atMillis] como el instante en que el sentido dado se puso en verde. */
    fun sync(
        context: Context,
        direction: Direction,
        atMillis: Long = System.currentTimeMillis()
    ) {
        prefs(context).edit()
            .putLong(timeKey(direction), atMillis)
            .putLong(syncedAtKey(direction), atMillis)
            .apply()
    }
}
