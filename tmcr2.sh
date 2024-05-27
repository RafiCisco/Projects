#!/bin/bash
set -euo pipefail

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Associative array to store team existence status
declare -A team_status

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
    echo "Team $team_name already exists."
    return 0
  else
    team_status[$team_name]=1 # Team does not exist
    echo "Team $team_name does not exist."
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

# Function to add a repository to a team
add_repo_to_team() {
  local team_name=$1
  local repo_name=$2
  local permission=$3

  local response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"permission\": \"$permission\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams/$team_name/repos/$repo_name")

  if [[ "$response" -ne 204 ]]; then
    echo "Error adding repository $repo_name to team $team_name. HTTP status code: $response"
  else
    echo "Repository $repo_name added to team $team_name with $permission permission."
  fi
}

# Display project names from JSON file
echo "Projects in repos.json file:"
projects=$(jq -c '.projects[]' repos.json)
while IFS= read -r project; do
  project_name=$(echo "$project" | jq -r '.name')
  echo "$project_name"
done <<< "$projects"
echo "--------------------"

# Fetch and display repositories under the organization
echo "Repositories under the organization:"
repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$ORGANIZATION/repos" | jq -r '.[].name')
for repo in $repos; do
  echo "$repo"
done
echo "--------------------"

# Loop through projects
while IFS= read -r project; do
  project_name=$(echo "$project" | jq -r '.name')

  # Check if dev and admin teams exist, create if not
  for team_name in "dev" "admin"; do
    if ! team_exists "$team_name"; then
      create_team "$team_name" "$team_name team" "closed"
    fi
  done

# Display the repositories assigned to each team
for team_name in "dev" "admin"; do
  echo "Repositories assigned to team $team_name:"
  assigned_repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/orgs/$ORGANIZATION/teams/$team_name/repos" | jq -r '.[].name')
  for repo in $assigned_repos; do
    echo "$repo"
  done
  echo "--------------------"
done
