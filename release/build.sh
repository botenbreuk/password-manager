#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "=== Password Manager Build ==="
echo "Project root: $PROJECT_ROOT"

# Install build dependencies
echo ""
echo "--- Installing build dependencies ---"
pip install pyinstaller

# Convert icons (only if not already present)
if [ ! -f "$SCRIPT_DIR/icons/icon.icns" ]; then
    echo ""
    echo "--- Converting icons ---"
    pip install Pillow cairosvg
    python "$SCRIPT_DIR/convert_icon.py"
else
    echo ""
    echo "--- Icons already present, skipping conversion ---"
fi

# Run PyInstaller
echo ""
echo "--- Running PyInstaller ---"
pyinstaller "$SCRIPT_DIR/password_manager.spec" \
    --distpath "$PROJECT_ROOT/dist" \
    --workpath "$PROJECT_ROOT/build" \
    --noconfirm

# Report result
echo ""
echo "=== Build Complete ==="
if [[ "$(uname)" == "Darwin" ]]; then
    OUTPUT="$PROJECT_ROOT/dist/PasswordManager.app"
    if [ -d "$OUTPUT" ]; then
        # Ad-hoc sign so Gatekeeper doesn't block the app on other Macs
        echo ""
        echo "--- Ad-hoc signing macOS app ---"
        codesign --force --deep --sign - "$OUTPUT"
        echo "Signed: $OUTPUT"

        SIZE=$(du -sh "$OUTPUT" | cut -f1)
        echo "Output: $OUTPUT ($SIZE)"
        echo "Run with: open $OUTPUT"
    else
        echo "Error: Expected output not found at $OUTPUT"
        exit 1
    fi
else
    OUTPUT="$PROJECT_ROOT/dist/PasswordManager"
    if [ -f "$OUTPUT" ]; then
        SIZE=$(du -h "$OUTPUT" | cut -f1)
        echo "Output: $OUTPUT ($SIZE)"
    else
        echo "Error: Expected output not found at $OUTPUT"
        exit 1
    fi
fi
