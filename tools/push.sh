#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MSG=${1:-"Update PIDK $(date '+%Y-%m-%d %H:%M')"}
exec sh "$ROOT/tools/sync.sh" "$MSG"
