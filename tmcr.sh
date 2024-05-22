#!/bin/bash

# GitHub Organization or username
ORGANIZATION="RafiCisco"

# Access GitHub token passed from workflow
TOKEN="$1"

# Now you can use $TOKEN in your script for making GitHub API requests or other operations
echo "GitHub Token: $TOKEN"

# Create Admin Team
ADMIN_TEAM_ID=$(curl -X POST -H "Authorization: token $TOKEN" -d '{"name": "admin", "permission": "admin"}' "https://api.github.com/orgs/$ORGANIZATION/teams" | jq -r '.id')





