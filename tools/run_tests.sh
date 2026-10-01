#!/usr/bin/env bash
# Runs the GUT unit tests in game/tests/unit, without a window.
#
# Usage: tools/run_tests.sh
# Uses the Godot executable in $GODOT, or `godot` from your PATH.
set -euo pipefail

GODOT="${GODOT:-godot}"
GAME="$(cd "$(dirname "$0")/../game" && pwd)"

# A fresh clone has no import cache yet, and GUT can't find our classes without it.
"$GODOT" --headless --path "$GAME" --import >/dev/null 2>&1
exec "$GODOT" --headless --path "$GAME" -s addons/gut/gut_cmdln.gd "$@"
