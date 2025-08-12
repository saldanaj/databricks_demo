# databricks_demo

Demo of Databricks Asset Bundles (DAB): develop locally, sync notebooks, deploy a job and a DLT pipeline, and run them using the Databricks CLI.

## Prerequisites
- Databricks workspace URL (e.g., https://adb-xxxxxxxxxxxx.azuredatabricks.net)
- Databricks CLI (installed by `scripts/install_databricks_cli.sh`)
- For remote/devcontainer environments (e.g., Codespaces): Azure CLI is recommended for auth

## Authenticate
Choose one of the following:

Option A — Azure CLI device login (recommended for Codespaces/containers)
```bash
# Install CLI (once)
chmod +x scripts/*.sh || true
scripts/install_databricks_cli.sh

# Sign in to Azure via device code (opens a code you enter in your local browser)
az login --use-device-code

# Create/set a Databricks CLI profile that uses Azure CLI tokens
# Replace URL with your workspace URL
export DATABRICKS_CONFIG_PROFILE=codespaces
cat >> "$HOME/.databrickscfg" <<'EOF'
[codespaces]
host = https://<your-workspace-url>
auth_type = azure-cli
EOF

# Verify
databricks -p "$DATABRICKS_CONFIG_PROFILE" auth describe
```

Option B — Browser-based login (best on a local machine with a default browser)
```bash
# Install CLI (once)
chmod +x scripts/*.sh || true
scripts/install_databricks_cli.sh

# Start login (replace URL)
scripts/databricks_login.sh https://<your-workspace-url>

# If you see "state mismatch" in a container, prefer Option A
```

## Environment
Set the workspace host for bundle commands and, if using a profile, set it globally:
```bash
export WORKSPACE_HOST=https://<your-workspace-url>
# If you used Option A above
export DATABRICKS_CONFIG_PROFILE=codespaces
```

## Setup and run
```bash
cd /workspaces/databricks_demo

# 1) Validate bundle (requires WORKSPACE_HOST)
scripts/bundle_validate.sh

# 2) Start bidirectional file sync (keeps running)
scripts/bundle_sync.sh

# In another terminal:
# 3) Deploy resources (job + pipeline)
scripts/bundle_deploy.sh

# 4) Run the job
scripts/run_job.sh

# 5) Start the DLT pipeline
scripts/run_pipeline.sh
```

## Customization
- Attach the notebook job to an existing cluster:
```bash
export BUNDLE_VARS="existing_cluster_id=<your-cluster-id>"
```
- If Unity Catalog is enabled for DLT:
```bash
export BUNDLE_VARS="${BUNDLE_VARS} catalog=<your-catalog>"
```

Bundle configuration lives in `databricks.yml`. Notebooks are under `notebooks/`.

## Troubleshooting
- OAuth state mismatch during login: common in remote/devcontainers when multiple browsers launch. Use Azure CLI auth (Option A) instead.
- Error: parse "https://${var.workspace_host}": Set `WORKSPACE_HOST` before running bundle commands.
- Multiple CLI versions detected (extension vs. legacy): this is informational; the newer CLI will be used automatically. You can ignore it.
