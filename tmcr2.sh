#!/bin/bash
set -euo pipefail

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
GITHUB_TOKEN="${GITHUB_TOKEN}"

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

# Fetch and display all repositories under the organization
echo "Repositories under the organization $ORGANIZATION:"
org_repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$ORGANIZATION/repos" | jq -r '.[].name')
for repo in $org_repos; do
  echo "  - $repo"
done
