#!/usr/bin/env bash
# Starts a dedicated server without a window. Extra arguments go to the game,
# for example: tools/run_server.sh --port 7778
# Uses the Godot executable in $GODOT, or `godot` from your PATH.
set -euo pipefail

GODOT="${GODOT:-godot}"
GAME="$(cd "$(dirname "$0")/../game" && pwd)"

# Import every time, not only on a fresh clone. After a branch switch, the old
# import makes scripts that use new classes fail to load, and the game still
# starts. With nothing to update it takes a few seconds. Only errors and
# warnings from the import are shown.
import_log="$("$GODOT" --headless --path "$GAME" --import 2>&1 || true)"
grep -E "SCRIPT ERROR|^ERROR:|^WARNING:" <<<"$import_log" || true
exec "$GODOT" --headless --path "$GAME" -- --server "$@"
