SEMÁFORO ARNEDILLO — PARCHE BUILD 4
====================================

POR QUÉ ESTE PARCHE
-------------------
El parche Build 3 reintrodujo la dependencia de Base44 que habíamos
eliminado. Concretamente:

- Sources/App/ContentView.swift volvió a llamar a Base44Service.
- Sources/App/HorariosView.swift (nuevo en Build 3) también llamaba a
  Base44Service.
- Sources/App/Base44Service.swift seguía en el repositorio (nunca llegó
  a borrarse).

Como el proyecto Base44 exige login y devuelve HTTP 403 al acceso
anónimo (verificado), esas dos pantallas fallan siempre.

En cambio, Build 3 sí dejó bien:
- Sources/App/LiveActivityManager.swift (ya usaba SemaforoSyncStore).
- Sources/LiveActivity/SemaforoLiveActivity.swift (mejoras de pantalla
  de bloqueo, sin Base44).
- Sources/Shared/SemaforoEngine.swift (con nextGreenStarts).

Este Build 4 conserva TODAS las mejoras de horarios y de UX de Build 3
y elimina Base44 de forma definitiva.

QUÉ CAMBIA
----------
- ContentView.swift: mantiene el diseño de Build 3 (ScrollView y tarjeta
  de acceso a Horarios) y lee el instante de referencia de
  SemaforoSyncStore. Se sustituye el botón "Actualizar" por
  "Sincronizar", que recalibra el semáforo pulsándolo justo cuando el
  semáforo real se pone en verde, y muestra la última sincronización.
- HorariosView.swift: mantiene todo el diseño de Build 3 (selector de
  sentido, tarjeta de ruta, próximos verdes en 2 horas, próximo
  destacado, cuenta atrás por segundo, pull-to-refresh) pero calcula a
  partir de SemaforoSyncStore. Se elimina el estado de error de red
  porque ya no hay red.
- project.yml: CURRENT_PROJECT_VERSION = 4 (App Store Connect exige que
  cada subida tenga un build superior al anterior). MARKETING_VERSION
  sigue en 1.0.
- Resources/App/Info.plist: se añade ITSAppUsesNonExemptEncryption =
  false para que App Store Connect deje de preguntar por cumplimiento de
  exportación en cada subida y TestFlight quede disponible al momento.

ARCHIVOS DEL PARCHE
-------------------
Sustituir:
- Sources/App/ContentView.swift
- Sources/App/HorariosView.swift
- Resources/App/Info.plist
- project.yml

Asegurar que existe (se incluye por si acaso, es idéntico al del repo):
- Sources/Shared/SemaforoSyncStore.swift

BORRAR DEL REPOSITORIO (importante, es lo que faltó la vez anterior):
- Sources/App/Base44Service.swift

No modificar:
- codemagic.yaml
- Resources/LiveActivity/Info.plist
- Resources/App/PrivacyInfo.xcprivacy
- Resources/App/Assets.xcassets (iconos)
- Scripts/preflight_ipa.sh
- Sources/App/LiveActivityManager.swift
- Sources/LiveActivity/SemaforoLiveActivity.swift
- Sources/Shared/SemaforoEngine.swift
- Sources/Shared/SemaforoActivityAttributes.swift

PASOS
-----
1. Copia los archivos a las mismas rutas en GitHub.
2. BORRA Sources/App/Base44Service.swift.
3. Commit.
4. Lanza un nuevo build en Codemagic.
5. Debe publicarse como versión 1.0, build 4.

COMPROBACIÓN RÁPIDA ANTES DE HACER COMMIT
------------------------------------------
Busca "Base44" en todo el repositorio. No debe aparecer en ningún
archivo de Sources/. Si aparece, el build volverá a fallar igual.

QUÉ PROBAR AL INSTALAR
----------------------
- Pantalla principal: contador visible, sin errores de red.
- Botón "Sincronizar": actualiza el contador y la fecha de última
  sincronización.
- Horarios: lista de próximos verdes con el primero destacado.
- "Mostrar en CarPlay": Live Activity con fondo oscuro y estado en
  color.

NOTA SOBRE EL CIFRADO (ITSAppUsesNonExemptEncryption)
------------------------------------------------------
Se declara "false" porque, tras eliminar Base44, la app no realiza
ninguna conexión de red ni utiliza algoritmos de cifrado: todo el
cálculo del semáforo es local y el único dato que guarda es un instante
de referencia en UserDefaults.

Esta clave es una declaración legal de cumplimiento de exportación que
haces tú como responsable de la app. Es correcta mientras la app siga
sin usar cifrado. Si en el futuro añades llamadas de red por HTTPS
(por ejemplo, para sincronizar desde un servidor propio), revisa la
declaración: el uso de HTTPS estándar suele seguir estando exento, pero
conviene confirmarlo entonces en App Store Connect.

NOTA SOBRE LA SINCRONIZACIÓN
-----------------------------
La calibración es local a cada dispositivo, porque ya no hay servidor.
Cada iPhone se calibra la primera vez que alguien pulse "Sincronizar"
delante del semáforo real. Si en el futuro quieres que la calibración
sea compartida por todos los usuarios, habría que publicar un JSON en
un servidor propio (sin login) y leerlo desde SemaforoSyncStore.
