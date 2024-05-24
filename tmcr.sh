#!/bin/bash

# GitHub Personal Access Token (Replace 'YOUR_TOKEN' with your actual token)
token="${GITHUB_TOKEN}"

# GitHub Organization or User name (Replace 'YOUR_ORG' with your actual organization or user name)
org="RafiCisco"

# Name of the admin team
admin_team_name="admin"

# Path to JSON file containing repository names
json_file="repos.json"

# Function to create an admin team with administrative access
create_admin_team() {
    admin_team_response=$(curl -X POST \
        -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/orgs/$org/teams" \
        -d "{\"name\": \"$admin_team_name\", \"privacy\": \"closed\", \"permission\": \"admin\"}")

    # Extract admin team ID from the response
    admin_team_id=$(echo "$admin_team_response" | jq -r '.id')

    echo "Admin team created with ID: $admin_team_id"
}

# Function to assign admin team to repositories
assign_admin_team() {
    # Read JSON file and assign admin team to repositories
    while IFS= read -r repo; do
        repo_name=$(echo "$repo" | jq -r '.name')

        # Assign admin team to repository
        curl -X PUT \
            -H "Authorization: token $token" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$org/$repo_name/teams/$admin_team_id"
        echo "Assigned $admin_team_name team to $repo_name"
    done <<< "$(jq -c '.repositories[]' "$json_file")"
}

# Execute function to create admin team
create_admin_team

# Execute function to assign admin team to repositories
assign_admin_team
