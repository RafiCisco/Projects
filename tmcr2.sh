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

  if echo "$response" | jq -e '.id' >/dev/null; then
    echo "Team $team_name created successfully."
  else
    echo "Failed to create team $team_name."
    exit 1
  fi
}

# Function to add repository to a team with specified permission
add_repo_to_team() {
  local team_name=$1
  local repo_name=$2
  local permission=$3

  local response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"permission\": \"$permission\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams/$team_name/repos/$ORGANIZATION/$repo_name")

  if [[ "$response" -eq 204 ]]; then
    echo "Repository $repo_name added to team $team_name with $permission permission"
  else
    echo "Error adding repository $repo_name to team $team_name. HTTP status code: $response"
  fi
}

# Read project and repository information from JSON file
projects=$(jq -c '.projects[]' repos.json)

# Loop through projects
while IFS= read -r project; do
  project_name=$(echo "$project" | jq -r '.name')
  repositories=$(echo "$project" | jq -r '.repositories[]')

  # Check if dev and admin teams exist, create if not
  for team_name in "dev" "admin"; do
    if ! team_exists "$team_name"; then
      create_team "$team_name" "$team_name team" "closed"
    fi
  done

  # Assign repositories to dev and admin teams
  for repo in $repositories; do
    for team_name in "dev" "admin"; do
      add_repo_to_team "$team_name" "$repo" "push"
    done
  done

done <<< "$projects"

echo "Repository assignment completed."
