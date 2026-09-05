#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MSG=${1:-"Update PIDK $(date '+%Y-%m-%d %H:%M')"}

if sh "$ROOT/tools/build.sh"; then
    :
else
    code=$?
    if [ "$code" -eq 127 ]; then
        echo "TeX lokal tidak tersedia. Source akan dipush dan GitHub Actions akan compile."
    else
        echo "Build gagal. Push dibatalkan." >&2
        exit "$code"
    fi
fi

git add -A
if ! git diff --cached --quiet; then
    git commit -m "$MSG"
fi

# Ambil perubahan remote yang mungkin masuk dari Overleaf tepat sebelum push.
if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
    git pull --rebase origin main
fi

git push -u origin main
