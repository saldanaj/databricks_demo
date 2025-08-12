#!/usr/bin/env bash
# Helper for OAuth/SSO login using external browser.
# Usage: scripts/databricks_login.sh https://<your-workspace-url>

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 https://<your-workspace-url>" >&2
  exit 2
fi

HOST_URL="$1"

if ! command -v databricks >/dev/null 2>&1; then
  echo "[error] databricks CLI not found; run scripts/install_databricks_cli.sh first" >&2
  exit 1
fi

echo "[login] Starting external-browser auth for host: $HOST_URL"
set +e
LOGIN_OUTPUT=$(databricks auth login --host "$HOST_URL" --auth-type external-browser 2>&1)
STATUS=$?
set -e

echo "$LOGIN_OUTPUT"

# If CLI printed a URL (device flow), try to open with host browser variable if available
LOGIN_URL=$(echo "$LOGIN_OUTPUT" | grep -Eo 'https?://[^ ]+') || true
if [[ -n "${LOGIN_URL:-}" ]]; then
  if [[ -n "${BROWSER:-}" ]]; then
    echo "[login] Opening login URL in host browser via $BROWSER"
    $BROWSER "$LOGIN_URL" >/dev/null 2>&1 || true
  fi
fi

# Show identity (if logged in)
set +e
databricks auth whoami
set -e
