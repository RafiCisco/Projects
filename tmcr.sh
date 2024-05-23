#!/bin/bash

# GitHub Organization name
ORGANIZATION="RafiCisco"

# GitHub Token with appropriate permissions
TOKEN="${GITHUB_TOKEN}"

# Teams and their descriptions
declare -A TEAMS
TEAMS["admin"]="Admin team full access"
TEAMS["dev"]="Dev team will have write access"


# Team privacy (closed or secret)
TEAM_PRIVACY="closed"  # or "secret"


# Repositories to assign
REPOSITORIES=("RepoA1" "RepoA2" "RepoB1" "RepoB2")

# Projects to assign (specify project IDs)
PROJECTS=("Project_A" "project_B")



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


# Function to assign a team to a project
assign_team_to_project() {
  local team_id=$1
  local project_id=$2
  local response=$(curl -s -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.github.com/teams/$team_id/projects/$project_id")
  local status=$(echo "$response" | jq -r '.message')

  if [[ "$status" != "null" ]]; then
    echo "Error assigning team $team_id to project $project_id: $status"
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

  for project in "${PROJECTS[@]}"; do
    assign_team_to_project "$team_id" "$project"
  done
done

# Display created teams
echo "Displaying Teams:"
teams=$(curl -s -H "Authorization: token $TOKEN" "https://api.github.com/orgs/$ORGANIZATION/teams" | jq -r '.[].name')
echo "$teams"
