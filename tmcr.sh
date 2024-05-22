#!/bin/bash

# GitHub variables
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT"

# Function to create a team
create_team() {
    team_name="$1"
    description="$2"
    privacy="$3"
    curl -L -s -X POST \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        "https://api.github.com/orgs/$ORG/teams" \
        -d "{\"name\": \"$team_name\", \"description\": \"$description\", \"privacy\": \"$privacy\"}"
}

# Function to add members to a team
add_members_to_team() {
    team_id="$1"
    members="$2"
    curl -L -s -X PUT \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/teams/$team_id/memberships/$members"
}

# Function to add a team to a repository
add_team_to_repo() {
    team_id="$1"
    repo="$2"
    permission="$3"
    curl -L -s -X PUT \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/teams/$team_id/repos/$ORG/$repo" \
        -d "{\"permission\": \"$permission\"}"
}

# Example usage
create_team "team_name" "Description of the team" "closed"
add_members_to_team "team_id" "username"
add_team_to_repo "team_id" "repo_name" "admin"
