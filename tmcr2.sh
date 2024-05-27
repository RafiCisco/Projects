#!/bin/bash
set -euo pipefail

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Function to check if a team exists
team_exists() {
  local team_name=$1

  local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")

  local team_id=$(echo "$response" | jq -r ".[] | select(.name == \"$team_name\") | .id")

  if [[ -n "$team_id" ]]; then
    echo "$team_id"
  else
    echo "false"
  fi
}

# Function to create a team
create_team() {
  local team_name=$1

  local response=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$team_name\"}" \
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

# Function to add repository to a team with specified permission
add_repo_to_team() {
  local team_slug=$1
  local repo_name=$2
  local permission=$3

  local response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"permission\": \"$permission\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams/$team_slug/repos/$ORGANIZATION/$repo_name")

  if [[ "$response" -ne 204 ]]; then
    echo "Error adding repo $repo_name to team $team_slug: HTTP status code $response"
    exit 1
  else
    echo "Repo $repo_name added to team $team_slug with $permission permission"
  fi
}

# Read repository names from JSON file
repos_json="repos.json"
repo_names=$(jq -r '.[].name' "$repos_json")

# Create teams and assign repositories
for repo_name in $repo_names; do
  # Create team if it doesn't exist
  if [[ "$(team_exists "$repo_name")" == "false" ]]; then
    create_team "$repo_name"
  fi

  # Add repository to the team
  add_repo_to_team "$repo_name" "$repo_name" "admin" # Adjust permission as needed
done

echo "Teams and repositories created and assigned successfully."
