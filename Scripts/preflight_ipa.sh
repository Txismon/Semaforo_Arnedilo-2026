#!/bin/bash
set -euo pipefail

IPA="$(find "$CM_BUILD_DIR/build/ios/ipa" -name '*.ipa' | head -1)"
[ -n "$IPA" ] || { echo "ERROR: IPA no encontrado"; exit 1; }

WORK="/tmp/semaforo_preflight"
rm -rf "$WORK"
mkdir -p "$WORK"
unzip -q "$IPA" -d "$WORK"

APP="$WORK/Payload/SemaforoArnedillo.app"
EXT="$APP/PlugIns/SemaforoLiveActivity.appex"

echo "=== PRE-FLIGHT IPA ==="
echo "IPA: $IPA"

require_file() {
  [ -e "$1" ] || { echo "ERROR: falta $1"; exit 1; }
}

plist_value() {
  /usr/libexec/PlistBuddy -c "Print :$2" "$1"
}

assert_plist() {
  local plist="$1" key="$2" expected="$3"
  local actual
  actual="$(plist_value "$plist" "$key" 2>/dev/null || true)"
  echo "$key = $actual"
  [ "$actual" = "$expected" ] || {
    echo "ERROR: $key esperado '$expected', obtenido '$actual'"
    exit 1
  }
}

require_file "$APP/Info.plist"
require_file "$EXT/Info.plist"
require_file "$APP/SemaforoArnedillo"
require_file "$EXT/SemaforoLiveActivity"
require_file "$APP/Assets.car"
require_file "$APP/PrivacyInfo.xcprivacy"
require_file "$APP/embedded.mobileprovision"
require_file "$EXT/embedded.mobileprovision"

echo "--- App Info.plist"
assert_plist "$APP/Info.plist" "CFBundleExecutable" "SemaforoArnedillo"
assert_plist "$APP/Info.plist" "CFBundleIdentifier" "$APP_BUNDLE_ID"
assert_plist "$APP/Info.plist" "CFBundlePackageType" "APPL"
assert_plist "$APP/Info.plist" "CFBundleIconName" "AppIcon"
assert_plist "$APP/Info.plist" "CFBundleName" "SemaforoArnedillo"

echo "--- LiveActivity Info.plist"
assert_plist "$EXT/Info.plist" "CFBundleExecutable" "SemaforoLiveActivity"
assert_plist "$EXT/Info.plist" "CFBundleIdentifier" "$APP_BUNDLE_ID.LiveActivity"
assert_plist "$EXT/Info.plist" "CFBundlePackageType" "XPC!"
assert_plist "$EXT/Info.plist" "CFBundleName" "SemaforoLiveActivity"
assert_plist "$EXT/Info.plist" "NSExtension:NSExtensionPointIdentifier" "com.apple.widgetkit-extension"

echo "--- Ejecutables"
file "$APP/SemaforoArnedillo"
file "$EXT/SemaforoLiveActivity"
test -x "$APP/SemaforoArnedillo"
test -x "$EXT/SemaforoLiveActivity"

echo "--- Firmas"
codesign --verify --deep --strict --verbose=2 "$APP"
codesign --verify --strict --verbose=2 "$EXT"

echo "--- Privacy manifest"
/usr/libexec/PlistBuddy -c \
  "Print :NSPrivacyAccessedAPITypes:0:NSPrivacyAccessedAPIType" \
  "$APP/PrivacyInfo.xcprivacy"
/usr/libexec/PlistBuddy -c \
  "Print :NSPrivacyAccessedAPITypes:0:NSPrivacyAccessedAPITypeReasons:0" \
  "$APP/PrivacyInfo.xcprivacy"

echo "--- Assets"
xcrun --find assetutil >/dev/null
xcrun assetutil --info "$APP/Assets.car" > "$WORK/assets.json"
grep -q '"Name" : "AppIcon"' "$WORK/assets.json" || {
  echo "ERROR: AppIcon no aparece compilado en Assets.car"
  cat "$WORK/assets.json"
  exit 1
}

echo "PRE-FLIGHT OK"
