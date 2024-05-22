#!/bin/bash

# GitHub organization details
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT"

# Function to create a team
create_team() {
  local team_name=$1
  local team_slug=$(echo "$team_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  
  # Make API request to create team and print the raw response
  create_team_response=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/teams" \
    -d "{\"name\": \"$team_name\", \"description\": \"Team description\", \"privacy\": \"closed\"}")
  
  # Print the raw JSON response
  echo "Create Team Response:"
  echo "$create_team_response"
  
  # Extract team ID from response
  team_id=$(echo "$create_team_response" | jq -r '.id')
  echo "$team_id"
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

# Example usage: Create a team and assign it to a repository
team_id=$(create_team "Team1")

# Assign the team to a repository with desired permission
assign_team_to_repo "$team_id" "repo1" "admin"
