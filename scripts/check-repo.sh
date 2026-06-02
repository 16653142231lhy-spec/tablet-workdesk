#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "== Bash syntax =="
bash -n scripts/install-tablet-workdesk.sh
bash -n scripts/finalize-office-lite-avnc.sh
bash -n scripts/switch-office-to-avnc.sh
bash -n scripts/tune-office-light.sh
bash -n scripts/check-repo.sh

echo "== Shell line endings =="
if grep -RIl $'\r' scripts/*.sh; then
  echo "CRLF found in shell scripts"
  exit 1
fi

echo "== Common accidental secret patterns =="
if grep -RInE '(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|OPENAI_API_KEY|ANTHROPIC_API_KEY|Authorization: Bearer)' \
  README.md README.zh-CN.md CHANGELOG.md CONTRIBUTING.md SECURITY.md SUPPORT.md CODE_OF_CONDUCT.md docs scripts .github/ISSUE_TEMPLATE .github/PULL_REQUEST_TEMPLATE.md \
  | grep -vE 'scripts/check-repo\.(sh|ps1)'; then
  echo "Possible secret pattern found"
  exit 1
fi

echo "OK"
