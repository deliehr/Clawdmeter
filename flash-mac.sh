#!/bin/bash
# Build and flash Clawdmeter firmware on macOS.
# Usage:
#   ./flash-mac.sh <board>                       # auto-detect /dev/cu.usbmodem*
#   ./flash-mac.sh <board> /dev/cu.usbmodem1101  # explicit USB serial port
#   ./flash-mac.sh --clean <board> [port]        # wipe build artifacts first
#
# <board> is the PlatformIO env name, e.g. waveshare_amoled_216 or waveshare_amoled_18.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLEAN=0
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --clean) CLEAN=1 ;;
        *) ARGS+=("$arg") ;;
    esac
done
BOARD="${ARGS[0]}"
PORT="${ARGS[1]}"

if [ -z "$BOARD" ]; then
    echo "Error: board env name is required."
    echo "Usage: $0 [--clean] <board> [port]"
    echo "Available boards:"
    grep -E '^\[env:' "$SCRIPT_DIR/firmware/platformio.ini" | sed 's/\[env:/  /;s/\]//'
    exit 1
fi

if [ -z "$PORT" ]; then
    PORT=$(ls /dev/cu.usbmodem* 2>/dev/null | head -1)
    if [ -z "$PORT" ]; then
        echo "Error: no /dev/cu.usbmodem* device found. Plug in via USB-C."
        exit 1
    fi
fi

if ! command -v pio >/dev/null; then
    echo "Error: 'pio' not found. Install with:"
    echo "  brew install platformio"
    exit 1
fi

echo "=== Flashing Clawdmeter ==="
echo "Board: $BOARD"
echo "Port:  $PORT"
[ "$CLEAN" = 1 ] && echo "Clean: yes"
echo ""

cd "$SCRIPT_DIR/firmware"
if [ "$CLEAN" = 1 ]; then
    pio run -e "$BOARD" -t clean
fi
pio run -e "$BOARD" -t upload --upload-port "$PORT"

echo ""
echo "=== Done ==="
echo "Monitor with: pio device monitor -p $PORT -b 115200"
