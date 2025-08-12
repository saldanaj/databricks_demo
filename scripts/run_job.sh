#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${WORKSPACE_HOST:-}" && -z "${DATABRICKS_HOST:-}" ]]; then
	export DATABRICKS_HOST="${WORKSPACE_HOST}"
fi

PROFILE_ARG=()
if [[ -n "${DATABRICKS_CONFIG_PROFILE:-}" ]]; then
	PROFILE_ARG=(-p "${DATABRICKS_CONFIG_PROFILE}")
elif grep -q "^\[codespaces\]$" "$HOME/.databrickscfg" 2>/dev/null; then
	PROFILE_ARG=(-p codespaces)
fi

JOB_NAME="demo_notebook_job"

databricks "${PROFILE_ARG[@]}" bundle run -t dev "${JOB_NAME}" ${BUNDLE_VARS:+--var ${BUNDLE_VARS}}
