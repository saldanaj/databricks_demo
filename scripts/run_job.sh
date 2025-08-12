#!/usr/bin/env bash
set -euo pipefail

: "${WORKSPACE_HOST:?Set WORKSPACE_HOST to your workspace URL}"

JOB_NAME="demo_notebook_job"

databricks bundle run -t dev "${JOB_NAME}" --var workspace_host="${WORKSPACE_HOST}" ${BUNDLE_VARS:+--var ${BUNDLE_VARS}}
