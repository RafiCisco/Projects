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
  local permission=$2

  local response=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$team_name\", \"permission\": \"$permission\"}" \
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

# Function to add repository to a team
add_repo_to_team() {
  local team_name=$1
  local repo_name=$2

  local response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{}" \
    "https://api.github.com/teams/$team_name/repos/$ORGANIZATION/$repo_name")

  if [[ "$response" -eq 204 ]]; then
    echo "Repo $repo_name added to team $team_name"
  else
    echo "Error adding repo $repo_name to team $team_name: HTTP status code $response"
    exit 1
  fi
}

# Read repository names from JSON file
repos_json="repos.json"
repo_names=$(jq -r '.[].name' "$repos_json")

# Create admin and dev teams and assign repositories
for repo_name in $repo_names; do
  # Check if admin team exists, if not create it
  if [[ "$(team_exists "admin-$repo_name")" == "false" ]]; then
    admin_team_id=$(create_team "admin-$repo_name" "admin")
    echo "Admin team created for $repo_name with ID $admin_team_id"
  else
    admin_team_id=$(team_exists "admin-$repo_name")
    echo "Admin team for $repo_name already exists with ID $admin_team_id"
  fi

  # Check if dev team exists, if not create it
  if [[ "$(team_exists "dev-$repo_name")" == "false" ]]; then
    dev_team_id=$(create_team "dev-$repo_name" "push")
    echo "Dev team created for $repo_name with ID $dev_team_id"
  else
    dev_team_id=$(team_exists "dev-$repo_name")
    echo "Dev team for $repo_name already exists with ID $dev_team_id"
  fi

  # Assign repository to admin team
  add_repo_to_team "$admin_team_id" "$repo_name"

  # Assign repository to dev team
  add_repo_to_team "$dev_team_id" "$repo_name"
done

echo "Teams and repositories created and assigned successfully."
