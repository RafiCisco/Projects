#!/bin/bash

# GitHub organization details
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT

# Function to create a team
create_team() {
  local team_name=$1
  
  # Make API request to create team
  curl -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d "{\"name\": \"$team_name\", \"description\": \"Team description\"}" \
    "https://api.github.com/orgs/$ORG/teams"
}

# Function to get repository ID
get_repo_id() {
  local repo_name=$1
  
  # Make API request to get repository ID
  curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$ORG/$repo_name" | jq -r '.id'
}

# Function to assign team to repository
assign_team_to_repo() {
  local team_name=$1
  local repo_name=$2
  local permission=$3
  
  local team_id=$(create_team "$team_name" | jq -r '.id')
  local repo_id=$(get_repo_id "$repo_name")
  
  # Make API request to assign team to repository
  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -d "{\"permission\": \"$permission\"}" \
    "https://api.github.com/teams/$team_id/repos/$ORG/$repo_id"
}

# Example usage: Assign team "Team1" to repository "repo1" with write permission
assign_team_to_repo "Team1" "repo1" "write"
