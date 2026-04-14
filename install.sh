#!/usr/bin/env bash

echo ""
echo "📦 Installing pip-analyzer..."

INSTALL_DIR="$HOME/.local/share/pip-analyzer"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/pip-analyze.ps1" "$INSTALL_DIR/"

# Criar wrapper
cat > "$BIN_DIR/pip-analyze" <<EOF
#!/usr/bin/env pwsh
pwsh "$INSTALL_DIR/pip-analyze.ps1" "\$@"
EOF

chmod +x "$BIN_DIR/pip-analyze"

echo ""
echo "⚠️ Make sure ~/.local/bin is in your PATH"

echo "Example:"
echo 'export PATH="$HOME/.local/bin:$PATH"'

echo ""
echo "🎉 Installation complete!"
echo "👉 Run: pip-analyze"
echo ""