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

# The override file only exists for this run, so it never ends up in a commit.
trap 'rm -f "$GAME/override.cfg"' EXIT

"$GODOT" --headless --path "$GAME" --import >/dev/null 2>&1
"$GODOT" --headless --path "$GAME" -s "$CHECKER" -- --write-override
"$GODOT" --headless --path "$GAME" --import >/dev/null 2>&1
"$GODOT" --headless --path "$GAME" -s "$CHECKER"
