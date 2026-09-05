#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
MSG="${1:-Update PIDK $(date '+%Y-%m-%d %H:%M')}"
if ! "$ROOT/tools/build.sh"; then
  code=$?
  if [[ $code -eq 127 ]]; then
    echo "Build lokal dilewati; GitHub Actions akan compile setelah push."
  else
    echo "Build lokal gagal. Push dibatalkan agar error diperbaiki dahulu."
    exit $code
  fi
fi
git add -A
if ! git diff --cached --quiet; then git commit -m "$MSG"; fi
git push -u origin main
