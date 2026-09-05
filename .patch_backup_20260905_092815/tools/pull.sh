#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
git pull --rebase --autostash origin main
if ! "$ROOT/tools/build.sh"; then
  code=$?
  [[ $code -eq 127 ]] || exit $code
fi
