#!/bin/bash

# GitHub organization details
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT"

# Function to create a team
create_team() {
  local team_name=$1
  
  # Make API request to create team
  team_response=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/teams" \
    -d "{\"name\": \"$team_name\", \"description\": \"$team_name team\", \"privacy\": \"closed\"}")
  
  # Extract team ID from response
  team_id=$(echo "$team_response" | jq -r '.id')
  echo "$team_id"
}

# Function to get project ID
get_project_id() {
  local project_name=$1
  
  # Make API request to get project ID
  project_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORG/projects" | jq -r --arg project_name "$project_name" '.[] | select(.name == $project_name) | .id')
  
  echo "$project_id"
}

# Function to get repository ID
get_repo_id() {
  local repo_name=$1
  
  # Make API request to get repository ID
  repo_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$ORG/$repo_name" | jq -r '.id')
  
  echo "$repo_id"
}

# Function to assign team to repository
assign_team_to_repo() {
  local team_id=$1
  local repo_name=$2
  local permission=$3
  local repo_id=$(get_repo_id "$repo_name")
  
  # Make API request to assign team to repository
  assign_team_response=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/teams/$team_id/repos/$ORG/$repo_name" \
    -d "{\"permission\": \"$permission\"}")
  
  # Check if the assignment was successful
  if [ "$(echo "$assign_team_response" | jq -r '.message')" == "Not Found" ]; then
    echo "Failed to assign team to repository $repo_name. Repository not found."
  else
    echo "Team assigned to repository $repo_name successfully."
  fi
}

# Example usage: Create teams (admin and dev) for RepoA1 of Project_A
project_id=$(get_project_id "Project_A")

# Create teams
admin_team_id=$(create_team "admin")
dev_team_id=$(create_team "dev")

# Assign teams to repository with appropriate permissions
assign_team_to_repo "$admin_team_id" "RepoA1" "admin"
assign_team_to_repo "$dev_team_id" "RepoA1" "push"
