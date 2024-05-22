#!/bin/bash


# Variables
GITHUB_ORG="RafiCisco"
#GITHUB_TOKEN="GH_PAT"

# Define repositories and their corresponding teams and permissions
declare -A repos_teams=(
  ["RepoA1"]="admin:admin dev:write"
  ["RepoA2"]="admin:admin dev:write"
  ["RepoA3"]="admin:admin dev:write"
  ["RepoA4"]="admin:admin dev:write"
  ["RepoA5"]="admin:admin dev:write"
  ["RepoB1"]="admin:admin dev:write"
  ["RepoB2"]="admin:admin dev:write"
  ["RepoB3"]="admin:admin dev:write"
  ["RepoB4"]="admin:admin dev:write"
  
)

# Define projects and their corresponding repositories
declare -A projects_repos=(
  ["Project_A"]="RepoA1 RepoA2 RepoA3 RepoA4 RepoA5"
  ["Project_B"]="RepoB1 RepoB2 RepoB3 RepoB4"
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

# Function to create a project
create_project() {
  local project_name=$1

  echo "Creating project $project_name..."

  RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.inertia-preview+json" \
    https://api.github.com/orgs/$GITHUB_ORG/projects \
    -d "{\"name\":\"$project_name\"}")

  PROJECT_ID=$(echo $RESPONSE | jq -r '.id')

  if [ "$PROJECT_ID" == "null" ]; then
    echo "Failed to create project. Response: $RESPONSE"
    exit 1
  else
    echo "Project created with ID: $PROJECT_ID"
  fi
}

# Function to add repositories to a project
add_repos_to_project() {
  local project_id=$1
  shift
  local repos=("$@")

  echo "Adding repositories ${repos[*]} to project $project_id..."

  for repo in "${repos[@]}"; do
    RESPONSE=$(curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.inertia-preview+json" \
      https://api.github.com/projects/$project_id/columns \
      -d "{\"name\":\"$repo\"}")

    COLUMN_ID=$(echo $RESPONSE | jq -r '.id')

    if [ "$COLUMN_ID" == "null" ]; then
      echo "Failed to add repository $repo to project. Response: $RESPONSE"
    else
      echo "Repository $repo added to project $project_id."
    fi
  done
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

# Create projects and add repositories to them
for project_name in "${!projects_repos[@]}"; do
  create_project "$project_name"
  project_id=$PROJECT_ID
  add_repos_to_project "$project_id" ${projects_repos[$project_name]}
done

echo "Done."
