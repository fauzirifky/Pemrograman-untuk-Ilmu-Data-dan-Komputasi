#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

STASHED=0
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "==> Simpan sementara perubahan lokal"
  git stash push -u -m "PIDK auto-stash before pull $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null
  STASHED=1
fi

if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
  git fetch origin main
  git rebase origin/main
else
  echo "origin/main belum tersedia."
fi

if [ "$STASHED" -eq 1 ]; then
  echo "==> Kembalikan perubahan lokal"
  if ! git stash pop; then
    echo "Stash berhasil diambil tetapi ada conflict. Selesaikan conflict secara manual." >&2
    exit 2
  fi
fi

if sh "$ROOT/tools/build.sh"; then
  :
else
  code=$?
  [ "$code" -eq 127 ] || exit "$code"
  echo "TeX lokal tidak tersedia; pull tetap selesai."
fi
