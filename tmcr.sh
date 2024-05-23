#!/bin/bash

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
TOKEN="${GITHUB_TOKEN}"

# Team name and description
#TEAM_NAME="admin"
#TEAM_DESCRIPTION="full access"

# Team details and description
TEAM1_NAME="admin1"
TEAM1_DESCRIPTION="admin with full access"
TEAM2_NAME="dev1"
TEAM2_DESCRIPTION="only write access for dev"
TEAM_PRIVACY="closed"  # or "secret"


# Team privacy (closed or secret)
TEAM_PRIVACY="closed"  # or "secret"

# Function to create a team
create_team() {
  local team_name=$1
  local team_description=$2
  local response=$(curl -s -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$team_name\", \"description\": \"$team_description\", \"privacy\": \"$TEAM_PRIVACY\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")
  local team_id=$(echo "$response" | jq -r '.id')
  local error_message=$(echo "$response" | jq -r '.message')

  if [[ "$team_id" == "null" ]]; then
    echo "Error creating team $team_name: $error_message"
    exit 1
  else
    echo "Team '$team_name' created with ID $team_id"
  fi
}

# Create Team 1
create_team "$TEAM1_NAME" "$TEAM1_DESCRIPTION"

# Create Team 2
create_team "$TEAM2_NAME" "$TEAM2_DESCRIPTION"

# Display created teams
echo "Displaying Teams:"
teams=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/orgs/$ORGANIZATION/teams" | jq -r '.[].name')
echo "$teams"
