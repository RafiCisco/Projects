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

# Example usage: Create a team named "example_team"
create_team "example_team"
