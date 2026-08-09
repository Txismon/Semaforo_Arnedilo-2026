PARCHE: eliminar dependencia de Base44 (quita el bloqueo de login)
====================================================================

QUÉ CAMBIA
----------
La app llamaba a la API de Base44 (Sources/App/Base44Service.swift) para
leer el instante en que cada sentido del semáforo se pone en verde. Esa
llamada se hacía sin token, solo con un ID anónimo, pero el proyecto
Base44 exige login para acceder a esa entidad y devuelve HTTP 403. Como
no hay acceso a ese proyecto Base44, la app nunca podrá leer el dato y
siempre fallará.

Este parche quita esa dependencia por completo. El cálculo del semáforo
(SemaforoEngine.swift, sin cambios) ya era determinista: un ciclo fijo
de 590.03 s rojo + 67 s verde + 3 s ámbar a partir de un único instante
de referencia. Ese instante ahora se guarda en el propio dispositivo
(UserDefaults), sin red ni login.

Se añade un botón "Sincronizar" en la app: quien esté delante del
semáforo real lo pulsa justo cuando se pone en verde, y así se recalibra
el contador. Es el mismo mecanismo que tenía la web (el diálogo con
contraseña), pero ahora vive en el propio iPhone y no depende de nadie.

Limitación a tener en cuenta: la sincronización es local a cada
dispositivo. Si instalas la app en varios iPhones, cada uno se calibra
por su cuenta la primera vez que alguien pulse "Sincronizar" delante del
semáforo real.

PASOS EN GITHUB
----------------
1. Sustituye estos dos archivos por los de este ZIP:
   - Sources/App/ContentView.swift
   - Sources/App/LiveActivityManager.swift

2. Añade este archivo nuevo:
   - Sources/Shared/SemaforoSyncStore.swift

3. Borra este archivo, ya no se usa:
   - Sources/App/Base44Service.swift

4. No hay que tocar project.yml, codemagic.yaml, Info.plist ni
   PrivacyInfo.xcprivacy: siguen siendo válidos (la app deja de hacer
   llamadas de red, así que si en algún momento quieres declarar aún
   menos permisos, puedes, pero no es obligatorio).

5. Haz commit y lanza un nuevo build en Codemagic.

QUÉ PROBAR AL INSTALAR EL BUILD
--------------------------------
- Abre la app: debe mostrar el contador sin ningún error ni pantalla de
  login (antes se veía "Base44 devolvió HTTP 403").
- Pulsa "Sincronizar" y comprueba que el contador arranca en verde y el
  texto "Última sincronización" se actualiza.
- Pulsa "Mostrar en CarPlay" y comprueba que la Live Activity aparece y
  cuenta correctamente.
