SEMÁFORO ARNEDILLO — PARCHE ACUMULATIVO BUILD 3

Este parche incluye de una sola vez:

1. FUNCIÓN HORARIOS
   - Nuevo acceso "Horarios" desde la pantalla principal.
   - Selector ENTRADA / SALIDA.
   - Próximas aperturas a verde durante las siguientes 2 horas.
   - Próxima apertura destacada.
   - Cuenta atrás relativa actualizada cada segundo.
   - Pull-to-refresh para releer greenStartTime de Base44.

2. LIVE ACTIVITY / PANTALLA DE BLOQUEO
   - Fondo oscuro.
   - Dirección del trayecto en blanco.
   - Cuenta atrás en blanco.
   - Estado ROJO / ÁMBAR / VERDE con color propio.
   - Se elimina cualquier elemento decorativo adicional a la derecha.
   - Se mantiene únicamente el indicador circular de estado a la izquierda.

3. BUILD
   - CURRENT_PROJECT_VERSION = 3
   - MARKETING_VERSION se mantiene en 1.0.

ARCHIVOS DEL PARCHE

Sustituir:
- Sources/App/ContentView.swift
- Sources/Shared/SemaforoEngine.swift
- Sources/LiveActivity/SemaforoLiveActivity.swift
- project.yml

Añadir:
- Sources/App/HorariosView.swift

No modificar:
- codemagic.yaml
- Info.plist
- iconos
- firma
- provisioning profiles
- Scripts/preflight_ipa.sh

Después:
1. Copia estos archivos a las mismas rutas de GitHub.
2. Commit.
3. Lanza un nuevo build en Codemagic.
4. Debe publicarse como versión 1.0, build 3.
