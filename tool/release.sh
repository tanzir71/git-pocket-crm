#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: tool/release.sh <version> (e.g. tool/release.sh 2.0.0)" >&2
  exit 1
fi

VERSION="$1"
TAG="v${VERSION}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> 1/5 Running tool/verify.sh..."
bash tool/verify.sh

echo "==> 2/5 Building universal signed APK..."
bash tool/build_apk.sh

APK="build/PocketCRM.apk"
SHA_FILE="build/PocketCRM.apk.sha256"
NOTES_FILE="build/release-notes.md"

if command -v sha256sum >/dev/null 2>&1; then
  SHA="$(sha256sum "$APK" | awk '{print $1}')"
else
  SHA="$(shasum -a 256 "$APK" | awk '{print $1}')"
fi
echo "${SHA}  PocketCRM.apk" > "$SHA_FILE"
echo "==> Wrote $SHA_FILE ($SHA)"

echo "==> 3/5 Generating release notes at $NOTES_FILE..."
python - "$VERSION" "$SHA" "$NOTES_FILE" <<'PY'
import re, sys
from pathlib import Path

version, sha, notes_path = sys.argv[1], sys.argv[2], sys.argv[3]
changelog = Path("CHANGELOG.md").read_text(encoding="utf-8")
m = re.search(rf"^## {re.escape(version)}\b.*?\n(.*?)(?=\n## |\Z)", changelog, flags=re.S | re.M)
section = m.group(1).strip() if m else f"PocketCRM {version} release."

notes = f"""## What's new in PocketCRM {version}

{section}

## Verify download (SHA-256)

```
{sha}  PocketCRM.apk
```

## How to install on Android

1. Download `PocketCRM.apk` and open it. Allow your browser or file manager to install apps if Android asks.
2. Open PocketCRM and follow the five-step setup screen.
3. On Android 13 and later, if Calls and messages is refused immediately, tap **Open app info**, tap the three dots at the top right, tap **Allow restricted settings**, confirm with your screen lock, and return to PocketCRM to tap **Allow** again.
"""
Path(notes_path).write_text(notes, encoding="utf-8")
PY

echo "==> 4/5 Tagging $TAG and pushing..."
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists locally."
else
  git tag -a "$TAG" -m "PocketCRM $VERSION"
fi
git push origin "$TAG"

echo "==> 5/5 Creating GitHub release $TAG..."
gh release create "$TAG" "$APK" "$SHA_FILE" \
  --title "PocketCRM ${VERSION}" \
  --notes-file "$NOTES_FILE" \
  --latest

echo "==> Release $TAG published!"
