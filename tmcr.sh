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

# Create Team 1
#response1=$(curl -X POST \
 # -H "Authorization: token $TOKEN" \
  #-d "{\"name\": \"$TEAM1_NAME\", \"description\": \"$TEAM1_DESCRIPTION\"}" \
  #"https://api.github.com/orgs/$ORGANIZATION/teams")

  response1=$(curl -X POST -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token $TOKEN"" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{\"name\": \"$TEAM1_NAME\", \"description\": \"$TEAM1_DESCRIPTION\"}" \
  "https://api.github.com/orgs/$ORGANIZATION/teams")


# Extract Team 1 ID
TEAM1_ID=$(echo "$response1" | jq -r '.id')

echo "Team 1 created with ID: $TEAM1_ID"
