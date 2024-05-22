#!/bin/bash

# Replace with your own values
GITHUB_TOKEN="GH_PAT"
ORG_NAME="RafiCisco"
TEAM_NAME="Admin"
TEAM_DESCRIPTION="Admin full access"

# Set up the JSON payload
PAYLOAD=$(cat <<EOF
{
  "name": "$TEAM_NAME",
  "description": "$TEAM_DESCRIPTION",
  "privacy": "closed"  # 'closed' or 'secret'
}
EOF
)

# Make the API request to create the team
response=$(curl -s -w "%{http_code}" -o /dev/null -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "https://api.github.com/orgs/$ORG_NAME/teams")

# Check the response status code
if [ "$response" -eq 201 ]; then
  echo "Team created successfully!"
else
  echo "Failed to create team: $response"
  echo "Response: $(curl -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" "https://api.github.com/orgs/$ORG_NAME/teams")"
fi
