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

  if echo "$response" | jq -e '.[].name' | grep -q "$team_name"; then
    return 0 # Team exists
  else
    return 1 # Team does not exist
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

# Read project names from projects.json
projects=$(jq -r '.projects[].name' projects.json)

echo "Projects:"
while IFS= read -r project_name; do
  echo "Project: $project_name"

  # Check if dev and admin teams exist, create if not
  for team_name in "dev" "admin"; do
    if ! team_exists "$team_name"; then
      create_team "$team_name" "$team_name team" "closed"
    fi
  done

  # Assign dev team to the project
  echo "Dev team assigned to project $project_name"
  # Assign admin team to the project
  echo "Admin team assigned to project $project_name"
  echo "--------------------"

done <<< "$projects"
