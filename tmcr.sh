#!/bin/bash

#set -e

set -euo pipefail

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
TOKEN="${GITHUB_TOKEN}"


# Variables
TEAM_NAME="admin"  # change the name and description if team name is already exists
TEAM_DESCRIPTION="Admin with full access"
TEAM_PRIVACY="closed"  # or "secret"

# Function to create a team
create_team() {
  local team_name=$1
  local team_description=$2
  local team_privacy=$3

  local response=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$team_name\", \"description\": \"$team_description\", \"privacy\": \"$team_privacy\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")
  
  local team_id=$(echo "$response" | jq -r '.id')
  local error_message=$(echo "$response" | jq -r '.message')

  if [[ "$team_id" == "null" ]]; then
    echo "Error creating team $team_name: $error_message"
    exit 1
  else
    echo "Team '$team_name' created with ID $team_id"
    echo "$team_id"
  fi
}

# Create the team
#create_team "$TEAM_NAME" "$TEAM_DESCRIPTION" "$TEAM_PRIVACY"


# Function to get team details
get_team_details() {
  local team_id=$1

  local response=$(curl -s -X GET \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/organizations/$ORGANIZATION/team/$team_id")

  echo "$response" | jq '.'
}

# Create the team and get its details
TEAM_ID=$(create_team "$TEAM_NAME" "$TEAM_DESCRIPTION" "$TEAM_PRIVACY")
echo "Team '$TEAM_NAME' created with ID $TEAM_ID"
echo "Team details:"
get_team_details "$TEAM_ID"
