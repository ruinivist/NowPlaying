#!/bin/bash

# Get the directory where the script is located.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/package"
PLASMOID_NAME=$(grep -oP '"Id": "\K[^"]+' "$PACKAGE_DIR/metadata.json")

# Check for inotify-tools.
if ! command -v inotifywait &> /dev/null; then
    echo "Error: inotify-tools is typically not installed."
    echo "Please install it with your package manager (e.g., sudo apt install inotify-tools)"
    exit 1
fi

echo "Found Widget ID: $PLASMOID_NAME"
echo "Starting Hot Reload Watcher..."
echo "Press Ctrl+C to stop."

# Cleanup function to kill the viewer when the script exits.
cleanup() {
    echo -e "\nStopping watcher..."
    if [ -n "$PID" ]; then
        kill "$PID" 2>/dev/null
    fi
    exit
}

trap cleanup SIGINT SIGTERM

# Initial start.
echo -e "\n[$(date +%T)] Starting plasmoidviewer..."
plasmoidviewer -a "$PACKAGE_DIR" &
PID=$!

# Watch loop.
while true; do
    # Wait for any file modification in the package directory.
    inotifywait -r -e modify -e create -e delete "$PACKAGE_DIR" -q

    echo -e "\n[$(date +%T)] Change detected! Reloading..."

    # Kill the current instance.
    if [ -n "$PID" ]; then
        kill "$PID" 2>/dev/null
        wait "$PID" 2>/dev/null
    fi

    # Small delay to let Qt/KDE clean up properly.
    sleep 0.5

    # Restart with absolute path.
    plasmoidviewer -a "$PACKAGE_DIR" &
    PID=$!
done
