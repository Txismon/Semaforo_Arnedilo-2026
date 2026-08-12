package com.txismon.semaforoarnedillo.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.txismon.semaforoarnedillo.Direction
import com.txismon.semaforoarnedillo.SemaforoEngine

private const val HORIZON_SECONDS = 2.0 * 60 * 60

@Composable
fun HorariosScreen(
    direction: Direction,
    greenStartTimeMs: Double,
    lastSyncedAt: Long?,
    onDirectionChange: (Direction) -> Unit,
    onVolver: () -> Unit
) {
    val now by rememberNowMillis()
    val openings = SemaforoEngine.nextGreenStarts(now, greenStartTimeMs, HORIZON_SECONDS)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextButton(onClick = onVolver) { Text("‹  Volver") }
        }

        Card(modifier = Modifier.fillMaxWidth()) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 18.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = "Horarios",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = "Próximos cambios a verde",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        SelectorSentido(
            seleccionado = direction,
            etiqueta = { it.name },
            onSeleccionar = onDirectionChange
        )

        Card(modifier = Modifier.fillMaxWidth()) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 22.dp, vertical = 20.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                PuntoRuta(
                    titulo = direction.origin,
                    subtitulo = "ORIGEN",
                    modifier = Modifier.weight(1f)
                )
                Text(
                    text = "→",
                    fontSize = 22.sp,
                    color = VerdeMarca
                )
                PuntoRuta(
                    titulo = direction.destination,
                    subtitulo = "DESTINO",
                    modifier = Modifier.weight(1f)
                )
            }
        }

        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = VerdeMarca.copy(alpha = 0.08f)
            ),
            border = BorderStroke(1.dp, VerdeMarca.copy(alpha = 0.25f))
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(18.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Próximos verdes",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = VerdeMarca
                    )
                    Text(
                        text = "Desde ahora hasta " +
                            formatHoraCorta(now + (HORIZON_SECONDS * 1000).toLong()),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Text(
                    text = "2 h",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = VerdeMarca
                )
            }
        }

        if (openings.isEmpty()) {
            Card(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "No hay aperturas calculadas en las próximas 2 horas.",
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        } else {
            openings.forEachIndexed { index, opening ->
                FilaApertura(
                    openingMillis = opening,
                    nowMillis = now,
                    esProximo = index == 0
                )
            }
        }

        Card(modifier = Modifier.fillMaxWidth()) {
            Text(
                text = if (lastSyncedAt != null)
                    "Sincronizado a las ${formatHora(lastSyncedAt)}"
                else
                    "Sin sincronizar: usa «Sincronizar» en la pantalla principal",
                modifier = Modifier.padding(14.dp),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun PuntoRuta(
    titulo: String,
    subtitulo: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(
            text = titulo,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold
        )
        Text(
            text = subtitulo,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun FilaApertura(
    openingMillis: Long,
    nowMillis: Long,
    esProximo: Boolean
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = if (esProximo) VerdeMarca.copy(alpha = 0.10f)
            else MaterialTheme.colorScheme.surfaceVariant
        ),
        border = if (esProximo) BorderStroke(1.5.dp, VerdeMarca) else null
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                if (esProximo) {
                    Text(
                        text = "Próximo cambio a verde",
                        style = MaterialTheme.typography.labelMedium,
                        color = VerdeMarca
                    )
                }

                Text(
                    text = formatHora(openingMillis),
                    fontSize = 20.sp,
                    fontWeight = FontWeight.SemiBold,
                    fontFamily = FontFamily.Monospace
                )

                Text(
                    text = formatRelativo(openingMillis, nowMillis),
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (esProximo) VerdeMarca
                    else MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            if (esProximo) {
                Text(
                    text = "PRÓXIMO",
                    style = MaterialTheme.typography.labelMedium,
                    fontWeight = FontWeight.Bold,
                    color = VerdeMarca
                )
            }
        }
    }
}
