package com.txismon.semaforoarnedillo

/**
 * Equivalente a SemaforoActivityAttributes.Direction de la app iOS.
 */
enum class Direction(
    val key: String,
    val origin: String,
    val destination: String
) {
    ENTRADA("entrada", "Arnedo", "Arnedillo"),
    SALIDA("salida", "Arnedillo", "Arnedo");

    val title: String
        get() = "$origin → $destination"

    companion object {
        fun fromKey(key: String?): Direction =
            values().firstOrNull { it.key == key } ?: SALIDA
    }
}
