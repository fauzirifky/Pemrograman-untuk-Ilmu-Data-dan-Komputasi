#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
[[ -d .git ]] || { echo "Belum merupakan Git repository."; exit 1; }
git fetch origin
git pull --rebase --autostash origin main
