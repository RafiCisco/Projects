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

# Function to assign a team to a repository
assign_team_to_repo() {
  local team_name=$1
  local repo_name=$2
  local permission=$3

  local response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"permission\": \"$permission\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams/$team_name/repos/$ORGANIZATION/$repo_name")

  if [[ "$response" -eq 204 ]]; then
    echo "Team $team_name assigned to repository $repo_name with $permission permission."
  else
    echo "Error assigning team $team_name to repository $repo_name. HTTP status code: $response"
  fi
}

# Read project names from repos.json
projects=$(jq -r '.projects[].name' repos.json)

echo "Projects and their repositories reading from repos.json:"
while IFS= read -r project_name; do
  echo "Project: $project_name"

  # Check if dev and admin teams exist, create if not
  for team_name in "dev" "admin"; do
    if ! team_exists "$team_name"; then
      create_team "$team_name" "$team_name team" "closed"
    fi
  done

  # Assign dev and admin teams to the project repositories
  repositories=$(jq -r --arg proj "$project_name" '.projects[] | select(.name == $proj) | .repositories[]' repos.json)
  for repo in $repositories; do
    assign_team_to_repo "dev" "$repo" "write"
    assign_team_to_repo "admin" "$repo" "admin"
  done

  echo "Dev and admin teams assigned to repositories of project $project_name"
  echo "--------------------"

done <<< "$projects"
