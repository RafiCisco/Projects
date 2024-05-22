#!/bin/bash

# GitHub organization details
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT"
PROJECT_NAME="Project_A"

# Function to check if team exists
team_exists() {
  local team_name=$1
  
  # Make API request to check if team exists
  team_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORG/teams/$team_name")
  
  # Check if team exists
  if [ "$(echo "$team_response" | jq -r '.message')" == "Not Found" ]; then
    echo "false"
  else
    echo "true"
  fi
}

# Function to create a team if it doesn't exist
create_team_if_not_exists() {
  local team_name=$1
  
  # Check if team exists
  if [ "$(team_exists "$team_name")" == "false" ]; then
    # Make API request to create team
    team_response=$(curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/orgs/$ORG/teams" \
      -d "{\"name\": \"$team_name\", \"description\": \"$team_name team\", \"privacy\": \"closed\"}")
    
    # Extract team ID from response
    team_id=$(echo "$team_response" | jq -r '.id')
    echo "$team_id"
  fi
}

# Function to get repository IDs in a project
get_project_repos() {
  local project_name=$1
  
  # Make API request to get project details
  project_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORG/projects" | jq -r --arg project_name "$project_name" '.[] | select(.name == $project_name) | .id')
  
  # Get project ID from response
  project_id=$(echo "$project_response" | jq -r '.id')
  
  # Make API request to get repository IDs in project
  repos_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/projects/$project_id/repos")
  
  # Extract repository names from response
  repo_names=$(echo "$repos_response" | jq -r '.[].name')
  echo "$repo_names"
}

# Function to assign team to repository
assign_team_to_repo() {
  local team_name=$1
  local repo_name=$2
  local permission=$3
  
  # Create team if it doesn't exist
  team_id=$(create_team_if_not_exists "$team_name")
  
  # Make sure team was created successfully
  if [ -z "$team_id" ]; then
    echo "Failed to create team '$team_name'."
    exit 1
  fi
  
  # Make API request to assign team to repository
  assign_team_response=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/teams/$team_id/repos/$ORG/$repo_name" \
    -d "{\"permission\": \"$permission\"}")
  
  # Check if the assignment was successful
  if [ "$(echo "$assign_team_response" | jq -r '.message')" == "Not Found" ]; then
    echo "Failed to assign repository '$repo_name' to team '$team_name'. Response from GitHub: $assign_team_response"
  else
    echo "Team '$team_name' assigned to repository '$repo_name' successfully."
  fi
}

# Example usage: Assign teams to repositories in Project_A
repos=$(get_project_repos "$PROJECT_NAME")

# Assign teams to each repository in the project
for repo in $repos; do
  assign_team_to_repo "admin" "$repo" "admin"
  assign_team_to_repo "dev" "$repo" "push"
done
