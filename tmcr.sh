#!/bin/bash

# Variables
ORG_NAME="RafiCisco"  # Replace with your actual organization name
GITHUB_TOKEN="${GITHUB_TOKEN}"  # Replace with your GitHub personal access token

# Team names
ADMIN_TEAM="admin"
DEV_TEAM="dev"

# Function to create a team
create_team() {
    local team_name=$1
    local team_description=$2

    # Check if team already exists
    team_exists=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
                        "https://api.github.com/orgs/$ORG_NAME/teams/$team_name" | jq -r '.id')

    if [ "$team_exists" != "null" ]; then
        echo "Team '$team_name' already exists with ID: $team_exists"
        return 0
    fi

    # Create the team
    response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"name\": \"$team_name\", \"description\": \"$team_description\", \"privacy\": \"closed\"}" \
        "https://api.github.com/orgs/$ORG_NAME/teams")

    team_id=$(echo "$response" | jq -r '.id')

    if [ -n "$team_id" ] && [ "$team_id" != "null" ]; then
        echo "Team '$team_name' created with ID: $team_id"
    else
        echo "Failed to create team '$team_name': $(echo "$response" | jq -r '.message')"
        exit 1
    fi
}

# Function to assign a team to a repository
assign_team_to_repo() {
    local team_name=$1
    local repo_name=$2
    local permission=$3  # admin, write, or pull
    local project_name=$4

    response=$(curl -s -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"permission\": \"$permission\"}" \
        "https://api.github.com/orgs/$ORG_NAME/teams/$team_name/repos/$ORG_NAME/$repo_name")

    if [ "$(echo "$response" | jq -r '.message')" == "null" ]; then
        echo "Assigned repository '$repo_name' to team '$team_name' with '$permission' permission for project '$project_name'."
    else
        echo "Error assigning repository '$repo_name' to team '$team_name': $(echo "$response" | jq -r '.message') for project '$project_name'."
    fi
}

# Create admin and dev teams
create_team "$ADMIN_TEAM" "Admin team with full access"
create_team "$DEV_TEAM" "Development team with restricted access"

# Read project name from repos.json
project_name=$(jq -r '.project_name' repos.json)

# Read repositories from repos.json
repos=$(jq -r '.repositories[].name' repos.json)

# Assign teams to repositories
for repo in $repos; do
    # Assign admin team with admin permission
    assign_team_to_repo "$ADMIN_TEAM" "$repo" "admin" "$project_name"
    # Assign dev team with write permission
    assign_team_to_repo "$DEV_TEAM" "$repo" "write" "$project_name"
done
