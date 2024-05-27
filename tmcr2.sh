#!/bin/bash
set -euo pipefail

# Read project names and repositories from repos.json
projects=$(jq -c '.projects[]' repos.json)

echo "Projects and their repositories:"
while IFS= read -r project; do
  project_name=$(echo "$project" | jq -r '.name')
  repositories=$(echo "$project" | jq -r '.repositories[]')
  echo "Project: $project_name"
  echo "Repositories:"
  for repo in $repositories; do
    echo "  - $repo"
  done
done <<< "$projects"
