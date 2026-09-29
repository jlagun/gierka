#!/usr/bin/env bash
# Starts the game with the main menu. Extra arguments go to the game, for example:
#   tools/run_client.sh --connect 100.64.0.1 --name Kuba
#   tools/run_client.sh --host --name Kuba
# Uses the Godot executable in $GODOT, or `godot` from your PATH.
set -euo pipefail

GODOT="${GODOT:-godot}"
GAME="$(cd "$(dirname "$0")/../game" && pwd)"

# A fresh clone has no import cache yet, and the game can't start without it.
if [ ! -d "$GAME/.godot" ]; then
  "$GODOT" --headless --path "$GAME" --import
fi
exec "$GODOT" --path "$GAME" -- "$@"
