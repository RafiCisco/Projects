#!/bin/bash

# GitHub organization details
ORG="RafiCisco"
#GITHUB_TOKEN="GH_PAT"
GITHUB_TOKEN="GH_TOKEN"
PROJECT_NAME="Project_A"

# Team details
TEAM_NAMES=("admin" "dev")

# Repository details
REPO_NAMES=("RepoA1" "RepoA2" "RepoA3")

# Function to create a team
create_team() {
  local team_name=$1
  local team_slug=$(echo "$team_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  
  create_team_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/teams" \
    -d "{\"name\": \"$team_name\", \"description\": \"A new team\", \"privacy\": \"closed\"}")
  
  if [ "$create_team_response" -eq 201 ]; then
    echo "Team $team_name created successfully."
  else
    echo "Failed to create team $team_name. HTTP Status: $create_team_response"
  fi
}

# Function to assign a team to a repository
assign_team_to_repo() {
  local team_name=$1
  local repo_name=$2
  local permission=$3
  
  local team_slug=$(echo "$team_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  
  assign_team_response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/teams/$team_slug/repos/$ORG/$repo_name" \
    -d "{\"permission\": \"$permission\"}")
  
  if [ "$assign_team_response" -eq 204 ]; then
    echo "Team $team_name assigned to repository $repo_name successfully."
  else
    echo "Failed to assign team $team_name to repository $repo_name. HTTP Status: $assign_team_response"
  fi
}

# Function to create a project
create_project() {
  local project_name=$1
  
  create_project_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/projects" \
    -d "{\"name\": \"$project_name\"}")

  if [ "$create_project_response" -eq 201 ]; then
    echo "Project $project_name created successfully."
  else
    echo "Failed to create project $project_name. HTTP Status: $create_project_response"
  fi
}

# Function to get project ID
get_project_id() {
  local project_name=$1

  project_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.inertia-preview+json" \
    "https://api.github.com/orgs/$ORG/projects" | jq -r ".[] | select(.name == \"$project_name\") | .id")

  echo "$project_id"
}

# Create teams
for team_name in "${TEAM_NAMES[@]}"; do
  create_team "$team_name"
done

# Create the project
create_project "$PROJECT_NAME"

# Get the project ID
project_id=$(get_project_id "$PROJECT_NAME")

# Assign teams to repositories within the project
for repo_name in "${REPO_NAMES[@]}"; do
  for team_name in "${TEAM_NAMES[@]}"; do
    assign_team_to_repo "$team_name" "$repo_name" "push"
  done
done

# Function to add repositories to a project
add_repo_to_project() {
  local project_id=$1
  local repo_name=$2

  add_repo_response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.inertia-preview+json" \
    "https://api.github.com/projects/$project_id/columns" \
    -d "{\"name\": \"$repo_name\", \"position\": 1}")

  if [ "$add_repo_response" -eq 201 ]; then
    echo "Repository $repo_name added to project $PROJECT_NAME successfully."
  else
    echo "Failed to add repository $repo_name to project $PROJECT_NAME. HTTP Status: $add_repo_response"
  fi
}

# Add repositories to the project
for repo_name in "${REPO_NAMES[@]}"; do
  add_repo_to_project "$project_id" "$repo_name"
done
