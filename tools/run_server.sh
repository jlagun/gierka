#!/usr/bin/env bash
# Starts a dedicated server without a window. Extra arguments go to the game,
# for example: tools/run_server.sh --port 7778
# Uses the Godot executable in $GODOT, or `godot` from your PATH.
set -euo pipefail

GODOT="${GODOT:-godot}"
GAME="$(cd "$(dirname "$0")/../game" && pwd)"

# A fresh clone has no import cache yet, and the game can't start without it.
if [ ! -d "$GAME/.godot" ]; then
  "$GODOT" --headless --path "$GAME" --import
fi
exec "$GODOT" --headless --path "$GAME" -- --server "$@"
