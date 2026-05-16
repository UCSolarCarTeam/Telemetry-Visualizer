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

Save the dashboard in Grafana first (Ctrl+S), then export — this ensures the
exported JSON reflects your latest changes.

1. Open the dashboard in local Grafana
2. Click the **Share icon** (top right)
3. Select the **Export** tab
4. Click **Copy to clipboard**

### 4. Replace the file in git

Open the corresponding file in `grafana/dashboards/` and paste the clipboard
content, replacing the entire file contents. The filename should stay the same.

### 5. Commit and push

CI/CD runs on merge to `main` and deploys to Grafana Cloud automatically.

---

## What CI/CD does

The deploy job in `.github/workflows/workflow.yml`:

1. Fetches all datasources from Grafana Cloud
2. Strips `__inputs`, `__requires`, and `__elements` from the dashboard JSON (safe to include or omit in the exported file)
3. Walks the entire dashboard JSON and rewrites every datasource `uid` by matching on `type` against the Cloud datasources
4. POSTs the remapped dashboard to `POST /api/dashboards/db`

---

## Common mistakes

| Mistake                                      | Result                                                       |
| -------------------------------------------- | ------------------------------------------------------------ |
| Using "Share externally" instead of "Export" | Creates a public URL link — not what you want                |
| Editing dashboard directly in Grafana Cloud  | Changes get overwritten on next CI/CD deploy, no git history |

---
