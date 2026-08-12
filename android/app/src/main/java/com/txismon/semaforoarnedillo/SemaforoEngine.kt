package com.txismon.semaforoarnedillo

import kotlin.math.ceil

enum class TrafficPhase(val label: String, val symbol: String) {
    GREEN("VERDE", "🟢"),
    AMBER("ÁMBAR", "🟡"),
    RED("ROJO", "🔴");

    val subtitle: String
        get() = when (this) {
            GREEN -> "tiempo de paso"
            AMBER -> "cambio a rojo"
            RED -> "hasta próximo verde"
        }
}

data class SemaforoSnapshot(
    val phase: TrafficPhase,
    val remainingSeconds: Double
) {
    val countdownText: String
        get() {
            val total = remainingSeconds.coerceAtLeast(0.0).toInt()
            return "%02d:%02d".format(total / 60, total % 60)
        }

    val remainingMillis: Long
        get() = (remainingSeconds.coerceAtLeast(0.0) * 1000).toLong()
}

/**
 * Réplica exacta del motor de la app iOS (Sources/Shared/SemaforoEngine.swift).
 * Ciclo fijo: 67 s verde + 3 s ámbar + 590,03 s rojo = 660,03 s.
 * Todo el cálculo es local: no hay red ni backend.
 */
object SemaforoEngine {

    const val GREEN_DURATION = 67.0
    const val AMBER_DURATION = 3.0
    const val RED_DURATION = 590.03
    const val CYCLE_DURATION = GREEN_DURATION + AMBER_DURATION + RED_DURATION

    fun snapshot(nowMillis: Long, greenStartTimeMs: Double): SemaforoSnapshot {
        var elapsed = (nowMillis / 1000.0) - (greenStartTimeMs / 1000.0)
        elapsed %= CYCLE_DURATION

        if (elapsed < 0) {
            elapsed += CYCLE_DURATION
        }

        if (elapsed < GREEN_DURATION) {
            return SemaforoSnapshot(TrafficPhase.GREEN, GREEN_DURATION - elapsed)
        }

        if (elapsed < GREEN_DURATION + AMBER_DURATION) {
            return SemaforoSnapshot(TrafficPhase.AMBER, GREEN_DURATION + AMBER_DURATION - elapsed)
        }

        return SemaforoSnapshot(TrafficPhase.RED, CYCLE_DURATION - elapsed)
    }

    /**
     * Instantes (epoch ms) de inicio de verde entre [fromMillis] y [fromMillis] + [horizonSeconds].
     */
    fun nextGreenStarts(
        fromMillis: Long,
        greenStartTimeMs: Double,
        horizonSeconds: Double
    ): List<Long> {
        if (horizonSeconds <= 0) return emptyList()

        val reference = greenStartTimeMs / 1000.0
        val now = fromMillis / 1000.0
        val end = now + horizonSeconds

        var cycleIndex = ceil((now - reference) / CYCLE_DURATION)
        var firstStart = reference + cycleIndex * CYCLE_DURATION

        // Protección frente a errores de coma flotante en el instante exacto.
        if (firstStart < now - 0.001) {
            cycleIndex += 1
            firstStart = reference + cycleIndex * CYCLE_DURATION
        }

        val result = mutableListOf<Long>()
        var current = firstStart

        while (current <= end + 0.001) {
            result.add((current * 1000).toLong())
            current += CYCLE_DURATION
        }

        return result
    }
}
