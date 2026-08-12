package com.txismon.semaforoarnedillo.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.txismon.semaforoarnedillo.Direction
import com.txismon.semaforoarnedillo.MainActivity
import com.txismon.semaforoarnedillo.R
import com.txismon.semaforoarnedillo.SemaforoEngine
import com.txismon.semaforoarnedillo.SemaforoSyncStore
import com.txismon.semaforoarnedillo.TrafficPhase

/**
 * Equivalente en Android a la Live Activity de iOS: una notificación persistente
 * en la pantalla de bloqueo con la fase actual y una cuenta atrás.
 *
 * La cuenta atrás la dibuja el propio sistema mediante el cronómetro de la
 * notificación, así que solo hace falta reescribirla cuando cambia de fase
 * (cada 67 s, 3 s o 590 s) en lugar de cada segundo.
 */
class SemaforoNotificationService : Service() {

    companion object {
        const val ACTION_START = "com.txismon.semaforoarnedillo.START"
        const val ACTION_STOP = "com.txismon.semaforoarnedillo.STOP"
        const val EXTRA_DIRECTION = "direction"

        private const val CHANNEL_ID = "semaforo_estado"
        private const val NOTIFICATION_ID = 1001

        fun start(context: Context, direction: Direction) {
            val intent = Intent(context, SemaforoNotificationService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_DIRECTION, direction.key)
            }
            context.startForegroundService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, SemaforoNotificationService::class.java).apply {
                action = ACTION_STOP
            }
            context.startService(intent)
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var direction: Direction = Direction.SALIDA

    private val tick = object : Runnable {
        override fun run() {
            val delay = publish()
            handler.postDelayed(this, delay)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopSelf()
                return START_NOT_STICKY
            }

            else -> {
                direction = Direction.fromKey(intent?.getStringExtra(EXTRA_DIRECTION))
                handler.removeCallbacks(tick)
                handler.post(tick)
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(tick)
        super.onDestroy()
    }

    /**
     * Publica la notificación con el estado actual y devuelve dentro de cuántos
     * milisegundos hay que volver a publicarla (al terminar la fase en curso).
     */
    private fun publish(): Long {
        val greenStart = SemaforoSyncStore.greenStartTimeMs(this, direction)
        val snapshot = SemaforoEngine.snapshot(System.currentTimeMillis(), greenStart)

        val openIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_IMMUTABLE
        )

        val stopIntent = PendingIntent.getService(
            this,
            1,
            Intent(this, SemaforoNotificationService::class.java).apply {
                action = ACTION_STOP
            },
            PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_semaforo)
            .setContentTitle("${snapshot.phase.symbol}  ${snapshot.phase.label}")
            .setContentText("${direction.title} · ${snapshot.phase.subtitle}")
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setWhen(System.currentTimeMillis() + snapshot.remainingMillis)
            .setColor(colorFor(snapshot.phase))
            .setColorized(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(openIntent)
            .addAction(0, "Detener", stopIntent)
            .build()

        startForeground(NOTIFICATION_ID, notification)

        // Se reprograma justo al final de la fase, con un pequeño margen.
        return snapshot.remainingMillis.coerceAtLeast(1000L) + 120L
    }

    private fun colorFor(phase: TrafficPhase): Int = when (phase) {
        TrafficPhase.GREEN -> Color.parseColor("#39E75F")
        TrafficPhase.AMBER -> Color.parseColor("#FFB830")
        TrafficPhase.RED -> Color.parseColor("#FF3B3B")
    }

    private fun createChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Estado del semáforo",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Cuenta atrás del semáforo en la pantalla de bloqueo"
            setShowBadge(false)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                setAllowBubbles(false)
            }
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }
}
