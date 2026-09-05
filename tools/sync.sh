#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
MSG="${1:-Sync PIDK $(date '+%Y-%m-%d %H:%M')}"
[[ -d .git ]] || { echo "Belum merupakan Git repository."; exit 1; }

# Simpan edit lokal sebagai commit lebih dulu supaya tidak hilang.
git add -A
if ! git diff --cached --quiet; then
  git commit -m "$MSG"
fi

# Ambil perubahan GitHub (termasuk push dari Overleaf), lalu push hasil lokal.
git fetch origin
git pull --rebase origin main
git push origin main

echo
echo "Sinkronisasi PC <-> GitHub selesai."
echo "Overleaf <-> GitHub: gunakan Integrations > GitHub > Pull/Push di Overleaf."
