#!/bin/bash
set -euo pipefail

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Array to store existing teams
existing_teams=()

# Associative array to store team existence status
declare -A team_status=()

# Function to check if a team exists
team_exists() {
  local team_name=$1

  if [[ ${team_status[$team_name]+_} ]]; then
    return ${team_status[$team_name]}
  fi

  local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")

  if echo "$response" | jq -e '.[].name' | grep -q "$team_name"; then
    team_status[$team_name]=0 # Team exists
    return 0
  else
    team_status[$team_name]=1 # Team does not exist
    return 1
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

  if echo "$response" | jq -e '.id' >/dev/null; then
    echo "Team $team_name created successfully."
  else
    echo "Failed to create team $team_name."
    exit 1
  fi
}

# Read project information from JSON file
projects=$(jq -c '.projects[]' repos.json)

# Loop through projects
while IFS= read -r project; do
  project_name=$(echo "$project" | jq -r '.name')

  # Check if dev and admin teams exist, create if not
  for team_name in "dev" "admin"; do
    if ! team_exists "$team_name"; then
      create_team "$team_name" "$team_name team" "closed"
    fi
  done

  echo "Teams assigned to project: $project_name"
  echo "--------------------"

done <<< "$projects"


# Array to store existing teams
existing_teams=()

# Associative array to store team existence status
declare -A team_status

# Function to check if a team exists
team_exists() {
  local team_name=$1

  if [[ ${team_status[$team_name]} ]]; then
    return ${team_status[$team_name]}
  fi

  local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")

  if echo "$response" | jq -e '.[].name' | grep -q "$team_name"; then
    team_status[$team_name]=0 # Team exists
    return 0
  else
    team_status[$team_name]=1 # Team does not exist
    return 1
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

  if echo "$response" | jq -e '.id' >/dev/null; then
    echo "Team $team_name created successfully."
  else
    echo "Failed to create team $team_name."
    exit 1
  fi
}

# Read project information from JSON file
projects=$(jq -c '.projects[]' repos.json)

# Loop through projects
while IFS= read -r project; do
  project_name=$(echo "$project" | jq -r '.name')

  # Check if dev and admin teams exist, create if not
  for team_name in "dev" "admin"; do
    if ! team_exists "$team_name"; then
      create_team "$team_name" "$team_name team" "closed"
    fi
  done

  echo "Teams assigned to project: $project_name"
  echo "--------------------"

done <<< "$projects"
