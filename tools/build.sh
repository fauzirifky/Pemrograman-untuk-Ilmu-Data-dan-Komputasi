#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEN="$ROOT/generated"
mkdir -p "$GEN/Lembar_Kerja" "$GEN/Materi"

if command -v latexmk >/dev/null 2>&1; then
  ENGINE=(latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error)
  CLEAN=(latexmk -c)
elif command -v pdflatex >/dev/null 2>&1; then
  ENGINE=(pdflatex -interaction=nonstopmode -halt-on-error -file-line-error)
  CLEAN=()
else
  echo "TeX tidak ditemukan. Install MacTeX/TeX Live atau compile di Overleaf."
  exit 127
fi

build_one() {
  local srcdir="$1" tex="$2" outdir="$3"
  mkdir -p "$outdir"
  echo "==> BUILD ${srcdir#$ROOT/}/$tex"
  if [[ "${ENGINE[0]}" == "latexmk" ]]; then
    (cd "$srcdir" && "${ENGINE[@]}" -outdir="$outdir" "$tex")
  else
    (cd "$srcdir" && "${ENGINE[@]}" -output-directory="$outdir" "$tex")
    (cd "$srcdir" && "${ENGINE[@]}" -output-directory="$outdir" "$tex")
  fi
  # Sisakan hanya PDF di generated untuk tampilan bersih.
  find "$outdir" -maxdepth 1 -type f ! -name '*.pdf' ! -name 'README.md' -delete 2>/dev/null || true
}

build_one "$ROOT/Lembar_Kerja" "lembar_kerja_PIDK.tex" "$GEN/Lembar_Kerja"

while IFS= read -r -d '' tex; do
  d="$(dirname "$tex")"
  m="$(basename "$d")"
  [[ "$m" =~ ^M[0-9][0-9]$ ]] || continue
  build_one "$d" "$(basename "$tex")" "$GEN/Materi/$m"
done < <(find "$ROOT/Materi" -mindepth 2 -maxdepth 2 -type f -name '*.tex' -print0 | sort -z)

echo
echo "Selesai. PDF lokal ada di: $GEN"
