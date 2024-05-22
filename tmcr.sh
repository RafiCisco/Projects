#!/bin/bash

# GitHub Organization or username
ORGANIZATION="RafiCisco"

# Access GitHub token passed from workflow
TOKEN="$1"

# Now you can use $TOKEN in your script for making GitHub API requests or other operations
echo "GitHub Token: $TOKEN"



# GitHub Token with appropriate permissions
#TOKEN="${{ secrets.GH_PAT }}"  # Or your personal access token
#TOKEN="${{ secrets.GH_TOKEN }}"
#TOKEN="${{ secrets.GH_ORGT }}"

# Create Admin Team
ADMIN_TEAM_ID=$(curl -X POST -H "Authorization: token $TOKEN" -d '{"name": "admin", "permission": "admin"}' "https://api.github.com/orgs/$ORGANIZATION/teams" | jq -r '.id')

# Create Dev Team
DEV_TEAM_ID=$(curl -X POST -H "Authorization: token $TOKEN" -d '{"name": "dev", "permission": "push"}' "https://api.github.com/orgs/$ORGANIZATION/teams" | jq -r '.id')

# Get list of repositories
REPO_LIST=$(curl -H "Authorization: token $TOKEN" "https://api.github.com/orgs/$ORGANIZATION/repos" | jq -r '.[].name')

# Assign Admin Team to Repositories
for REPO in $REPO_LIST; do
    curl -X PUT -H "Authorization: token $TOKEN" -d "{\"permission\": \"admin\"}" "https://api.github.com/teams/$ADMIN_TEAM_ID/repos/$ORGANIZATION/$REPO"
done

# Assign Dev Team to Repositories
for REPO in $REPO_LIST; do
    curl -X PUT -H "Authorization: token $TOKEN" -d "{\"permission\": \"push\"}" "https://api.github.com/teams/$DEV_TEAM_ID/repos/$ORGANIZATION/$REPO"
done

echo "Teams assigned to repositories successfully!"

