#!/bin/bash

# GitHub organization details
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT"

# GitHub API endpoint for listing teams
API_URL="https://api.github.com/orgs/$ORG/teams"

# Function to list teams in the organization
list_teams() {
  echo "Listing teams in organization: $ORG"
  
  # Make API request to list teams
  response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$API_URL")
  
  # Check if the request was successful
  if [ $? -eq 0 ]; then
    # Parse the JSON response to extract team names
    team_names=$(echo "$response" | jq -r '.[].name')
    
    # Print the list of team names
    echo "Teams:"
    echo "$team_names"
  else
    # Print error message if the request failed
    echo "Failed to list teams. Check your authentication token and organization name."
  fi
}

# Call the function to list teams
list_teams
