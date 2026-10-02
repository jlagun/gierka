#!/bin/bash
# SessionStart hook for Claude Code on the web (cloud sessions). It installs the
# tools this project needs, Godot and gdtoolkit, so a cloud session can run the
# smoke test and the linters. On your own machines it does nothing.
#
# When you upgrade Godot (see CLAUDE.md), change GODOT_VERSION and
# GODOT_ZIP_SHA512 here too, with the same values as in the CI workflow.
#
# The two installs don't depend on each other. If one fails, the other is still
# set up, so the session gets whatever worked. That's why there's no `set -e`.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

GODOT_VERSION="4.7.2"
# From Godot's SHA512-SUMS.txt for this release.
GODOT_ZIP_SHA512="9aa00f7a605200940bce3027a567b782f49bd8e940dd06ae9e987bd65aee1b1467edd56ed84fcdcbdd44354bf613bdbb4e5d2913e925850368e150c59ed54c65"
GDTOOLKIT_VERSION="4.5.0"
TOOLS_DIR="$HOME/.local/share/bursa-tales-tools"
BIN_DIR="$TOOLS_DIR/bin"
GODOT_BIN="$TOOLS_DIR/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
GDTOOLKIT_VENV="$TOOLS_DIR/gdtoolkit-$GDTOOLKIT_VERSION"

install_godot() {
  local zip="$TOOLS_DIR/godot.zip"
  curl -fsSL -o "$zip" \
    "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" &&
    echo "$GODOT_ZIP_SHA512  $zip" | sha512sum --check --quiet &&
    python3 -m zipfile -e "$zip" "$TOOLS_DIR" &&
    chmod +x "$GODOT_BIN"
  local status=$?
  rm -f "$zip"
  return "$status"
}

install_gdtoolkit() {
  python3 -m venv "$GDTOOLKIT_VENV" &&
    "$GDTOOLKIT_VENV/bin/pip" install --quiet --disable-pip-version-check "gdtoolkit==$GDTOOLKIT_VERSION"
}

mkdir -p "$BIN_DIR"
missing=()

# Both installs are skipped when the cached container already has them. A failed
# one leaves no executable behind, so the next session tries again.
if [ ! -x "$GODOT_BIN" ]; then
  echo "Installing Godot $GODOT_VERSION..."
  install_godot || missing+=("Godot")
fi
if [ ! -x "$GDTOOLKIT_VENV/bin/gdlint" ]; then
  echo "Installing gdtoolkit $GDTOOLKIT_VERSION..."
  install_gdtoolkit || missing+=("gdtoolkit")
fi

if [ -x "$GODOT_BIN" ]; then
  ln -sf "$GODOT_BIN" "$BIN_DIR/godot"
fi
for tool in gdlint gdformat; do
  if [ -x "$GDTOOLKIT_VENV/bin/$tool" ]; then
    ln -sf "$GDTOOLKIT_VENV/bin/$tool" "$BIN_DIR/$tool"
  fi
done

# The project's scripts read GODOT; PATH makes godot, gdlint and gdformat available.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  if [ -x "$GODOT_BIN" ]; then
    echo "export GODOT=\"$BIN_DIR/godot\"" >>"$CLAUDE_ENV_FILE"
  fi
  echo "export PATH=\"$BIN_DIR:\$PATH\"" >>"$CLAUDE_ENV_FILE"
fi

if [ ${#missing[@]} -eq 0 ]; then
  echo "Cloud session tools ready: Godot $("$BIN_DIR/godot" --version), gdtoolkit $GDTOOLKIT_VERSION"
else
  echo "Cloud session tools incomplete: ${missing[*]} failed to install (see the errors above). The rest is set up."
fi
