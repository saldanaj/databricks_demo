#!/usr/bin/env bash
set -euo pipefail

# Prefer DATABRICKS_HOST; support WORKSPACE_HOST for convenience
if [[ -n "${WORKSPACE_HOST:-}" && -z "${DATABRICKS_HOST:-}" ]]; then
	export DATABRICKS_HOST="${WORKSPACE_HOST}"
fi

# Determine profile argument
PROFILE_ARG=()
if [[ -n "${DATABRICKS_CONFIG_PROFILE:-}" ]]; then
	PROFILE_ARG=(-p "${DATABRICKS_CONFIG_PROFILE}")
elif grep -q "^\[codespaces\]$" "$HOME/.databrickscfg" 2>/dev/null; then
	PROFILE_ARG=(-p codespaces)
fi

databricks "${PROFILE_ARG[@]}" bundle validate -t dev ${BUNDLE_VARS:+--var ${BUNDLE_VARS}}
