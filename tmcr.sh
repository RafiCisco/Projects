#!/bin/bash

#set -e

set -euo pipefail

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
TOKEN="${GITHUB_TOKEN}"

# Variables
TEAM_NAME="Admin"
TEAM_DESCRIPTION="Admin team with full access"
TEAM_PRIVACY="closed"  # or "secret"



# Function to check if a team exists
team_exists() {
  local team_name=$1

  local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")

  local team_exists=$(echo "$response" | jq -r ".[] | select(.name == \"$team_name\") | .id")

  if [[ -n "$team_exists" ]]; then
    echo "true"
  else
    echo "false"
  fi
}

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
    echo "$team_id"
  fi
}

# Function to get team slug from team ID
get_team_slug() {
  local team_id=$1

  local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")

  local team_slug=$(echo "$response" | jq -r ".[] | select(.id==$team_id) | .slug")

  if [[ -z "$team_slug" ]]; then
    echo "Error: Team slug not found for team ID $team_id"
    exit 1
  else
    echo "$team_slug"
  fi
}

# Function to get team details
get_team_details() {
  local team_slug=$1

  local response=$(curl -s -X GET \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/orgs/$ORGANIZATION/teams/$team_slug")

  echo "$response" | jq '.'
}

# Check if the team already exists
if [[ $(team_exists "$TEAM_NAME") == "true" ]]; then
  echo "Team '$TEAM_NAME' already exists."
else
  # Create the team and get its details
  TEAM_ID=$(create_team "$TEAM_NAME" "$TEAM_DESCRIPTION" "$TEAM_PRIVACY")
  echo "Team '$TEAM_NAME' created with ID $TEAM_ID"

  # Fetch the team slug using the team ID
  TEAM_SLUG=$(get_team_slug "$TEAM_ID")

  echo "Fetching details for team '$TEAM_NAME' with slug '$TEAM_SLUG'..."
  get_team_details "$TEAM_SLUG"
fi
