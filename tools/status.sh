#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
echo "Repo: $ROOT"
echo
git status -sb
echo
git remote -v
echo
git log --oneline --decorate -10 2>/dev/null || true
