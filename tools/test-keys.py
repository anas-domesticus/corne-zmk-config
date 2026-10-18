#!/usr/bin/env python3
"""Live-monitor the Corne keyboard's raw key events.

Run it with sudo (you're not in the 'input' group):

    sudo python3 tools/test-keys.py

Then press keys on the LEFT half, then the RIGHT half.
Every key that reaches the computer is printed. If right-half keys never
appear, the wireless split link is down (or the right half is off/flat).
Ctrl+C to stop.
"""
import glob
import os
import struct
import sys

EV_KEY = 1
FMT = "llHHi"                 # struct input_event (x86_64, no padding)
SIZE = struct.calcsize(FMT)   # 24 bytes


def load_key_names():
    names = {}
    for path in (
        "/usr/include/linux/input-event-codes.h",
        "/usr/include/linux/input.h",
    ):
        if not os.path.exists(path):
            continue
        with open(path) as fh:
            for line in fh:
                if line.startswith("#define KEY_"):
                    parts = line.split()
                    if len(parts) >= 3:
                        try:
                            names[int(parts[2], 0)] = parts[1][4:]
                        except ValueError:
                            pass
        if names:
            break
    return names


def find_corne():
    for path in glob.glob("/sys/class/input/event*/device/name"):
        try:
            name = open(path).read().strip()
        except OSError:
            continue
        if "Corne" in name or "ZMK" in name:
            event = "/dev/input/" + path.split("/")[4]
            return event, name
    return None, None


def main():
    event, name = find_corne()
    if not event:
        print("No ZMK/Corne input device found.")
        print("Is the CENTRAL (left) half plugged into USB, or paired over Bluetooth?")
        sys.exit(1)

    print(f"Monitoring: {name}")
    print(f"Device:     {event}")
    print("Press keys on the LEFT half, then the RIGHT half. Ctrl+C to stop.\n")

    names = load_key_names()
    with open(event, "rb") as fh:
        while True:
            data = fh.read(SIZE)
            if not data or len(data) < SIZE:
                break
            _sec, _usec, etype, code, value = struct.unpack(FMT, data)
            if etype != EV_KEY or value not in (0, 1):
                continue
            state = "DOWN" if value == 1 else "up"
            print(f"  {names.get(code, str(code)):>12}  {state}", flush=True)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nstopped.")
