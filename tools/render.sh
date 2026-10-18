#!/usr/bin/env bash
#
# Render the Corne ZMK keymap to SVG + PNG using keymap-drawer.
#
# Run from anywhere; renders <repo>/config/corne.keymap into tools/out/.
#   ./tools/render.sh
#
# Needs keymap-drawer. Either a venv at tools/.venv, or the one at
# ~/code/corne-tools/.venv (see tools/README.md).
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${CORNE_REPO:-$(cd "$HERE/.." && pwd)}"
OUT="$HERE/out"
KEYMAP="$REPO/config/corne.keymap"

KEYMAPDRAW="${KEYMAPDRAW:-$HERE/.venv/bin/keymap}"
[ -x "$KEYMAPDRAW" ] || KEYMAPDRAW="$HOME/code/corne-tools/.venv/bin/keymap"
if [ ! -x "$KEYMAPDRAW" ]; then
  echo "keymap-drawer not found. See tools/README.md." >&2
  exit 1
fi
[ -f "$KEYMAP" ] || { echo "Keymap not found: $KEYMAP" >&2; exit 1; }

mkdir -p "$OUT"
CONFIG="$HERE/keymap_drawer.config.yaml"

"$KEYMAPDRAW" -c "$CONFIG" parse -z "$KEYMAP" -o "$OUT/corne.yaml"
"$KEYMAPDRAW" -c "$CONFIG" draw -z corne "$OUT/corne.yaml" -o "$OUT/corne.svg"

if command -v rsvg-convert >/dev/null 2>&1; then
  rsvg-convert -b white -o "$OUT/corne.png" "$OUT/corne.svg"
fi

cat > "$OUT/keymap.html" <<'HTML'
<!doctype html>
<meta charset="utf-8">
<meta http-equiv="refresh" content="2">
<title>Corne keymap</title>
<style>html,body{margin:0;background:#fff}img{max-width:1100px;width:100%;display:block;margin:0 auto}</style>
<img src="corne.svg" alt="Corne keymap">
HTML

echo "Rendered from $KEYMAP:"
ls -la "$OUT/corne.svg" "$OUT/corne.png" 2>/dev/null
