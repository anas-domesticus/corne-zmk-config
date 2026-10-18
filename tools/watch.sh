#!/usr/bin/env bash
#
# Watch the Corne keymap and re-render whenever it changes.
# Open out/keymap.html in a browser for a live-updating preview.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${CORNE_REPO:-$HOME/code/corne-zmk-config}"
KEYMAP="$REPO/config/corne.keymap"

echo "Watching $KEYMAP (Ctrl+C to stop)"
echo "Open: $HERE/out/keymap.html"

last=""
while true; do
  cur="$(md5sum "$KEYMAP" 2>/dev/null | awk '{print $1}')"
  if [ -n "$cur" ] && [ "$cur" != "$last" ]; then
    if "$HERE/render.sh" >/dev/null 2>&1; then
      echo "[$(date +%H:%M:%S)] re-rendered"
      last="$cur"
    fi
  fi
  sleep 1
done
