#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Building signed release APK..."
flutter build apk --release "$@"

SRC="build/app/outputs/flutter-apk/app-release.apk"
DEST="build/PocketCRM.apk"

if [ ! -f "$SRC" ]; then
  echo "ERROR: Expected APK not found at $SRC" >&2
  exit 1
fi

cp "$SRC" "$DEST"
echo "==> Copied APK to $DEST"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$DEST"
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$DEST"
else
  echo "WARNING: sha256sum not found; unable to print SHA-256" >&2
fi
