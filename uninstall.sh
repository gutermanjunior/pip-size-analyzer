#!/usr/bin/env bash

echo ""
echo "🧹 Uninstalling pip-analyzer..."

INSTALL_DIR="$HOME/.local/share/pip-analyzer"
BIN_FILE="$HOME/.local/bin/pip-analyze"

if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
fi
rm -f "$BIN_FILE"

echo "✅ Removed pip-analyzer files"

echo ""
echo "🎯 Uninstall complete"
echo ""