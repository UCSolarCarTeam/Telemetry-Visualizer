# Dashboard Update Workflow

Edit dashboards locally, commit to git, and let CI/CD deploy to Grafana Cloud.
Never edit dashboards directly in Grafana Cloud.

## Steps

### 1. Start local Grafana

```bash
cd grafana
docker compose up -d
```

Open http://localhost:3000 (admin / admin).

### 2. Edit the dashboard locally

Make your changes in local Grafana as usual.

### 3. Export the dashboard JSON

1. Open the dashboard in local Grafana
2. Click the **Share icon** (top right)
3. Select the **Export** tab
4. Toggle **"Export for sharing externally"** ON (blue)
5. Click **Download file**

> **Why this toggle matters:** It adds `__inputs` and `__requires` sections to the
> JSON. The CI/CD deploy script reads `__inputs` to remap datasource UIDs from
> local values to the correct Grafana Cloud UIDs. Without it, the dashboard
> uploads but panels show "Data source not found".

### 4. Replace the file in git

Replace the existing file in `grafana/dashboards/` with the downloaded JSON.
The filename should stay the same.

```bash
cp ~/Downloads/<dashboard-name>.json grafana/dashboards/<dashboard-name>.json
```

### 5. Commit and push

```bash
git add grafana/dashboards/<dashboard-name>.json
git commit -m "feat(grafana): update dashboard ..."
git push
```

CI/CD runs on push to `main` and deploys to Grafana Cloud automatically.

---

## What CI/CD does

The deploy job in `.github/workflows/workflow.yml`:

1. Fetches all datasources from Grafana Cloud
2. For each `__inputs` entry, looks up the matching Cloud datasource UID by `pluginId` or name
3. Rewrites all hardcoded panel datasource UIDs to the Cloud values
4. POSTs to `POST /api/dashboards/import` with the remapped dashboard

---

## Common mistakes

| Mistake                                               | Result                                                             |
| ----------------------------------------------------- | ------------------------------------------------------------------ |
| Export without "Export for sharing externally" toggle | Dashboard uploads but panels show "Data source not found" in Cloud |
| Using "Share externally" instead of "Export"          | Creates a public URL link — not what you want                      |
| Editing dashboard directly in Grafana Cloud           | Changes get overwritten on next CI/CD deploy, no git history       |

---
