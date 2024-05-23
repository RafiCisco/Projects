#!/bin/bash

# GitHub organization name
ORG="RafiCisco"

# GitHub Personal Access Token with appropriate permissions
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Function to check if a team exists
check_team_exists() {
    local team_name=$1

    team_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/orgs/$ORG/teams?per_page=100" | jq -r ".[] | select(.name == \"$team_name\") | .id")

    if [ -n "$team_id" ]; then
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
        "https://api.github.com/repos/$ORG/$repo_name")

    if [ "$response" -eq 200 ]; then
        return 0
    else
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
        "https://api.github.com/orgs/$ORG/teams")

    team_id=$(echo "$response" | jq -r '.id')

    if [ -n "$team_id" ]; then
        echo "Team '$team_name' created with ID: $team_id"
    else
        echo "Failed to create team '$team_name'"
        exit 1
    fi
}

# Function to assign team to repository
assign_team_to_repo() {
    local team_name=$1
    local repo_name=$2

    team_id=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/orgs/$ORG/teams?per_page=100" | jq -r ".[] | select(.name == \"$team_name\") | .id")

    if [ -z "$team_id" ]; then
        echo "Team '$team_name' not found"
        exit 1
    fi

    response=$(curl -s -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/teams/$team_id/repos/$ORG/$repo_name")

    if [ "$(echo "$response" | jq -r '.message')" = "Not Found" ]; then
        echo "Repository '$repo_name' not found"
        exit 1
    fi

    echo "Assigned team '$team_name' to repository '$repo_name'"
}

# Check if teams exist
if ! check_team_exists "admin" && ! check_team_exists "dev"; then
    # Create teams if they don't exist
    create_team "admin" "Admin team with full access"
    create_team "dev" "Development team with restricted access"
else
    echo "Teams already exist"
fi

# Check if repositories exist
if check_repo_exists "repo1" && check_repo_exists "repo2"; then
    # Assign teams to repositories
    assign_team_to_repo "admin" "repo1"
    assign_team_to_repo "admin" "repo2"
    assign_team_to_repo "dev" "repo1"
    assign_team_to_repo "dev" "repo2"
else
    echo "One or more repositories do not exist"
fi
done
