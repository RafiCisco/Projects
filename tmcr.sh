#!/bin/bash

# GitHub organization details
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT"

# Function to create a team
create_team() {
  local team_name=$1
  
  # Make API request to create team
  create_team_response=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/orgs/$ORG/teams" \
    -d "{\"name\": \"$team_name\", \"description\": \"$team_name team\", \"privacy\": \"closed\"}")
  
  # Extract team ID from response
  team_id=$(echo "$create_team_response" | jq -r '.[].id')
  echo "$team_id"
}

# Function to get project IDs
get_project_ids() {
  # Make API request to get projects
  projects_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORG/projects")
  
  # Extract project IDs from response
  project_ids=$(echo "$projects_response" | jq -r '.[].id')
  echo "$project_ids"
}

# Function to get repository IDs in a project
get_repo_ids() {
  local project_id=$1
  
  # Make API request to get repositories in project
  repos_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/projects/$project_id/repos")
  
  # Extract repository IDs from response
  repo_ids=$(echo "$repos_response" | jq -r '.[].id')
  echo "$repo_ids"
}

# Function to assign team to repositories
assign_team_to_repos() {
  local team_id=$1
  local repo_ids=$2
  
  # Loop through repository IDs and assign team to each repository
  for repo_id in $repo_ids; do
    # Make API request to assign team to repository
    curl -s -X PUT \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/teams/$team_id/repos/$ORG/$repo_id" \
      -d '{"permission": "push"}'
  done
}

# Example usage: Create teams and assign them to repositories
team_id=$(create_team "admin")
project_ids=$(get_project_ids)

# Loop through project IDs
for project_id in $project_ids; do
  repo_ids=$(get_repo_ids "$project_id")
  assign_team_to_repos "$team_id" "$repo_ids"
done
