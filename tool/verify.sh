#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> 1/5 flutter pub get"
flutter pub get

echo "==> 2/5 flutter analyze"
flutter analyze

echo "==> 3/5 flutter test"
flutter test

echo "==> 4/5 flutter build apk --debug"
flutter build apk --debug

echo "==> 5/5 tool/check_manifest.sh"
bash tool/check_manifest.sh

echo "==> verify.sh PASSED"
