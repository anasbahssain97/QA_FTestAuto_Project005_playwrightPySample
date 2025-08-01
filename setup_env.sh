#!/usr/bin/env bash
set -euo pipefail

VENV_DIR="${VENV_DIR:-./venv}"
REQ_FILE="${REQ_FILE:-requirements.txt}"
PYTHON_EXE="${PYTHON_EXE:-$VENV_DIR/bin/python}"
PIP_EXE="${PIP_EXE:-$VENV_DIR/bin/pip}"
CACHE_HASH_FILE="$VENV_DIR/.requirements_hash"

print_header() {
  echo -e "\n============================================================"
  echo "  $1"
  echo "============================================================"
}

# 1) Create virtual environment only if it doesn't exist
print_header "Creating virtual environment (if needed)"
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

# 2) Smart pip install based on hash
print_header "Installing Python dependencies (if needed)"
REQ_HASH=$(md5sum "$REQ_FILE" | cut -d' ' -f1)
if [ ! -f "$CACHE_HASH_FILE" ] || ! grep -q "$REQ_HASH" "$CACHE_HASH_FILE"; then
  "$PIP_EXE" install --upgrade pip setuptools wheel
  "$PIP_EXE" install --no-cache-dir --default-timeout=100 -r "$REQ_FILE"
  echo "$REQ_HASH" > "$CACHE_HASH_FILE"
else
  echo "✅ Requirements unchanged. Skipping pip install."
fi

# 3) Install Playwright browsers
print_header "Installing Playwright browsers"
"$PYTHON_EXE" -m playwright install

print_header "Setup complete ✅"
