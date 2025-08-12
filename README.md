# databricks_demo

Demo of Databricks Asset Bundles (DAB): develop locally, sync notebooks, deploy a job and a DLT pipeline, and run them using the Databricks CLI.

## Prerequisites
- Databricks workspace URL
- Ability to log in via SSO/OAuth (external browser)

## Setup
```bash
cd /workspaces/databricks_demo

# 1) Install CLI
chmod +x scripts/*.sh || true
scripts/install_databricks_cli.sh

# 2) Login with SSO (replace URL)
scripts/databricks_login.sh https://<your-workspace-url>

# 3) Validate bundle (set workspace host)
export WORKSPACE_HOST=https://<your-workspace-url>
scripts/bundle_validate.sh

# 4) Start bidirectional file sync (keeps running)
scripts/bundle_sync.sh

# In another terminal:
# 5) Deploy resources (job + pipeline)
scripts/bundle_deploy.sh

# 6) Run the job
scripts/run_job.sh

# 7) Start the DLT pipeline
scripts/run_pipeline.sh
```

## Customization
- To attach the notebook job to an existing cluster, export its ID:
```bash
export BUNDLE_VARS="existing_cluster_id=<your-cluster-id>"
```
- If Unity Catalog is enabled for DLT, also set:
```bash
export BUNDLE_VARS="${BUNDLE_VARS} catalog=<your-catalog>"
```

Bundle configuration lives in `databricks.yml`. Notebooks are under `notebooks/`.
