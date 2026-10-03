#!/usr/bin/env bash
# Fails if any GDScript file in the project has a warning. Godot only prints
# warnings that are set to Error, so this raises all of them for one run.
#
# Usage: tools/check_warnings.sh
# Uses the Godot executable in $GODOT, or `godot` from your PATH.
set -euo pipefail

GODOT="${GODOT:-godot}"
GAME="$(cd "$(dirname "$0")/../game" && pwd)"
CHECKER="res://tests/check_warnings.gd"

IMPORT_LOG="$(mktemp)"

# The override file only exists for this run, so it never ends up in a commit.
trap 'rm -f "$GAME/override.cfg" "$IMPORT_LOG"' EXIT

# The import prints a lot, so its output is only shown when it fails.
import_project() {
  if ! "$GODOT" --headless --path "$GAME" --import >"$IMPORT_LOG" 2>&1; then
    cat "$IMPORT_LOG"
    echo "The project import failed (output above)."
    exit 1
  fi
}

import_project
"$GODOT" --headless --path "$GAME" -s "$CHECKER" -- --write-override
import_project
"$GODOT" --headless --path "$GAME" -s "$CHECKER"
