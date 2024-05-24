#!/bin/bash

# GitHub organization name
ORG_NAME="RafiCisco"

# GitHub Personal Access Token with appropriate permissions (provided as an environment variable)
GITHUB_PAT=$1

# Team names
ADMIN_TEAM="admin"
DEV_TEAM="dev"

# Function to assign a team to a repository
assign_team_to_repo() {
    local team_name=$1
    local repo_full_name=$2
    local permission=$3

    echo "Assigning repository '$repo_full_name' to team '$team_name' with '$permission' permission..."

    response=$(curl -s -X PUT \
        -H "Authorization: token $GITHUB_PAT" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"permission\": \"$permission\"}" \
        "https://api.github.com/repos/$repo_full_name/teams/$team_name")

    if [[ "$(echo "$response" | jq -r '.message')" == "null" ]]; then
        echo "Assigned repository '$repo_full_name' to team '$team_name' with '$permission' permission."
    else
        echo "Error assigning repository '$repo_full_name' to team '$team_name': $(echo "$response" | jq -r '.message')"
    fi
}

# Read project name from repos.json
project_name=$(jq -r '.project_name' repos.json)

# Read repositories from repos.json
repos=$(jq -c '.repositories[]' repos.json)

# Assign teams to repositories
for repo in $repos; do
    repo_full_name=$(echo "$repo" | jq -r '.full_name')

    # Assign admin team with admin permission
    assign_team_to_repo "$ADMIN_TEAM" "$repo_full_name" "admin"
    # Assign dev team with write permission
    assign_team_to_repo "$DEV_TEAM" "$repo_full_name" "write"
done
