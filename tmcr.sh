#!/bin/bash

# Variables
GITHUB_ORG="your_organization_name"
GITHUB_TOKEN="your_personal_access_token"

# Define repositories and their corresponding teams and permissions
declare -A repos_teams=(
  ["repo1"]="admin:admin dev:push"
  ["repo2"]="admin:admin dev:push"
  ["repo3"]="admin:admin dev:push"
)

# Function to create a team
create_team() {
  local team_name=$1
  local team_description=$2

  echo "Creating team $team_name..."

  RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/$GITHUB_ORG/teams \
    -d "{\"name\":\"$team_name\", \"description\":\"$team_description\"}")

  TEAM_SLUG=$(echo $RESPONSE | jq -r '.slug')

  if [ "$TEAM_SLUG" == "null" ]; then
    echo "Failed to create team. Response: $RESPONSE"
    exit 1
  else
    echo "Team created with slug: $TEAM_SLUG"
  fi
}

# Function to add a team to a repository with a specific permission
add_team_to_repo() {
  local team_slug=$1
  local repo_name=$2
  local permission=$3

  echo "Adding team $team_slug to repository $repo_name with $permission permission..."

  RESPONSE=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/orgs/$GITHUB_ORG/teams/$team_slug/repos/$GITHUB_ORG/$repo_name \
    -d "{\"permission\":\"$permission\"}")

  if echo $RESPONSE | grep -q '"message": "Not Found"'; then
    echo "Failed to add team to repository. Response: $RESPONSE"
    exit 1
  else
    echo "Team $team_slug added to repository $repo_name with $permission permission."
  fi
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq is required but it's not installed. Install jq and try again."
  exit 1
fi

# Create teams
create_team "admin" "Admin team with full access"
create_team "dev" "Dev team with push access"

# Add teams to repositories with specified permissions
for repo in "${!repos_teams[@]}"; do
  IFS=' ' read -r -a teams <<< "${repos_teams[$repo]}"
  for team_info in "${teams[@]}"; do
    IFS=':' read -r -a team_permission <<< "$team_info"
    team_name=${team_permission[0]}
    permission=${team_permission[1]}
    team_slug=$(echo "$team_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    add_team_to_repo "$team_slug" "$repo" "$permission"
  done
done

echo "Done."
