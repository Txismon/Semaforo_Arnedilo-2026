package com.txismon.semaforoarnedillo.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Button
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.txismon.semaforoarnedillo.Direction
import kotlinx.coroutines.delay
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

/**
 * Selector de sentido. Se usa Button/OutlinedButton en lugar de
 * SegmentedButton porque este último todavía es API experimental en
 * Material 3 y obligaría a añadir @OptIn en cada pantalla.
 */
@Composable
fun SelectorSentido(
    seleccionado: Direction,
    etiqueta: (Direction) -> String,
    onSeleccionar: (Direction) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Direction.values().forEach { item ->
            if (item == seleccionado) {
                Button(
                    onClick = { onSeleccionar(item) },
                    modifier = Modifier.weight(1f)
                ) {
                    Text(etiqueta(item))
                }
            } else {
                OutlinedButton(
                    onClick = { onSeleccionar(item) },
                    modifier = Modifier.weight(1f)
                ) {
                    Text(etiqueta(item))
                }
            }
        }
    }
}

/** Reloj que se refresca cada segundo para redibujar las cuentas atrás. */
@Composable
fun rememberNowMillis(): State<Long> {
    val now = remember { mutableLongStateOf(System.currentTimeMillis()) }
    LaunchedEffect(Unit) {
        while (true) {
            now.longValue = System.currentTimeMillis()
            delay(500)
        }
    }
    return now
}

private val horaCompleta: DateTimeFormatter =
    DateTimeFormatter.ofPattern("HH:mm:ss").withZone(ZoneId.systemDefault())

private val horaCorta: DateTimeFormatter =
    DateTimeFormatter.ofPattern("HH:mm").withZone(ZoneId.systemDefault())

private val fechaYHora: DateTimeFormatter =
    DateTimeFormatter.ofPattern("d MMM, HH:mm:ss").withZone(ZoneId.systemDefault())

fun formatHora(epochMillis: Long): String =
    horaCompleta.format(Instant.ofEpochMilli(epochMillis))

fun formatHoraCorta(epochMillis: Long): String =
    horaCorta.format(Instant.ofEpochMilli(epochMillis))

fun formatFechaYHora(epochMillis: Long): String =
    fechaYHora.format(Instant.ofEpochMilli(epochMillis))

/** "En 3m 20s", "En 1h 05m 02s". */
fun formatRelativo(targetMillis: Long, nowMillis: Long): String {
    val total = ((targetMillis - nowMillis) / 1000).coerceAtLeast(0L).toInt()

    if (total < 60) return "En ${total}s"

    val hours = total / 3600
    val minutes = (total % 3600) / 60
    val seconds = total % 60

    return if (hours > 0) "En ${hours}h ${minutes}m ${seconds}s"
    else "En ${minutes}m ${seconds}s"
}
