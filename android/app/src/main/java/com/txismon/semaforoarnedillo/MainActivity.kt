package com.txismon.semaforoarnedillo

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import com.txismon.semaforoarnedillo.service.SemaforoNotificationService
import com.txismon.semaforoarnedillo.ui.ContadorScreen
import com.txismon.semaforoarnedillo.ui.HorariosScreen
import com.txismon.semaforoarnedillo.ui.SemaforoTheme

private enum class Pantalla { CONTADOR, HORARIOS }

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            SemaforoTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    SemaforoApp()
                }
            }
        }
    }
}

@Composable
private fun SemaforoApp() {
    val context = LocalContext.current

    var pantalla by remember { mutableStateOf(Pantalla.CONTADOR) }
    var direction by remember { mutableStateOf(Direction.SALIDA) }
    var notificacionActiva by remember { mutableStateOf(false) }

    // Se recalculan al cambiar de sentido o tras sincronizar.
    var recarga by remember { mutableStateOf(0) }

    val greenStartTimeMs = remember(direction, recarga) {
        SemaforoSyncStore.greenStartTimeMs(context, direction)
    }
    val lastSyncedAt = remember(direction, recarga) {
        SemaforoSyncStore.lastSyncedAt(context, direction)
    }

    val iniciarNotificacion = {
        SemaforoNotificationService.start(context, direction)
        notificacionActiva = true
    }

    val permisoNotificaciones = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { concedido ->
        if (concedido) iniciarNotificacion()
    }

    when (pantalla) {
        Pantalla.CONTADOR -> ContadorScreen(
            direction = direction,
            greenStartTimeMs = greenStartTimeMs,
            lastSyncedAt = lastSyncedAt,
            notificacionActiva = notificacionActiva,
            onDirectionChange = { direction = it },
            onSync = {
                SemaforoSyncStore.sync(context, direction)
                recarga++
                if (notificacionActiva) {
                    SemaforoNotificationService.start(context, direction)
                }
            },
            onAbrirHorarios = { pantalla = Pantalla.HORARIOS },
            onIniciarNotificacion = {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.POST_NOTIFICATIONS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    permisoNotificaciones.launch(Manifest.permission.POST_NOTIFICATIONS)
                } else {
                    iniciarNotificacion()
                }
            },
            onDetenerNotificacion = {
                SemaforoNotificationService.stop(context)
                notificacionActiva = false
            }
        )

        Pantalla.HORARIOS -> HorariosScreen(
            direction = direction,
            greenStartTimeMs = greenStartTimeMs,
            lastSyncedAt = lastSyncedAt,
            onDirectionChange = { direction = it },
            onVolver = { pantalla = Pantalla.CONTADOR }
        )
    }
}
