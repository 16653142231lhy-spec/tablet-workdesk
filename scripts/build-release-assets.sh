#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

mkdir -p dist
cp scripts/install-tablet-workdesk.sh dist/tw.sh
chmod +x dist/tw.sh

if grep -Il $'\r' dist/tw.sh; then
  echo "CRLF found in dist/tw.sh"
  exit 1
fi

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum dist/tw.sh > dist/tw.sh.sha256
else
  shasum -a 256 dist/tw.sh > dist/tw.sh.sha256
fi

echo "Release assets written:"
echo "  dist/tw.sh"
echo "  dist/tw.sh.sha256"
