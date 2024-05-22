#!/bin/bash

# Set your personal access token
export GITHUB_TOKEN="GH_PAT"

# Define organization and team details
ORG_NAME="RafiCisco"
REPO_NAME="RepoA1"

# Team details
TEAM1_NAME="admin"
TEAM1_DESCRIPTION="Admin team with full permissions"
TEAM1_PERMISSION="admin"  # Admin permission

TEAM2_NAME="dev"
TEAM2_DESCRIPTION="Development team with push permissions"
TEAM2_PERMISSION="push"  # Push permission

# Function to create a team
create_team() {
    local TEAM_NAME=$1
    local TEAM_DESCRIPTION=$2
    
    response=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/orgs/$ORG_NAME/teams \
        -d '{"name": "'"$TEAM_NAME"'", "description": "'"$TEAM_DESCRIPTION"'", "privacy": "closed"}')
    
    if echo "$response" | grep -q '"id"'; then
        echo "Team '$TEAM_NAME' created successfully in organization '$ORG_NAME'."
        TEAM_SLUG=$(echo $response | jq -r '.slug')
        echo $TEAM_SLUG
    else
        echo "Failed to create team '$TEAM_NAME'. Response from GitHub:"
        echo "$response"
        exit 1
    fi
}

# Function to assign repository to a team
assign_repo_to_team() {
    local TEAM_SLUG=$1
    local REPO_NAME=$2
    local PERMISSION=$3

    response=$(curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/orgs/$ORG_NAME/teams/$TEAM_SLUG/repos/$ORG_NAME/$REPO_NAME \
        -d '{"permission": "'"$PERMISSION"'"}')
    
    if [ -z "$response" ]; then
        echo "Repository '$REPO_NAME' assigned to team '$TEAM_SLUG' with '$PERMISSION' permission."
    else
        echo "Failed to assign repository '$REPO_NAME' to team '$TEAM_SLUG'. Response from GitHub:"
        echo "$response"
    fi
}

# Create the admin team and get its slug
TEAM1_SLUG=$(create_team "$TEAM1_NAME" "$TEAM1_DESCRIPTION")

# Create the dev team and get its slug
TEAM2_SLUG=$(create_team "$TEAM2_NAME" "$TEAM2_DESCRIPTION")

# Assign the repository to the admin team
assign_repo_to_team "$TEAM1_SLUG" "$REPO_NAME" "$TEAM1_PERMISSION"

# Assign the repository to the dev team
assign_repo_to_team "$TEAM2_SLUG" "$REPO_NAME" "$TEAM2_PERMISSION"
