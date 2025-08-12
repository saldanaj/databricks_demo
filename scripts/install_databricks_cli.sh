#!/usr/bin/env bash
# Installs the modern Databricks CLI (Go-based) on Ubuntu/Debian.
# Safe to re-run; will upgrade if already installed. Falls back to legacy python CLI only if needed.

set -euo pipefail

if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
fi

echo "[install] Updating apt package index..."
$SUDO apt-get update -y

echo "[install] Installing prerequisites (curl, bash, core utils; plus python3/pipx for fallback)..."
$SUDO apt-get install -y curl ca-certificates bash coreutils python3 python3-venv pipx || true

echo "[install] Installing/Upgrading modern Databricks CLI (official script)..."
# Install to ~/.databricks/bin
export DATABRICKS_BIN_DIR="$HOME/.databricks/bin"
mkdir -p "$DATABRICKS_BIN_DIR"

set +e
curl -fsSL https://github.com/databricks/cli/releases/latest/download/install.sh | bash
STATUS=$?
set -e

# Ensure the CLI bin dir is at the front of PATH for this session and future shells
export PATH="$DATABRICKS_BIN_DIR:$HOME/.local/bin:$PATH"
if ! grep -q 'export PATH=.*\.databricks/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.databricks/bin:$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "[install] Verifying modern CLI and bundle support..."
if command -v databricks >/dev/null 2>&1; then
  databricks version || databricks --version || true
  if databricks bundle --help >/dev/null 2>&1; then
    echo "[install] Modern CLI with bundle support is ready."
    echo "[install] Done. You can now authenticate with: scripts/databricks_login.sh <https://your-workspace-url>"
    exit 0
  fi
fi

echo "[install] Modern CLI install didn't expose 'bundle'. Installing legacy python CLI as fallback..."

echo "[install] Ensuring pipx is on PATH..."
pipx ensurepath || true
export PATH="$HOME/.local/bin:$PATH"

if ! pipx install --force databricks-cli; then
  echo "[install] Falling back to user-level pip install..."
  python3 -m pip install --user --upgrade pip || true
  python3 -m pip install --user --upgrade databricks-cli || true
fi

echo "[install] Verifying Databricks CLI installation..."
if ! command -v databricks >/dev/null 2>&1; then
  echo "[error] 'databricks' command not found on PATH after install. Ensure ~/.databricks/bin and ~/.local/bin are in PATH." >&2
  echo "        Try: echo 'export PATH=\"$HOME/.databricks/bin:$HOME/.local/bin:$PATH\"' >> ~/.bashrc && source ~/.bashrc" >&2
  exit 1
fi

databricks --version 2>/dev/null || databricks version 2>/dev/null || true
echo "[install] Note: legacy Python CLI may not support bundles. Prefer the modern CLI for DAB."

echo "[install] Done. You can now authenticate with: scripts/databricks_login.sh <https://your-workspace-url>"
