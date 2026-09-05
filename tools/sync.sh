#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MSG=${1:-"Sync PIDK $(date '+%Y-%m-%d %H:%M')"}

echo "==> 1/4 Pull GitHub"
if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
    git pull --rebase --autostash origin main
else
    echo "origin/main belum tersedia; lanjut sebagai initial push."
fi

echo "==> 2/4 Compile"
if sh "$ROOT/tools/build.sh"; then
    :
else
    code=$?
    if [ "$code" -eq 127 ]; then
        echo "TeX lokal tidak tersedia. GitHub Actions akan compile setelah push."
    else
        echo "Build gagal. Sync berhenti sebelum push." >&2
        exit "$code"
    fi
fi

echo "==> 3/4 Commit"
git add -A
if ! git diff --cached --quiet; then
    git commit -m "$MSG"
else
    echo "Tidak ada perubahan untuk commit."
fi

echo "==> 4/4 Push"
if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
    git pull --rebase origin main
fi
git push -u origin main

echo
echo "Sync selesai: PC <-> GitHub."
echo "Jika ada edit baru di Overleaf setelah ini, lakukan Push dari Overleaf lalu jalankan sync lagi di PC."
