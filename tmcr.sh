#!/bin/bash

#set -e

set -euo pipefail

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Teams and repositories
declare -A TEAMS=( ["admin"]="Admin team with full access" ["dev"]="Development team with restricted access" )
REPOSITORIES=("RepoA1" "RepoA2")  # Add the names of your repositories here

# Function to create a team
create_team() {
  local name="$1"
  local description="$2"
  local privacy="closed"  # or "secret"

  local response=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$name\", \"description\": \"$description\", \"privacy\": \"$privacy\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")

  local team_id=$(echo "$response" | jq -r '.id')
  local error_message=$(echo "$response" | jq -r '.message')

  if [[ "$team_id" == "null" ]]; then
    echo "Error creating team $name: $error_message" >&2
    exit 1
  else
    echo "Team '$name' created with ID $team_id"
  fi
}

# Function to assign repositories to a team with write access
assign_repositories_to_team() {
  local team_slug="$1"

  for repo in "${REPOSITORIES[@]}"; do
    local response=$(curl -s -X PUT \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"permission": "push"}' \
      "https://api.github.com/teams/$team_slug/repos/$ORGANIZATION/$repo")

    local status_code=$(echo "$response" | jq -r '.status')

    if [[ "$status_code" == "204" ]]; then
      echo "Assigned repository '$repo' to team '$team_slug' with 'write' permission."
    else
      echo "Error assigning repository '$repo' to team '$team_slug': $response" >&2
      exit 1
    fi
  done
}

# Main script
for team_name in "${!TEAMS[@]}"; do
  team_description="${TEAMS[$team_name]}"

  # Check if the team already exists
  team_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$ORGANIZATION/teams")
  team_slug=$(echo "$team_response" | jq -r ".[] | select(.name == \"$team_name\") | .slug")

  if [[ -z "$team_slug" ]]; then
    # Create team if it doesn't exist
    team_id=$(create_team "$team_name" "$team_description")
    team_slug=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$ORGANIZATION/teams/$team_id" | jq -r ".slug")
  else
    echo "Team '$team_name' already exists"
  fi

  # Assign repositories to the team with 'write' access
  assign_repositories_to_team "$team_slug"
done
