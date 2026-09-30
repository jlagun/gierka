#!/usr/bin/env bash
# Smoke test: starts a dedicated server and two bot clients, all without windows.
# It passes when each bot has seen the other one move, and nobody logged an error
# or a warning.
#
# Usage: tools/smoke_test.sh
# Uses the Godot executable in $GODOT, or `godot` from your PATH.
set -euo pipefail

GODOT="${GODOT:-godot}"
GAME="$(cd "$(dirname "$0")/../game" && pwd)"
PORT="${SMOKE_TEST_PORT:-7787}"
LOGS="$(mktemp -d)"
server_pid=""

stop_server() {
  if [ -n "$server_pid" ]; then
    kill "$server_pid" 2>/dev/null || true
  fi
}
trap stop_server EXIT

echo "Importing the project..."
if ! "$GODOT" --headless --path "$GAME" --import >"$LOGS/import.log" 2>&1; then
  cat "$LOGS/import.log"
  echo "Import failed."
  exit 1
fi

echo "Starting a dedicated server on UDP port $PORT..."
"$GODOT" --headless --path "$GAME" -- --server --port "$PORT" >"$LOGS/server.log" 2>&1 &
server_pid=$!
for _ in $(seq 1 50); do
  if grep -q "Server listening" "$LOGS/server.log"; then
    break
  fi
  sleep 0.2
done
if ! grep -q "Server listening" "$LOGS/server.log"; then
  cat "$LOGS/server.log"
  echo "The server didn't start."
  exit 1
fi

echo "Starting two bot clients..."
"$GODOT" --headless --path "$GAME" -- --connect 127.0.0.1 --port "$PORT" --name BotA --bot >"$LOGS/bot_a.log" 2>&1 &
bot_a=$!
"$GODOT" --headless --path "$GAME" -- --connect 127.0.0.1 --port "$PORT" --name BotB --bot >"$LOGS/bot_b.log" 2>&1 &
bot_b=$!

status=0
wait "$bot_a" || status=1
wait "$bot_b" || status=1

if grep -E "SCRIPT ERROR|^ERROR:|^WARNING:" "$LOGS/import.log" "$LOGS/server.log" "$LOGS/bot_a.log" "$LOGS/bot_b.log"; then
  echo "Errors or warnings were logged (listed above)."
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "Smoke test passed: both bots saw each other move."
else
  for log in server bot_a bot_b; do
    echo "--- $log.log"
    cat "$LOGS/$log.log"
  done
  echo "Smoke test FAILED. The logs are in $LOGS"
fi
exit "$status"
