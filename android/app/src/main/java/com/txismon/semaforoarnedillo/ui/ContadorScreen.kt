package com.txismon.semaforoarnedillo.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
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

@Composable
fun ContadorScreen(
    direction: Direction,
    greenStartTimeMs: Double,
    lastSyncedAt: Long?,
    notificacionActiva: Boolean,
    onDirectionChange: (Direction) -> Unit,
    onSync: () -> Unit,
    onAbrirHorarios: () -> Unit,
    onIniciarNotificacion: () -> Unit,
    onDetenerNotificacion: () -> Unit
) {
    val now by rememberNowMillis()
    val snapshot = SemaforoEngine.snapshot(now, greenStartTimeMs)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(20.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(18.dp)
    ) {
        Text(
            text = "Semáforo Arnedillo",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center
        )

        Text(
            text = "Contador local, sin conexión",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )

        SelectorSentido(
            seleccionado = direction,
            etiqueta = { it.title },
            onSeleccionar = onDirectionChange
        )

        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = colorFor(snapshot.phase).copy(alpha = 0.10f)
            )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 28.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text(text = snapshot.phase.symbol, fontSize = 68.sp)

                Text(
                    text = snapshot.phase.label,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = colorFor(snapshot.phase)
                )

                Text(
                    text = snapshot.countdownText,
                    fontSize = 52.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Monospace
                )

                Text(
                    text = snapshot.phase.subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { onAbrirHorarios() }
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(18.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Horarios",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    Text(
                        text = "Próximos verdes · 2 horas",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Text(text = "›", fontSize = 24.sp)
            }
        }

        OutlinedButton(
            onClick = onSync,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Sincronizar (pulsa al ponerse verde)")
        }

        Text(
            text = if (lastSyncedAt != null)
                "Última sincronización: ${formatFechaYHora(lastSyncedAt)}"
            else
                "Sin sincronizar todavía en este dispositivo",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )

        if (notificacionActiva) {
            Button(
                onClick = onDetenerNotificacion,
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.errorContainer,
                    contentColor = MaterialTheme.colorScheme.onErrorContainer
                )
            ) {
                Text("Quitar de la pantalla de bloqueo")
            }
        } else {
            Button(
                onClick = onIniciarNotificacion,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Mostrar en la pantalla de bloqueo")
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "El tiempo mostrado es orientativo. Sincroniza delante del " +
                "semáforo para máxima precisión.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}
