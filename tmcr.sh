#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."

    # Detect OS and install jq accordingly
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            install_jq_debian
        elif command -v dnf &> /dev/null; then
            install_jq_fedora
        elif command -v pacman &> /dev/null; then
            install_jq_arch
        else
            echo "Unsupported Linux distribution. Please install jq manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        install_jq_macos
    else
        echo "Unsupported OS. Please install jq manually."
        exit 1
    fi
fi

# Variables
GITHUB_API_URL="https://api.github.com"
ORG_NAME="RafiCisco"
GITHUB_TOKEN="GH_P"

# Function to create a team
create_team() {
    local team_name=$1
    curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "${GITHUB_API_URL}/orgs/${ORG_NAME}/teams" \
        -d "{\"name\": \"${team_name}\"}" | jq -r .id
}

# Function to add a repository to a team
add_repo_to_team() {
    local team_id=$1
    local repo_name=$2
    local permission=$3
    curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "${GITHUB_API_URL}/teams/${team_id}/repos/${ORG_NAME}/${repo_name}" \
        -d "{\"permission\": \"${permission}\"}"
}

# Define an associative array where keys are team names and values are repository:permission pairs
declare -A TEAMS
TEAMS["TeamA"]="repo1:push,repo2:pull"
TEAMS["TeamB"]="repo3:push,repo4:admin"

# Create teams and assign repositories
for team_name in "${!TEAMS[@]}"; do
    echo "Creating team: $team_name"
    team_id=$(create_team "$team_name")
    
    IFS=',' read -ra repos <<< "${TEAMS[$team_name]}"
    for repo in "${repos[@]}"; do
        repo_name=$(echo $repo | cut -d: -f1)
        permission=$(echo $repo | cut -d: -f2)
        
        echo "Adding repository $repo_name to team $team_name with $permission permission"
        add_repo_to_team "$team_id" "$repo_name" "$permission"
    done
done
