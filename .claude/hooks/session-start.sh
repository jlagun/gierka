#!/bin/bash
# SessionStart hook for Claude Code on the web (cloud sessions). It installs the
# tools this project needs, Godot and gdtoolkit, so a cloud session can run the
# smoke test and the linters. On your own machines it does nothing.
#
# When you upgrade Godot (see CLAUDE.md), change GODOT_VERSION here too.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

GODOT_VERSION="4.7.2"
GDTOOLKIT_VERSION="4.5.0"
TOOLS_DIR="$HOME/.local/share/bursa-tales-tools"
BIN_DIR="$TOOLS_DIR/bin"
GODOT_BIN="$TOOLS_DIR/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
GDTOOLKIT_VENV="$TOOLS_DIR/gdtoolkit-$GDTOOLKIT_VERSION"

mkdir -p "$BIN_DIR"

# Both installs are skipped when the cached container already has them.
if [ ! -x "$GODOT_BIN" ]; then
  echo "Installing Godot $GODOT_VERSION..."
  curl -fsSL -o "$TOOLS_DIR/godot.zip" \
    "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
  python3 -m zipfile -e "$TOOLS_DIR/godot.zip" "$TOOLS_DIR"
  rm "$TOOLS_DIR/godot.zip"
  chmod +x "$GODOT_BIN"
fi

if [ ! -x "$GDTOOLKIT_VENV/bin/gdlint" ]; then
  echo "Installing gdtoolkit $GDTOOLKIT_VERSION..."
  python3 -m venv "$GDTOOLKIT_VENV"
  "$GDTOOLKIT_VENV/bin/pip" install --quiet --disable-pip-version-check "gdtoolkit==$GDTOOLKIT_VERSION"
fi

ln -sf "$GODOT_BIN" "$BIN_DIR/godot"
ln -sf "$GDTOOLKIT_VENV/bin/gdlint" "$BIN_DIR/gdlint"
ln -sf "$GDTOOLKIT_VENV/bin/gdformat" "$BIN_DIR/gdformat"

# The project's scripts read GODOT; PATH makes godot, gdlint and gdformat available.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export GODOT=\"$BIN_DIR/godot\"" >>"$CLAUDE_ENV_FILE"
  echo "export PATH=\"$BIN_DIR:\$PATH\"" >>"$CLAUDE_ENV_FILE"
fi

echo "Cloud session tools ready: Godot $("$BIN_DIR/godot" --version), gdtoolkit $GDTOOLKIT_VERSION"
