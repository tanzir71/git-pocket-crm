#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Checking landing page under docs/..."

if [ ! -f "docs/.nojekyll" ]; then
  echo "ERROR: docs/.nojekyll is missing" >&2
  exit 1
fi

if [ ! -f "docs/index.html" ]; then
  echo "ERROR: docs/index.html is missing" >&2
  exit 1
fi

# 1. No <script> elements anywhere under docs/
if grep -rnI -i '<script' docs/; then
  echo "ERROR: Found <script> element under docs/" >&2
  exit 1
fi

# 2. No @import or url(http...) in CSS/HTML under docs/
if grep -rnI -i '@import' docs/; then
  echo "ERROR: Found @import under docs/" >&2
  exit 1
fi

if grep -rnI -i 'url([[:space:]]*["'\'']*http' docs/; then
  echo "ERROR: Found remote url(http...) under docs/" >&2
  exit 1
fi

# 3. No src="http..." or src="//..." or stylesheet href="http..." / href="//..."
if grep -rnI -iE 'src[[:space:]]*=[[:space:]]*["'\''](https?:|//)' docs/; then
  echo "ERROR: Found remote src attribute under docs/" >&2
  exit 1
fi

if grep -rnI -iE '<link[^>]*rel[[:space:]]*=[[:space:]]*["'\'']stylesheet["'\''][^>]*href[[:space:]]*=[[:space:]]*["'\''](https?:|//)' docs/; then
  echo "ERROR: Found remote stylesheet href under docs/" >&2
  exit 1
fi

# 4. Never describe the project as "open source"
if grep -rnI -i 'open[ -]source' docs/; then
  echo "ERROR: Found forbidden phrase 'open source' under docs/" >&2
  exit 1
fi

# 5. Exactly one <h1> in docs/index.html, and every <img> has alt, width, and height
python - <<'PY'
from html.parser import HTMLParser
import sys

class Checker(HTMLParser):
    def __init__(self):
        super().__init__()
        self.h1_count = 0
        self.errors = []

    def handle_starttag(self, tag, attrs):
        attr_map = dict(attrs)
        if tag.lower() == 'h1':
            self.h1_count += 1
        if tag.lower() == 'img':
            for req in ('alt', 'width', 'height'):
                if req not in attr_map or not str(attr_map[req]).strip():
                    self.errors.append(f"<img> missing required attribute '{req}': {attr_map}")

with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

c = Checker()
c.feed(content)

if c.h1_count != 1:
    c.errors.append(f"Expected exactly 1 <h1> in docs/index.html, found {c.h1_count}")

if c.errors:
    for err in c.errors:
        print(f"ERROR: {err}", file=sys.stderr)
    sys.exit(1)

print("==> HTML checks passed (1 <h1>, all <img> have alt/width/height)")
PY

echo "==> OK: check_landing.sh passed."
