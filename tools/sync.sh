#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
MSG=${1:-"Sync PIDK $(date '+%Y-%m-%d %H:%M')"}

has_remote_main() {
  git ls-remote --exit-code --heads origin main >/dev/null 2>&1
}

commit_all_if_needed() {
  message="$1"
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "$message"
    return 0
  fi
  return 1
}

rebase_origin_main() {
  if has_remote_main; then
    git fetch origin main
    if ! git rebase origin/main; then
      echo >&2
      echo "REBASE CONFLICT." >&2
      echo "Selesaikan conflict, lalu:" >&2
      echo "  git add -A" >&2
      echo "  git rebase --continue" >&2
      echo "  sh tools/sync.sh \"$MSG\"" >&2
      exit 2
    fi
  fi
}

echo "==> 1/6 Compile perubahan lokal"
if sh "$ROOT/tools/build.sh"; then
  :
else
  code=$?
  if [ "$code" -eq 127 ]; then
    echo "TeX lokal tidak tersedia. Source tetap dapat disinkronkan; GitHub Actions akan build."
  else
    echo "Build gagal. Sync dibatalkan sebelum commit/push." >&2
    exit "$code"
  fi
fi

echo "==> 2/6 Commit SEMUA perubahan lokal"
# Penting: commit dulu agar pull/rebase tidak pernah bertemu working tree kotor.
if commit_all_if_needed "$MSG"; then
  :
else
  echo "    Tidak ada perubahan lokal baru."
fi

echo "==> 3/6 Ambil perubahan GitHub/Overleaf"
rebase_origin_main

echo "==> 4/6 Rebuild setelah rebase"
if sh "$ROOT/tools/build.sh"; then
  if commit_all_if_needed "Rebuild PDFs after sync [skip ci]"; then
    :
  else
    echo "    PDF tetap sama."
  fi
else
  code=$?
  if [ "$code" -eq 127 ]; then
    echo "    TeX lokal tidak tersedia; lewati rebuild kedua."
  else
    exit "$code"
  fi
fi

echo "==> 5/6 Cek remote terakhir sebelum push"
# Working tree sudah bersih karena semua perubahan sudah dicommit.
rebase_origin_main

echo "==> 6/6 Push"
git push -u origin main

LOCAL_SHA=$(git rev-parse HEAD)
REMOTE_SHA=$(git ls-remote origin refs/heads/main | awk '{print $1}')

echo
if [ -n "$REMOTE_SHA" ] && [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
  echo "============================================================"
  echo "SYNC + BUILD + PUSH BERHASIL"
  echo "SHA: $LOCAL_SHA"
  echo "============================================================"
else
  echo "Push belum terverifikasi." >&2
  echo "Lokal : $LOCAL_SHA" >&2
  echo "Remote: ${REMOTE_SHA:-tidak terbaca}" >&2
  exit 3
fi
