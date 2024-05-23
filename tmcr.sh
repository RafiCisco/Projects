#!/bin/bash

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
TOKEN="$TOKEN"

# Team name and description
TEAM_NAME="admin"
TEAM_DESCRIPTION="full access"

# Team privacy (closed or secret)
TEAM_PRIVACY="closed"  # or "secret"

# Create the team
response=$(curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$TEAM_NAME\", \"description\": \"$TEAM_DESCRIPTION\", \"privacy\": \"$TEAM_PRIVACY\"}" \
  "https://api.github.com/orgs/$ORGANIZATION/teams")

# Extract the team ID and check for errors
TEAM_ID=$(echo "$response" | jq -r '.id')
ERROR_MESSAGE=$(echo "$response" | jq -r '.message')

if [[ "$TEAM_ID" == "null" ]]; then
  echo "Error creating team: $ERROR_MESSAGE"
  exit 1
else
  echo "Team '$TEAM_NAME' created with ID $TEAM_ID"
fi

# Optionally, display the created team's details
echo "Team Details:"
curl -s -H "Authorization: token $TOKEN" "https://api.github.com/teams/$TEAM_ID" | jq .
