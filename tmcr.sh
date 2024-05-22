#!/bin/bash

# GitHub Organization or username
ORGANIZATION="RafiCisco"

# Access GitHub token passed from workflow
TOKEN="$1"

# Now you can use $TOKEN in your script for making GitHub API requests or other operations
echo "GitHub Token: $TOKEN"

# Team names
TEAM1_NAME="team1"
TEAM2_NAME="team2"

# Team descriptions (optional)
TEAM1_DESCRIPTION="Team 1 description"
TEAM2_DESCRIPTION="Team 2 description"

response1=$(curl -X POST \
  -H "Authorization: token $TOKEN" \
  -d "{\"name\": \"$TEAM1_NAME\", \"description\": \"$TEAM1_DESCRIPTION\"}" \
  "https://api.github.com/orgs/$ORGANIZATION/teams")

echo "Team 1 creation response: $response1"
