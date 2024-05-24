#!/bin/bash

# GitHub organization name
ORG_NAME="RafiCisco"

# Project name
PROJECT_NAME="Project_A"

# Team names
ADMIN_TEAM="admin"
DEV_TEAM="dev"

# GitHub Personal Access Token with appropriate permissions
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Function to check if a team exists
check_team_exists() {
    local team_name=$1

    team_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/orgs/$ORG_NAME/teams?per_page=100" | jq -r ".[] | select(.name == \"$team_name\") | .id")

    if [ -n "$team_id" ]; then
        echo "Team '$team_name' exists with ID: $team_id"
        return 0
    else
        return 1
    fi
}

# Function to check if a repository exists
check_repo_exists() {
    local repo_name=$1

    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$ORG_NAME/$repo_name")

    if [ "$response" -eq 200 ]; then
        echo "Repository '$repo_name' exists"
        return 0
    else
        echo "Repository '$repo_name' does not exist"
        return 1
    fi
}

# Function to create a team
create_team() {
    local team_name=$1
    local team_description=$2

    response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"name\": \"$team_name\", \"description\": \"$team_description\", \"privacy\": \"closed\"}" \
        "https://api.github.com/orgs/$ORG_NAME/teams")

    team_id=$(echo "$response" | jq -r '.id')

    if [ -n "$team_id" ]; then
        echo "Team '$team_name' created with ID: $team_id"
    else
        echo "Failed to create team '$team_name': $(echo "$response" | jq -r '.message')"
        exit 1
    fi
}

# Function to assign team to repository
assign_team_to_repo() {
    local team_name=$1
    local repo_name=$2
    local permission=$3

    team_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/orgs/$ORG_NAME/teams?per_page=100" | jq -r ".[] | select(.name == \"$team_name\") | .id")

    if [ -z "$team_id" ]; then
        echo "Team '$team_name' not found"
        exit 1
    fi

    response=$(curl -s -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"permission\": \"$permission\"}" \
        "https://api.github.com/teams/$team_id/repos/$ORG_NAME/$repo_name")

    if [ "$(echo "$response" | jq -r '.message')" = "Not Found" ]; then
        echo "Repository '$repo_name' not found"
        exit 1
    elif [ "$(echo "$response" | jq -r '.message')" = "Validation Failed" ]; then
        echo "Error assigning repository '$repo_name' to team '$team_name': Validation Failed"
        exit 1
    fi

    echo "Assigned team '$team_name' to repository '$repo_name' with '$permission' permission"
}

# Main script execution

# Check if admin team exists and create if it doesn't
if ! check_team_exists "$ADMIN_TEAM"; then
    create_team "$ADMIN_TEAM" "Admin team with full access"
else
    echo "Team '$ADMIN_TEAM' already exists"
fi

# Check if dev team exists and create if it doesn't
if ! check_team_exists "$DEV_TEAM"; then
    create_team "$DEV_TEAM" "Development team with restricted access"
else
    echo "Team '$DEV_TEAM' already exists"
fi

# Get list of repositories in Project_A
repositories=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$ORG_NAME/projects/$PROJECT_NAME/repos" | jq -r '.[] | .name')

# Display project name
echo "Project: $PROJECT_NAME"

# Assign teams to repositories
for repo in $repositories; do
    if check_repo_exists "$repo"; then
        # Assign admin team with admin permission
        assign_team_to_repo "$ADMIN_TEAM" "$repo" "admin"
        # Assign dev team with write permission
        assign_team_to_repo "$DEV_TEAM" "$repo" "write"
    else
        echo "Repository '$repo' does not exist"
    fi
done
