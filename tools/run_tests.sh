#!/usr/bin/env bash
# Runs the GUT unit tests in game/tests/unit, without a window.
#
# Usage: tools/run_tests.sh
# Uses the Godot executable in $GODOT, or `godot` from your PATH.
set -euo pipefail

GODOT="${GODOT:-godot}"
GAME="$(cd "$(dirname "$0")/../game" && pwd)"

IMPORT_LOG="$(mktemp)"
trap 'rm -f "$IMPORT_LOG"' EXIT

# A fresh clone has no import cache yet, and GUT can't find our classes without
# it. The import prints a lot, so its output is only shown when it fails.
if ! "$GODOT" --headless --path "$GAME" --import >"$IMPORT_LOG" 2>&1; then
  cat "$IMPORT_LOG"
  echo "The project import failed (output above)."
  exit 1
fi
"$GODOT" --headless --path "$GAME" -s addons/gut/gut_cmdln.gd "$@"
