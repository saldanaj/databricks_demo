#!/usr/bin/env bash
set -euo pipefail

: "${WORKSPACE_HOST:?Set WORKSPACE_HOST to your workspace URL}"

PIPELINE_NAME="demo_dlt_pipeline"

databricks bundle run -t dev "${PIPELINE_NAME}" --var workspace_host="${WORKSPACE_HOST}" ${BUNDLE_VARS:+--var ${BUNDLE_VARS}}
