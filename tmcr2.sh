#!/bin/bash

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

# Function to add team to a project
add_team_to_project() {
  local project_name=$1
  local team_name=$2

  local response=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{}" \
    "https://api.github.com/orgs/$ORGANIZATION/projects/$project_name/teams/$team_name")

  if [[ "$response" == "" ]]; then
    echo "Team $team_name added to project $project_name."
  else
    echo "Error adding team $team_name to project $project_name: $response"
  fi
}

# Create dev and admin teams if they don't exist
for team_name in "dev" "admin"; do
  if ! team_exists "$team_name"; then
    create_team "$team_name" "$team_name team" "closed"
  fi
done

# Assign teams to projects
add_team_to_project "projA" "dev"
add_team_to_project "projA" "admin"
add_team_to_project "projB" "dev"
add_team_to_project "projB" "admin"
