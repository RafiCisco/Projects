#!/bin/bash

# GitHub Personal Access Token (Replace 'YOUR_TOKEN' with your actual token)
token="${GITHUB_TOKEN}"
#GITHUB_TOKEN="${GITHUB_TOKEN}"

# GitHub Organization or User name (Replace 'YOUR_ORG' with your actual organization or user name)
org="RafiCisco"


# Read input JSON file
json_file="$1"

# Check if JSON file is provided as argument
if [ -z "$json_file" ]; then
    echo "Usage: $0 repos.json"
    exit 1
fi

# Check if JSON file exists
if [ ! -f "$json_file" ]; then
    echo "Error: JSON file '$json_file' not found."
    exit 1
fi

# Read JSON file and assign admin team to repositories
repositories=$(jq -c '.repositories[]' "$json_file")
while IFS= read -r repo; do
    repo_name=$(echo "$repo" | jq -r '.name')
    
    # Assign admin team to repository
    curl -X PUT \
        -H "Authorization: token $token" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$org/$repo_name/teams/admin"
    echo "Assigned admin team to repository '$repo_name'"
done <<< "$repositories"
