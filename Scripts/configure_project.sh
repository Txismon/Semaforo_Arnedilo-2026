#!/bin/bash
set -euo pipefail

: "${APP_BUNDLE_ID:?Define APP_BUNDLE_ID, por ejemplo com.tuempresa.semaforoarnedillo}"
: "${APPLE_TEAM_ID:?Define APPLE_TEAM_ID, el Team ID de Apple Developer}"

BUNDLE_PREFIX="${APP_BUNDLE_ID%.*}"

cp project.yml project.generated.yml
sed -i.bak "s|__APP_BUNDLE_ID__|${APP_BUNDLE_ID}|g" project.generated.yml
sed -i.bak "s|__BUNDLE_PREFIX__|${BUNDLE_PREFIX}|g" project.generated.yml
sed -i.bak "s|__APPLE_TEAM_ID__|${APPLE_TEAM_ID}|g" project.generated.yml
rm -f project.generated.yml.bak

xcodegen generate --spec project.generated.yml

echo "Proyecto generado:"
echo "  App:       ${APP_BUNDLE_ID}"
echo "  Extension: ${APP_BUNDLE_ID}.LiveActivity"
