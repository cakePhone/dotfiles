#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="${1:-$HOME/.local/bin/ags-bar}"

mkdir -p "$(dirname "$OUTPUT")"
ags bundle "$SCRIPT_DIR/app.tsx" "$OUTPUT"
chmod +x "$OUTPUT"
echo "bundled to $OUTPUT"
