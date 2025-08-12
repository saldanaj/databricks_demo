# databricks_demo

Demo of Databricks Asset Bundles (DAB): develop locally, sync notebooks, deploy a job and a DLT pipeline, and run them using the Databricks CLI.

## Prerequisites
- Databricks workspace URL (e.g., https://adb-xxxxxxxxxxxx.azuredatabricks.net)
- Databricks CLI (installed by `scripts/install_databricks_cli.sh`)
- For remote/devcontainer environments (e.g., Codespaces): Azure CLI is recommended for auth
- **Running cluster** (recommended for faster job execution)

## Quick Start (Codespaces/Devcontainers)
```bash
# 1. Authenticate with Azure CLI (recommended for remote environments)
az login --use-device-code

# 2. Set environment variables
export DATABRICKS_CONFIG_PROFILE=codespaces
export WORKSPACE_HOST=https://<your-workspace-url>

# 3. Deploy and run
scripts/bundle_validate.sh
scripts/bundle_deploy.sh
scripts/run_job.sh
```

## Authenticate
Choose one of the following:

### Option A — Azure CLI device login (recommended for Codespaces/containers)
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

# Verify authentication
databricks -p "$DATABRICKS_CONFIG_PROFILE" auth describe
```

### Option B — Browser-based login (best on a local machine with a default browser)
```bash
# Install CLI (once)
chmod +x scripts/*.sh || true
scripts/install_databricks_cli.sh

# Start login (replace URL)
scripts/databricks_login.sh https://<your-workspace-url>

# If you see "state mismatch" in a container, prefer Option A
```

## Environment Variables
Set these for consistent operation across terminals:
```bash
export WORKSPACE_HOST=https://<your-workspace-url>
export DATABRICKS_CONFIG_PROFILE=codespaces  # If using Option A

# Optional: persist in shell profile
echo 'export WORKSPACE_HOST=https://<your-workspace-url>' >> ~/.bashrc
echo 'export DATABRICKS_CONFIG_PROFILE=codespaces' >> ~/.bashrc
```

## Setup and Run Bundle
```bash
cd /workspaces/databricks_demo

# 1) Validate bundle configuration
scripts/bundle_validate.sh

# 2) Deploy resources (job + pipeline) to workspace
scripts/bundle_deploy.sh

# 3) Optional: Start live file sync (keeps running)
scripts/bundle_sync.sh

# 4) Run the notebook job
scripts/run_job.sh

# 5) Start/update the DLT pipeline
scripts/run_pipeline.sh
```

### Verify Successful Deployment
After running the above commands, you should see:
```bash
# Check deployed notebooks
databricks -p "$DATABRICKS_CONFIG_PROFILE" workspace list \
  "/Workspace/Users/<your-email>/bundles/databricks_demo/dev/files/notebooks"

# Expected output:
# 01_local_notebook    NOTEBOOK  PYTHON
# dlt_pipeline        NOTEBOOK  PYTHON
```

**Success indicators:**
- ✅ `bundle_validate.sh` → "Validation OK!"
- ✅ `bundle_deploy.sh` → "Deployment complete!"
- ✅ `run_job.sh` → "TERMINATED SUCCESS"
- ✅ `run_pipeline.sh` → Pipeline update starts running

## Interactive Development

### Notebooks in VS Code
Three approaches for running notebooks interactively:

**A. Using Databricks Extension (.py files)**
1. Open any `.py` file in `notebooks/` directory
2. `Ctrl+Shift+P` → "Databricks: Configure Cluster"
3. Select workspace and cluster
4. Place cursor in any cell (between `# COMMAND ----------`)
5. `Ctrl+Shift+P` → "Databricks: Run Cell"

**B. In Databricks Workspace (recommended)**
```bash
# Access deployed notebooks directly in workspace:
# https://<workspace-url>/#workspace/users/<your-email>/bundles/databricks_demo/dev/files/notebooks/01_local_notebook
```

**C. Live Sync Development**
```bash
# Keep local changes synced to workspace
scripts/bundle_sync.sh
# Edit notebooks locally, changes appear in workspace automatically
```

**D. Programmatic Data Access**
```bash
# Use the SDK to download data locally for inspection
python test_authentication.py  # Test connectivity
python download_data.py        # Extract data to output/ directory
```

### Files and Structure
- `databricks.yml` - Bundle configuration (jobs, pipelines, sync paths)
- `notebooks/` - Notebook source files (Python format)
  - `01_local_notebook.py` - Simple demo notebook showing PySpark DataFrame operations
  - `dlt_pipeline.py` - Delta Live Tables pipeline with bronze and silver tables
- `scripts/` - Helper scripts for deployment and execution
- `.vscode/` - VS Code settings for Databricks extension
- `test_authentication.py` - Comprehensive authentication and SDK test script
- `download_data.py` - Example script for extracting data from Databricks to local files

## Customization
- **Use existing cluster** (faster job runs):
```bash
export BUNDLE_VARS="existing_cluster_id=<your-cluster-id>"
```
- **Unity Catalog for DLT**:
```bash
export BUNDLE_VARS="${BUNDLE_VARS} catalog=<your-catalog>"
```
- **Multiple environments**: Modify `targets` in `databricks.yml` for dev/staging/prod

## Troubleshooting

### Authentication Issues
- **OAuth state mismatch**: Common in remote/devcontainers when multiple browsers launch. Use Azure CLI auth (Option A) instead.
- **"default auth: cannot configure"**: Set `DATABRICKS_CONFIG_PROFILE=codespaces` or ensure profile exists in `~/.databrickscfg`
- **Multiple CLI versions detected**: Informational only; newer CLI will be used automatically.

### Bundle Issues  
- **"parse https://${var.workspace_host}"**: Set `WORKSPACE_HOST` environment variable before running bundle commands.
- **"both file.py and file.ipynb point to the same remote file location"**: Remove either the `.py` or `.ipynb` version - bundle sync cannot handle both formats pointing to the same workspace path.
- **"Unable to access notebook"**: Run `scripts/bundle_sync.sh` or manually upload notebooks to workspace.
- **"WAITING_FOR_RESOURCES"**: DLT pipelines take 3-10 minutes to provision compute. This is normal.

### Performance Tips
- **Use existing clusters**: Export `BUNDLE_VARS="existing_cluster_id=<cluster-id>"` to avoid cold starts
- **Pin cluster profiles**: Keep a cluster running to reduce job execution time  
- **Sync vs Upload**: Use `bundle_sync.sh` for active development, manual upload for one-off testing

### Codespaces-Specific
- **Kernel not found**: Databricks kernels don't work well in Codespaces. Use the .py file method or workspace browser.
- **Browser URLs**: Use `"$BROWSER" <url>` to open links in your local browser from the terminal.
- **File permissions**: Run `chmod +x scripts/*.sh` if scripts aren't executable.

## For AI/Copilot Context

This repository demonstrates:
- **Modern Databricks development** using Asset Bundles (DAB) for CI/CD
- **Multiple authentication patterns** for different environments (local, remote, CI)
- **Interactive development workflows** using VS Code + Databricks extension
- **Bundle structure** for jobs, pipelines, and workspace sync
- **Remote development** patterns for Codespaces/devcontainers
- **Troubleshooting** common issues in cloud development environments

Key patterns:
- Use `DATABRICKS_CONFIG_PROFILE` and `WORKSPACE_HOST` environment variables  
- Scripts auto-detect profiles and fallback to sensible defaults
- Bundle configuration avoids variable interpolation for auth-related fields
- Separate approaches for kernel-based vs. CLI-based notebook execution
