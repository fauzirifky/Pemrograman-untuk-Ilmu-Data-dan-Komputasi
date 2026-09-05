#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "Repository: $ROOT"
echo
git remote -v || true
echo
git status -sb || true
echo
if git rev-parse --git-dir >/dev/null 2>&1; then
  git log --oneline --decorate -8 || true
fi
