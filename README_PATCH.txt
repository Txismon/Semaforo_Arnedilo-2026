PATCH APP STORE

Sustituye/añade en tu repositorio exactamente estos archivos:

- project.yml
- Resources/App/Info.plist
- Resources/LiveActivity/Info.plist
- Resources/App/Assets.xcassets/Contents.json
- Resources/App/Assets.xcassets/AppIcon.appiconset/Contents.json
- Resources/App/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png

No cambies codemagic.yaml.

Este patch:
- Fuerza explícitamente INFOPLIST_FILE para app y Live Activity.
- Añade CFBundleIconName = AppIcon.
- Añade un catálogo de iconos válido con icono 1024x1024.
- Mantiene NSExtensionPointIdentifier = com.apple.widgetkit-extension.
- Baja deployment target a iOS 17.0.

Después:
1. Commit en GitHub.
2. Start new build en Codemagic.
