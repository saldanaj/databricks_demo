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

echo "[login] Starting external-browser auth"
LOGIN_TIMEOUT="${LOGIN_TIMEOUT:-5m}"
echo "[login] Using timeout: $LOGIN_TIMEOUT (override with LOGIN_TIMEOUT env var)"

# Stream output, capture to a temp file, and try to auto-open the URL in the host browser if printed.
TMP_LOG=$(mktemp -t dblogin.XXXXXX)
cleanup() { rm -f "$TMP_LOG" 2>/dev/null || true; }
trap cleanup EXIT

set +e
(
  # Start login and tee output for real-time viewing and URL detection
  # Unset BROWSER to prevent CLI from auto-opening a browser that can cause state mismatches in remote dev environments
  OLD_BROWSER="${BROWSER:-}"
  unset BROWSER
  databricks auth login "$HOST_URL" --timeout "$LOGIN_TIMEOUT" 2>&1 | tee "$TMP_LOG"
  export BROWSER="$OLD_BROWSER"
) &
LOGIN_PID=$!

# Wait for login to finish
wait "$LOGIN_PID"
STATUS=$?
set -e

if [[ $STATUS -ne 0 ]]; then
  echo "[login] Login command exited with status $STATUS" >&2
  if grep -q "state mismatch" "$TMP_LOG" 2>/dev/null; then
    echo "[hint] OAuth state mismatch detected. This can happen when a browser is auto-opened in a remote/devcontainer environment." >&2
    echo "[hint] We prevented auto-open, but if it still fails, try these options:" >&2
    echo "       1) Copy the printed URL and open it manually in your local browser (if shown)." >&2
    if command -v az >/dev/null 2>&1; then
      echo "       2) Use Azure CLI auth fallback (recommended in Codespaces):" >&2
      echo "          - Run: az login --use-device-code" >&2
      echo "          - Then: set up a Databricks profile using azure-cli tokens." >&2
      PROFILE_NAME="${DATABRICKS_PROFILE:-codespaces}"
      CFG_FILE="$HOME/.databrickscfg"
      mkdir -p "$(dirname "$CFG_FILE")"
      {
        echo "[$PROFILE_NAME]"
        echo "host = $HOST_URL"
        echo "auth_type = azure-cli"
      } >> "$CFG_FILE"
      echo "[login] Created/updated profile '$PROFILE_NAME' in $CFG_FILE with azure-cli auth." >&2
      echo "[login] If you just ran 'az login', retry commands with: databricks -p $PROFILE_NAME ..." >&2
      # Try to describe with the new profile (won't fail the script if az isn't logged in yet)
      set +e
      databricks -p "$PROFILE_NAME" auth describe || true
      set -e
    else
      echo "       2) Or generate a PAT in the workspace UI and run: databricks auth login $HOST_URL --timeout $LOGIN_TIMEOUT" >&2
    fi
  fi
  exit $STATUS
fi

# Show auth description (if logged in)
set +e
databricks auth describe --host "$HOST_URL" || true
set -e
