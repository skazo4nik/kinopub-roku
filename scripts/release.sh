#!/bin/sh
# Сборка и публикация релиза на GitHub.
# Использование: scripts/release.sh 1.2.2 "Описание изменений"
# Нужны: zip, gh (авторизованный), brighterscript (npm i -g brighterscript).
set -e
cd "$(dirname "$0")/.."
VER="$1"; NOTES="${2:-Релиз $1}"
[ -n "$VER" ] || { echo "укажите версию, например 1.2.2"; exit 1; }
MAJOR=$(echo "$VER" | cut -d. -f1); MINOR=$(echo "$VER" | cut -d. -f2); BUILD=$(echo "$VER" | cut -d. -f3)
sed -i "s/^major_version=.*/major_version=$MAJOR/; s/^minor_version=.*/minor_version=$MINOR/; s/^build_version=.*/build_version=${BUILD:-0}/" manifest
bsc --project bsconfig.json
rm -rf build kinopub.zip
zip -qr kinopub.zip manifest source components images
SHA=$(sha256sum kinopub.zip | cut -d' ' -f1)
git add -A && git commit -m "Версия $VER" || true
git tag "v$VER"
git push && git push --tags
gh release create "v$VER" kinopub.zip --title "v$VER" --notes "$NOTES

SHA-256 kinopub.zip: \`$SHA\`

Установка: раздел «Установка на Roku» в README."
