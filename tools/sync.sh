#!/bin/sh
set -eu

REPO="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$REPO"
MSG="${1:-Sinkronisasi PIDK}"

echo "============================================================"
echo "PIDK SYNC: PULL -> BUILD -> COMMIT -> PUSH"
echo "============================================================"

GITDIR=$(git rev-parse --git-dir)
if [ -d "$GITDIR/rebase-merge" ] || [ -d "$GITDIR/rebase-apply" ] || [ -f "$GITDIR/MERGE_HEAD" ]; then
  echo "ERROR: ada operasi merge/rebase yang belum selesai."
  git status --short
  exit 1
fi

UNMERGED=$(git diff --name-only --diff-filter=U 2>/dev/null || true)
if [ -n "$UNMERGED" ]; then
  NONPDF=$(printf '%s\n' "$UNMERGED" | grep -v '\.pdf$' || true)
  if [ -n "$NONPDF" ]; then
    echo "ERROR: conflict source perlu diselesaikan manual:"
    printf '%s\n' "$NONPDF"
    exit 1
  fi
  git reset HEAD -- . >/dev/null 2>&1 || true
  printf '%s\n' "$UNMERGED" | while IFS= read -r f; do
    [ -n "$f" ] || continue
    git restore --source=HEAD --staged --worktree -- "$f" >/dev/null 2>&1 || true
  done
fi

# PDF adalah output build. Buang perubahan PDF lokal lama sebelum pull.
for f in $(git ls-files '*.pdf' 2>/dev/null || true); do
  git restore --source=HEAD --staged --worktree -- "$f" >/dev/null 2>&1 || true
done

STASHED=0
STASH_NAME="auto-sync-$(date +%Y%m%d_%H%M%S)"
if [ -n "$(git status --porcelain)" ]; then
  git stash push -u -m "$STASH_NAME" >/dev/null
  STASHED=1
fi

git fetch origin main
git checkout main >/dev/null 2>&1 || true

if ! git merge --no-edit origin/main; then
  CONFLICTS=$(git diff --name-only --diff-filter=U 2>/dev/null || true)
  NONPDF=$(printf '%s\n' "$CONFLICTS" | grep -v '\.pdf$' || true)
  if [ -n "$CONFLICTS" ] && [ -z "$NONPDF" ]; then
    printf '%s\n' "$CONFLICTS" | while IFS= read -r f; do
      [ -n "$f" ] || continue
      git checkout --theirs -- "$f"
      git add "$f"
    done
    git commit --no-edit
  else
    echo "ERROR: conflict source saat pull."
    git status --short
    exit 1
  fi
fi

if [ "$STASHED" -eq 1 ]; then
  STASH_REF=$(git stash list | awk -v m="$STASH_NAME" 'index($0,m){sub(/:.*/,"",$0); print; exit}')
  if [ -n "$STASH_REF" ]; then
    if git stash apply "$STASH_REF"; then
      git stash drop "$STASH_REF" >/dev/null
    else
      echo "ERROR: perubahan lokal bertabrakan dengan perubahan GitHub."
      echo "Stash tetap aman: $STASH_REF"
      exit 1
    fi
  fi
fi

echo "==> Build"
sh tools/build.sh

git add -A
if git diff --cached --quiet; then
  echo "INFO: tidak ada perubahan untuk commit."
else
  git commit -m "$MSG"
fi

git fetch origin main
if ! git merge --no-edit origin/main; then
  CONFLICTS=$(git diff --name-only --diff-filter=U 2>/dev/null || true)
  NONPDF=$(printf '%s\n' "$CONFLICTS" | grep -v '\.pdf$' || true)
  if [ -n "$CONFLICTS" ] && [ -z "$NONPDF" ]; then
    # PDF lokal baru dibangun dari source terkini, jadi pilih hasil build lokal.
    printf '%s\n' "$CONFLICTS" | while IFS= read -r f; do
      [ -n "$f" ] || continue
      git checkout --ours -- "$f"
      git add "$f"
    done
    git commit --no-edit
  else
    echo "ERROR: conflict source sebelum push."
    git status --short
    exit 1
  fi
fi

git push origin main

LOCAL_SHA=$(git rev-parse HEAD)
REMOTE_SHA=$(git ls-remote origin refs/heads/main | awk '{print $1}')
[ "$LOCAL_SHA" = "$REMOTE_SHA" ] || {
  echo "ERROR: push tidak terverifikasi"
  exit 1
}

echo "BERHASIL: sync + build + push"
echo "SHA: $LOCAL_SHA"
