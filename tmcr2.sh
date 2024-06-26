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

# Function to add repository to a team with specified permission
add_repo_to_team() {
  local team_slug=$1
  local repo_name=$2
  local permission=$3

  local response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"permission\": \"$permission\"}" \
    "https://api.github.com/teams/$team_slug/repos/$ORGANIZATION/$repo_name")

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

# Create admin and dev teams if they don't exist
for team_name in "admin" "dev"; do
  team_id=$(team_exists "$team_name")
  if [[ "$team_id" == "false" ]]; then
    create_team "$team_name" "$team_name team" "closed"
  fi
done

# Assign repositories to admin and dev teams
for repo_name in $repo_names; do
  for team_name in "admin" "dev"; do
    team_id=$(team_exists "$team_name")
    if [[ "$team_name" == "admin" ]]; then
      add_repo_to_team "$team_id" "$repo_name" "admin"
    elif [[ "$team_name" == "dev" ]]; then
      add_repo_to_team "$team_id" "$repo_name" "push"
    fi
  done
done

# Display list of repositories assigned to each team
echo "Repositories assigned to teams:"
for team_name in "admin" "dev"; do
  team_id=$(team_exists "$team_name")
  echo "Team: $team_name"
  curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/teams/$team_id/repos" | jq -r '.[].full_name'
  echo ""
done
