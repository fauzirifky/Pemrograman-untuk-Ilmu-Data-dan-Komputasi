#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
MSG="${1:-Sync PIDK $(date '+%Y-%m-%d %H:%M')}"

# 1. Tarik update dari GitHub/Overleaf lebih dulu, sambil menjaga edit lokal.
git pull --rebase --autostash origin main || {
  echo "Pull gagal. Jika ada conflict, selesaikan conflict lalu jalankan sync lagi."
  exit 2
}

# 2. Compile lokal bila TeX tersedia.
if ! "$ROOT/tools/build.sh"; then
  code=$?
  if [[ $code -eq 127 ]]; then
    echo "Build lokal dilewati; GitHub Actions akan compile setelah push."
  else
    echo "Build lokal gagal. Sync berhenti sebelum push."
    exit $code
  fi
fi

# 3. Commit source + generated PDF, lalu push.
git add -A
if ! git diff --cached --quiet; then git commit -m "$MSG"; fi
git push -u origin main

echo
echo "Sync selesai: PC <-> GitHub."
echo "Jika edit berasal dari Overleaf, Push dari Overleaf dahulu."
echo "Jika edit berasal dari PC, setelah ini lakukan Pull pada Overleaf."
