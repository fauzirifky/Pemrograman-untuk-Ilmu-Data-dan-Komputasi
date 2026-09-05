#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

git pull --rebase --autostash origin main

if sh "$ROOT/tools/build.sh"; then
    :
else
    code=$?
    if [ "$code" -eq 127 ]; then
        echo "TeX lokal tidak tersedia. Pull tetap selesai; GitHub Actions dapat melakukan build."
    else
        exit "$code"
    fi
fi
