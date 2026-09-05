#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/.build"
GEN="$ROOT/generated"
rm -rf "$BUILD"
mkdir -p "$BUILD" "$GEN/Lembar_Kerja" "$GEN/Materi"

if command -v latexmk >/dev/null 2>&1; then
  LATEXMK=1
elif command -v pdflatex >/dev/null 2>&1; then
  LATEXMK=0
else
  echo "TeX lokal tidak ditemukan (latexmk/pdflatex)."
  echo "Source tetap bisa dipush; GitHub Actions akan compile dan mengisi generated/."
  exit 127
fi

build_one(){
  local src="$1" tex="$2" out="$3" final="$4"
  mkdir -p "$out" "$(dirname "$final")"
  echo "==> COMPILE ${src#$ROOT/}/$tex"
  if [[ "$LATEXMK" == 1 ]]; then
    (cd "$src" && latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$out" "$tex")
  else
    (cd "$src" && pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$out" "$tex")
    (cd "$src" && pdflatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory="$out" "$tex")
  fi
  local pdf="$out/${tex%.tex}.pdf"
  [[ -f "$pdf" ]] || { echo "PDF tidak terbentuk: $pdf"; exit 2; }
  cp "$pdf" "$final"
  echo "    -> ${final#$ROOT/}"
}

build_one "$ROOT/Lembar_Kerja" "lembar_kerja_PIDK.tex" "$BUILD/Lembar_Kerja" "$GEN/Lembar_Kerja/lembar_kerja_PIDK.pdf"

while IFS= read -r -d '' tex; do
  d="$(dirname "$tex")"
  m="$(basename "$d")"
  [[ "$m" =~ ^M[0-9][0-9]$ ]] || continue
  name="$(basename "$tex" .tex)"
  build_one "$d" "$(basename "$tex")" "$BUILD/Materi/$m" "$GEN/Materi/$m/${name}.pdf"
done < <(find "$ROOT/Materi" -mindepth 2 -maxdepth 2 -type f -name '*.tex' -print0 | sort -z)

rm -rf "$BUILD"
echo
echo "Build selesai: $GEN"
