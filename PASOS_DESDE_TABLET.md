# Pasos desde una tablet Android

1. Descarga y descomprime `SemaforoArnedillo_CloudBuild.zip`.
2. En GitHub crea un repositorio privado llamado `semaforo-arnedillo-ios`.
3. Usa "Add file / Upload files" y sube TODO el contenido de la carpeta descomprimida.
4. En Apple Developer localiza tu Team ID.
5. En App Store Connect crea la API Key (App Manager) y guarda el .p8.
6. En Codemagic conecta GitHub y añade el repositorio.
7. En Codemagic Team settings > Integrations > Developer Portal añade la clave y nómbrala
   exactamente `codemagic`.
8. Antes del primer build, cambia en `codemagic.yaml`:
   - `APP_BUNDLE_ID`
   - `APPLE_TEAM_ID`
9. Ejecuta el workflow `Semáforo Arnedillo - TestFlight`.
10. Si falla, descarga o copia el log de Codemagic y pásamelo; el siguiente ajuste se puede
    hacer sin Mac.
