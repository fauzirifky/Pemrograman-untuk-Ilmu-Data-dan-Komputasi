#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
MSG="${1:-Update materi PIDK $(date '+%Y-%m-%d %H:%M')}"
[[ -d .git ]] || { echo "Belum merupakan Git repository."; exit 1; }
git add -A
if ! git diff --cached --quiet; then
  git commit -m "$MSG"
else
  echo "Tidak ada perubahan lokal untuk di-commit."
fi
git push origin main
