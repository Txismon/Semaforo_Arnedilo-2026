# Semáforo Arnedillo — Cloud Build

Paquete preparado para compilar en Codemagic sin disponer de un Mac propio.

## Antes de subir

No necesitas abrir Xcode localmente.

Necesitas:
- Cuenta Apple Developer Program activa.
- Cuenta GitHub (o GitLab/Bitbucket).
- Cuenta Codemagic.
- Un Bundle ID propio y tu Apple Team ID.

## 1. Elige el Bundle ID

Ejemplo:

`com.tuempresa.semaforoarnedillo`

La extensión utilizará automáticamente:

`com.tuempresa.semaforoarnedillo.LiveActivity`

En Apple Developer deben existir ambos identificadores/perfiles. Codemagic puede crear/fetch
perfiles si la integración de App Store Connect tiene permisos suficientes.

## 2. App Store Connect API key

En App Store Connect:
Users and Access > Integrations > App Store Connect API

Crea una clave con acceso App Manager.

Guarda:
- Issuer ID
- Key ID
- archivo .p8

El .p8 sólo se puede descargar una vez.

## 3. Conecta Apple con Codemagic

Codemagic:
Team settings > Integrations > Developer Portal

Añade la clave y llámala exactamente:

`codemagic`

Ese nombre coincide con `codemagic.yaml`.

## 4. Variables que debes cambiar

En `codemagic.yaml` hay dos valores:

`APP_BUNDLE_ID: "com.example.semaforoarnedillo"`
`APPLE_TEAM_ID: "CAMBIAR_TEAM_ID"`

Puedes editarlos directamente antes de subir el repositorio o definirlos en Codemagic.

El Team ID aparece en Apple Developer > Membership.

## 5. Sube esta carpeta a un repositorio

El archivo `codemagic.yaml` debe quedar en la raíz del repositorio.

No subas la carpeta ZIP como un único archivo: hay que descomprimirla y subir su contenido.

## 6. Añade el repositorio a Codemagic

Codemagic > Applications > Add application > conecta GitHub > selecciona el repositorio.

Codemagic detectará `codemagic.yaml`.

Ejecuta:

`Semáforo Arnedillo - TestFlight`

## 7. Primera compilación

El workflow:

1. Instala XcodeGen.
2. Genera `SemaforoArnedillo.xcodeproj`.
3. Busca/crea perfiles App Store para app y Live Activity.
4. Aplica los perfiles.
5. Compila el IPA.
6. Sube el binario a App Store Connect.

`submit_to_testflight` está en false para que la primera build sólo se suba y puedas revisar
App Store Connect. Después se puede cambiar a true.

## 8. En App Store Connect

Crea el registro de la app con el mismo Bundle ID antes de publicar.

Una vez procesada la build:
TestFlight > Internal Testing > añade tu Apple ID como tester.

Instala TestFlight en el iPhone e instala Semáforo Arnedillo.

## Qué hace esta Fase 1

- Lee `SemaforoState` de la app Base44 pública.
- Selecciona:
  - Entrada: Arnedo → Arnedillo.
  - Salida: Arnedillo → Arnedo.
- Reproduce:
  - Verde 67 s.
  - Ámbar 3 s.
  - Rojo 590,03 s.
  - Ciclo total 660,03 s.
- Inicia una Live Activity.
- En iOS 26, la Live Activity puede mostrarse en CarPlay Dashboard.

## Limitación conocida

La Live Activity calcula el ciclo localmente con la última referencia `greenStartTime`.
Si el administrador resincroniza el semáforo mientras la app está cerrada, la referencia nueva
se lee al volver a abrir/activar la app.

## Problemas típicos

### Base44 devuelve HTTP 401/403
La estructura del endpoint se reconstruyó del cliente público. Si Base44 endurece permisos,
habrá que colocar un pequeño proxy/backend propio.

### Falta perfil de la extensión
Comprueba que existen perfiles de App Store para:
- `APP_BUNDLE_ID`
- `APP_BUNDLE_ID.LiveActivity`

### Xcode no encuentra la extensión
Revisa que Codemagic use Xcode 26 o superior.

### Primera subida a App Store Connect
Apple puede requerir completar manualmente la ficha inicial antes de TestFlight/distribución.
