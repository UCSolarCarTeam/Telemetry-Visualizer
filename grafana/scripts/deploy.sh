#!/usr/bin/env bash
set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:?GRAFANA_URL is not set}"
GRAFANA_TOKEN="${GRAFANA_TOKEN:?GRAFANA_TOKEN is not set}"

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

datasources=$(curl -sf \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  "$GRAFANA_URL/api/datasources") || { echo "ERROR: failed to fetch datasources from Grafana"; exit 1; }

echo "Found datasources: $(echo "$datasources" | jq -r '.[].type')"

for file in "$REPO_ROOT/grafana/dashboards"/*.json; do
  echo "Deploying $file..."
  dashboard=$(jq 'del(.id, .__inputs, .__requires, .__elements)' "$file")

  # Remap every datasource uid in the dashboard by matching on type against
  # the live datasources — works regardless of whether __inputs is present.
  while IFS= read -r ds_json; do
    cloud_type=$(echo "$ds_json" | jq -r '.type')
    cloud_uid=$(echo "$ds_json" | jq -r '.uid')

    dashboard=$(echo "$dashboard" | jq \
      --arg type "$cloud_type" \
      --arg uid "$cloud_uid" \
      'walk(if type == "object" and has("uid") and has("type") and .type == $type then .uid = $uid else . end)')

    echo "  Remapped '$cloud_type' -> '$cloud_uid'"
  done < <(echo "$datasources" | jq -c '.[]')

  payload=$(jq -n \
    --argjson dashboard "$dashboard" \
    '{dashboard: $dashboard, overwrite: true, folderUid: ""}')

  tmpfile=$(mktemp)
  response=$(curl -s -o "$tmpfile" -w "%{http_code}" \
    -X POST "$GRAFANA_URL/api/dashboards/db" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $GRAFANA_TOKEN" \
    -d "$payload")

  if [ "$response" = "200" ]; then
    rm -f "$tmpfile"
    echo "Successfully deployed $file"
    continue
  fi

  body=$(cat "$tmpfile")
  rm -f "$tmpfile"
  if [ "$response" = "400" ] && echo "$body" | grep -q "Cannot save provisioned dashboard"; then
    echo "Skipped $file — dashboard is file-provisioned; update the JSON file instead"
    continue
  fi

  echo "Failed to deploy $file (HTTP $response)"
  echo "$body"
  exit 1
done
