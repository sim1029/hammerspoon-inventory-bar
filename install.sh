#!/usr/bin/env bash
# Installs the Hammerspoon Inventory Bar config into ~/.hammerspoon/init.lua
# Backs up any existing init.lua first.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="$HOME/.hammerspoon"
DEST="$DEST_DIR/init.lua"

mkdir -p "$DEST_DIR"

if [ -f "$DEST" ]; then
  BACKUP="$DEST.bak.$(date +%Y%m%d%H%M%S)"
  cp "$DEST" "$BACKUP"
  echo "Backed up existing config -> $BACKUP"
fi

cp "$SRC_DIR/init.lua" "$DEST"
echo "Installed init.lua -> $DEST"

if [ -d "/Applications/Hammerspoon.app" ] || [ -d "$HOME/Applications/Hammerspoon.app" ]; then
  echo "Hammerspoon is installed. Launch it (open -a Hammerspoon) and grant Accessibility permission."
else
  echo "Hammerspoon not found. Install it first:  brew install --cask hammerspoon"
fi

echo "Done. Slots start empty — assign apps with Alt+Cmd+<n>."
