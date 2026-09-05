#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUILD="$ROOT/.build"

if command -v latexmk >/dev/null 2>&1; then
  ENGINE=latexmk
elif command -v pdflatex >/dev/null 2>&1; then
  ENGINE=pdflatex
else
  echo "TeX tidak ditemukan: perlu latexmk atau pdflatex." >&2
  exit 127
fi

rm -rf "$BUILD"
mkdir -p "$BUILD"

compile_one() {
  tex="$1"
  dir=$(dirname "$tex")
  file=$(basename "$tex")
  stem=${file%.tex}
  rel=${dir#"$ROOT"/}
  out="$BUILD/$rel"

  mkdir -p "$out"
  echo
  echo "==> COMPILE ${tex#"$ROOT"/}"

  if [ "$ENGINE" = "latexmk" ]; then
    (
      cd "$dir"
      latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error \
        -outdir="$out" "$file"
    )
  else
    (
      cd "$dir"
      pdflatex -interaction=nonstopmode -halt-on-error -file-line-error \
        -output-directory="$out" "$file"
      pdflatex -interaction=nonstopmode -halt-on-error -file-line-error \
        -output-directory="$out" "$file"
    )
  fi

  pdf="$out/$stem.pdf"
  [ -s "$pdf" ] || {
    echo "PDF tidak terbentuk: $pdf" >&2
    exit 2
  }
  cp "$pdf" "$dir/$stem.pdf"
  echo "    OK -> $rel/$stem.pdf"
}

find "$ROOT/Lembar_Kerja" "$ROOT/Materi" -type f -name '*.tex' -print | sort | while IFS= read -r tex; do
  if grep -Eq '^[[:space:]]*\\documentclass' "$tex"; then
    compile_one "$tex"
  fi
done

rm -rf "$BUILD"

echo
echo "Build selesai. PDF berada di folder yang sama dengan source .tex:"
find "$ROOT/Lembar_Kerja" "$ROOT/Materi" -type f -name '*.pdf' -print | sort | sed "s#^$ROOT/#    #"
