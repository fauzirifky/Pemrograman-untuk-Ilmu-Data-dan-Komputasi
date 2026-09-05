#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
echo "Repo: $ROOT"
echo
git status -sb
echo
git remote -v
echo
git log --oneline --decorate -8 2>/dev/null || true
