package com.txismon.semaforoarnedillo.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.txismon.semaforoarnedillo.TrafficPhase

val VerdeSemaforo = Color(0xFF39E75F)
val AmbarSemaforo = Color(0xFFFFB830)
val RojoSemaforo = Color(0xFFFF3B3B)
val VerdeMarca = Color(0xFF52B788)

fun colorFor(phase: TrafficPhase): Color = when (phase) {
    TrafficPhase.GREEN -> VerdeSemaforo
    TrafficPhase.AMBER -> AmbarSemaforo
    TrafficPhase.RED -> RojoSemaforo
}

private val DarkColors = darkColorScheme(
    primary = VerdeMarca,
    secondary = VerdeMarca
)

private val LightColors = lightColorScheme(
    primary = VerdeMarca,
    secondary = VerdeMarca
)

@Composable
fun SemaforoTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) DarkColors else LightColors,
        content = content
    )
}
