# tools

Layout tooling for this Corne keymap.

## Render the keymap (SVG / PNG / HTML preview)

`render.sh` uses [keymap-drawer](https://github.com/caksoylar/keymap-drawer) to turn
`config/corne.keymap` into an SVG, a PNG, and an auto-refreshing HTML preview. Legend
translation (US HID -> the characters a **UK `gb extd`** host will actually type) is
generated into `keymap_drawer.config.yaml` by `gen_uk_config.py`.

```bash
./tools/render.sh
# -> tools/out/corne.svg, corne.png, keymap.html
```

### One-time setup

```bash
python3 -m venv tools/.venv
tools/.venv/bin/pip install keymap-drawer
# optional, for PNG:
sudo pacman -S librsvg      # provides rsvg-convert
```

`render.sh` also falls back to a venv at `~/code/corne-tools/.venv`.

## Watch mode

`watch.sh` re-renders whenever `config/corne.keymap` changes (open `tools/out/keymap.html`):

```bash
./tools/watch.sh
```

## Test the keyboard

`test-keys.py` live-prints the HID key events reaching the host (needs `sudo`, or membership
of the `input` group):

```bash
sudo python3 tools/test-keys.py
```

## Files

- `render.sh` — keymap -> SVG/PNG/HTML
- `watch.sh` — auto re-render on change
- `gen_uk_config.py` — regenerates `keymap_drawer.config.yaml` (US HID -> UK output legends)
- `keymap_drawer.config.yaml` — generated legend config used by keymap-drawer
- `test-keys.py` — raw key-event monitor
