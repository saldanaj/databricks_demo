#!/usr/bin/env bash
set -euo pipefail

: "${WORKSPACE_HOST:?Set WORKSPACE_HOST to your workspace URL}"

databricks bundle sync -t dev --watch --var workspace_host="${WORKSPACE_HOST}" ${BUNDLE_VARS:+--var ${BUNDLE_VARS}}
