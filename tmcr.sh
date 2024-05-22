#!/bin/bash

# GitHub variables
ORG="RafiCisco"
GITHUB_TOKEN="GH_PAT"

# Function to create a team
create_team() {
    team_name="$1"
    description="$2"
    privacy="$3"

    response=$(curl -s -X POST \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/orgs/$ORG/teams" \
        -d "{\"name\": \"$team_name\", \"description\": \"$description\", \"privacy\": \"$privacy\"}")

    # Extract the team slug from the response
    team_slug=$(echo "$response" | jq -r '.slug')

    echo "$team_slug"
}

# Function to add a team to a repository
add_team_to_repo() {
    team_slug="$1"
    repo="$2"
    permission="$3"

    curl -s -X PUT \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/orgs/$ORG/teams/$team_slug/repos/$ORG/$repo" \
        -d "{\"permission\": \"$permission\"}"
}

# Example usage: Create a team
TEAM_NAME="admin"
DESCRIPTION="Admin team"
PRIVACY="closed"
TEAM_SLUG=$(create_team "$TEAM_NAME" "$DESCRIPTION" "$PRIVACY")

echo "Created team '$TEAM_NAME' with slug '$TEAM_SLUG'"

# Example usage: Add team to repositories
REPOSITORIES=("repo1" "repo2" "repo3")
PERMISSION="admin"

for REPO in "${REPOSITORIES[@]}"; do
    add_team_to_repo "$TEAM_SLUG" "$REPO" "$PERMISSION"
    echo "Added team '$TEAM_NAME' to repository '$REPO' with permission '$PERMISSION'"
done
