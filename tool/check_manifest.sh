#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ALLOW_LIST="tool/allowed_permissions.txt"
if [ ! -f "$ALLOW_LIST" ]; then
  echo "ERROR: Permission allow-list not found at $ALLOW_LIST" >&2
  exit 1
fi

echo "==> Checking merged release manifest permissions..."
(
  cd android
  ./gradlew :app:processReleaseMainManifest
)

MANIFEST="$(find build/app/intermediates/merged_manifest build/app/intermediates/merged_manifests -type f -path '*release*' -name 'AndroidManifest.xml' 2>/dev/null | head -n 1 || true)"

if [ -z "$MANIFEST" ] || [ ! -f "$MANIFEST" ]; then
  echo "ERROR: Merged release AndroidManifest.xml not found under build/app/intermediates/" >&2
  exit 1
fi

echo "==> Inspecting $MANIFEST"
if grep -q 'android\.permission\.INTERNET' "$MANIFEST"; then
  echo "ERROR: Release manifest contains android.permission.INTERNET!" >&2
  grep -n 'INTERNET' "$MANIFEST" >&2
  exit 1
fi

if grep -q '^android\.permission\.INTERNET$' "$ALLOW_LIST"; then
  echo "ERROR: $ALLOW_LIST must never contain android.permission.INTERNET!" >&2
  exit 1
fi

ACTUAL_FILE="$(mktemp)"
EXPECTED_FILE="$(mktemp)"
trap 'rm -f "$ACTUAL_FILE" "$EXPECTED_FILE"' EXIT

grep '<uses-permission' "$MANIFEST" \
  | sed -n 's/.*android:name="\([^"]*\)".*/\1/p' \
  | tr -d '\r' \
  | LC_ALL=C sort -u > "$ACTUAL_FILE"

grep -v '^[[:space:]]*#' "$ALLOW_LIST" \
  | grep -v '^[[:space:]]*$' \
  | tr -d '\r' \
  | LC_ALL=C sort -u > "$EXPECTED_FILE"

if ! diff -u "$EXPECTED_FILE" "$ACTUAL_FILE"; then
  echo "ERROR: Merged release permissions differ from $ALLOW_LIST!" >&2
  exit 1
fi

echo "==> OK: No INTERNET permission and merged release permissions exactly match $ALLOW_LIST."
