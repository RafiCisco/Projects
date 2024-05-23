#!/bin/bash

set -e

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
TOKEN="${GITHUB_TOKEN}"


# Teams and their descriptions
declare -A TEAMS
TEAMS["admin"]="Admin team description"
TEAMS["dev"]="Dev team description"

# Repositories to assign
REPOSITORIES=("RepoA1" "RepoA2")

# Projects to assign (specify project names)
PROJECT_NAMES=("Project1" "Project2")

# Team privacy
TEAM_PRIVACY="closed"  # or "secret"

# Function to get project ID by name
get_project_id() {
  local project_name=$1
  local response=$(curl -s -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.inertia-preview+json" \
    "https://api.github.com/orgs/$ORGANIZATION/projects")
  local project_id=$(echo "$response" | jq -r --arg name "$project_name" '.[] | select(.name == $name) | .id')

  if [[ -z "$project_id" ]]; then
    echo "Error: Project $project_name not found"
    exit 1
  else
    echo "$project_id"
  fi
}

# Function to create a team
create_team() {
  local team_name=$1
  local team_description=$2
  local response=$(curl -s -X POST \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"$team_name\", \"description\": \"$team_description\", \"privacy\": \"$TEAM_PRIVACY\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams")
  local team_id=$(echo "$response" | jq -r '.id')
  local error_message=$(echo "$response" | jq -r '.message')

  if [[ "$team_id" == "null" ]]; then
    echo "Error creating team $team_name: $error_message"
    exit 1
  else
    echo "Team '$team_name' created with ID $team_id"
    echo $team_id
  fi
}

# Function to assign a team to a repository
assign_team_to_repo() {
  local team_slug=$1
  local repo_name=$2
  local permission=$3
  echo "Assigning team $team_slug to repo $repo_name with $permission permission"
  local response=$(curl -s -o /dev/stderr -w "%{http_code}" -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"permission\": \"$permission\"}" \
    "https://api.github.com/orgs/$ORGANIZATION/teams/$team_slug/repos/$ORGANIZATION/$repo_name")
  
  if [[ "$response" != "204" ]]; then
    echo "Error assigning team $team_slug to repo $repo_name"
  else
    echo "Team '$team_slug' assigned to repo '$repo_name' with '$permission' permission"
  fi
}

# Function to assign a team to a project
assign_team_to_project() {
  local team_id=$1
  local project_id=$2
  echo "Assigning team ID $team_id to project ID $project_id"
  local response=$(curl -s -o /dev/stderr -w "%{http_code}" -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    -H "Accept: application/vnd.github.inertia-preview+json" \
    "https://api.github.com/teams/$team_id/projects/$project_id")
  
  if [[ "$response" != "204" ]]; then
    echo "Error assigning team $team_id to project $project_id"
  else
    echo "Team '$team_id' assigned to project '$project_id'"
  fi
}

# Create teams and assign them to repositories and projects
for team in "${!TEAMS[@]}"; do
  team_description=${TEAMS[$team]}
  team_id=$(create_team "$team" "$team_description")
  team_slug=$(echo $team | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

  for repo in "${REPOSITORIES[@]}"; do
    assign_team_to_repo "$team_slug" "$repo" "push"  # use "push" for write access, "admin" for admin access, or "pull" for read access
  done

  for project_name in "${PROJECT_NAMES[@]}"; do
    project_id=$(get_project_id "$project_name")
    assign_team_to_project "$team_id" "$project_id"
  done
done

# Display created teams
echo "Displaying Teams:"
teams=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/orgs/$ORGANIZATION/teams" | jq -r '.[].name')
echo "$teams"
