SEMÁFORO ARNEDILLO — APP ANDROID (APK)
=======================================

QUÉ ES ESTO
-----------
Port nativo a Android de la app iOS, en Kotlin + Jetpack Compose.
No comparte código con la app iOS: son dos proyectos nativos que
implementan el mismo motor de cálculo.

Igual que la versión iOS tras eliminar Base44, esta app NO hace ninguna
conexión de red. Todo el cálculo del semáforo es local:
  ciclo fijo de 67 s verde + 3 s ámbar + 590,03 s rojo = 660,03 s
a partir de un instante de referencia guardado en el dispositivo.

QUÉ INCLUYE
-----------
- Pantalla de contador: sentido (ENTRADA / SALIDA), fase actual con
  color, cuenta atrás y botón de sincronización.
- Pantalla de horarios: próximos cambios a verde en las siguientes 2
  horas, con el próximo destacado y cuenta atrás relativa.
- Notificación persistente en la pantalla de bloqueo con la fase actual
  y cuenta atrás. Es el equivalente a la Live Activity de iOS.
- Icono de app generado a partir del icono de 1024 px del proyecto iOS.

DÓNDE COLOCARLO EN GITHUB
--------------------------
Copia la carpeta completa en la raíz del repositorio, de forma que
quede así:

  Semaforo_Arnedilo-2026/
    Sources/            <- iOS (no se toca)
    Resources/          <- iOS (no se toca)
    project.yml         <- iOS (no se toca)
    codemagic.yaml      <- se le añade un workflow, ver abajo
    android/            <- NUEVO, todo lo de este ZIP
      app/
      gradle/
      build.gradle.kts
      settings.gradle.kts
      gradle.properties

IMPORTANTE: todo el contenido de este ZIP va dentro de una carpeta
llamada "android" en la raíz. Los proyectos iOS y Android conviven en el
mismo repositorio sin interferir.

CONFIGURAR CODEMAGIC
--------------------
Abre codemagic-android-workflow.yaml (incluido en este ZIP) y pega su
bloque dentro de la sección "workflows:" de tu codemagic.yaml actual,
al mismo nivel que "ios-testflight:". No borres el workflow de iOS.

Después, en Codemagic verás dos workflows y podrás lanzar el que
quieras:
  - "Semáforo Arnedillo - TestFlight"  (iOS)
  - "Semáforo Arnedillo - APK Android" (Android)

El APK aparecerá en los artefactos del build, listo para descargar.

FIRMA DEL APK
-------------
Por defecto el APK se firma con la clave de depuración, que es
suficiente para instalarlo por sideload y repartirlo.

Si más adelante quieres una firma propia y estable (recomendable si vas
a publicar actualizaciones), crea una clave en Codemagic en
"Code signing identities" > "Android keystores". El build.gradle.kts ya
está preparado: detecta las variables CM_KEYSTORE_PATH,
CM_KEYSTORE_PASSWORD, CM_KEY_ALIAS y CM_KEY_PASSWORD y firma con ellas
automáticamente, sin tocar código.

Aviso: una vez repartas un APK firmado con una clave, las
actualizaciones deben ir firmadas con la MISMA clave o Android se
negará a instalarlas encima.

CÓMO INSTALAR EL APK
--------------------
1. Descarga el .apk de los artefactos de Codemagic.
2. Pásalo al móvil (WhatsApp, Drive, cable, web...).
3. Al abrirlo, Android pedirá permiso para "instalar apps desconocidas"
   desde la aplicación que estés usando. Acéptalo.
4. Instala.

En el primer arranque, cuando pulses "Mostrar en la pantalla de
bloqueo", Android pedirá permiso de notificaciones (Android 13+).

DIFERENCIAS RESPECTO A LA APP iOS
----------------------------------
1. NO HAY ANDROID AUTO. Google solo permite en Android Auto apps de
   navegación, media y mensajería. Un contador de semáforo no encaja en
   ninguna categoría admitida, así que no existe equivalente al
   "Mostrar en CarPlay". La notificación en pantalla de bloqueo sí
   funciona con el móvil en el soporte.

2. LA NOTIFICACIÓN NO ES UNA LIVE ACTIVITY. Es una notificación
   persistente con cronómetro nativo de Android. Funciona bien y
   consume poca batería (el sistema dibuja la cuenta atrás y la app solo
   la reescribe al cambiar de fase), pero visualmente no es igual que
   una Live Activity ni una Dynamic Island.

3. LA SINCRONIZACIÓN ES LOCAL, igual que en iOS. Cada dispositivo se
   calibra por su cuenta pulsando "Sincronizar" justo cuando el
   semáforo real se pone en verde.

REQUISITOS
----------
- Android 8.0 (API 26) o superior.
- No requiere conexión a internet en ningún momento.

VERSIONES
---------
versionCode 1 / versionName "1.0" en android/app/build.gradle.kts.
Para futuras versiones sube versionCode en cada APK que repartas.
