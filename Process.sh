#!/bin/bash

# Read the JSON file
json=$(<Projects.json)

# Parse JSON data using jq
projects=$(echo "$json" | jq -r '.Projects[]')

# Loop through each project
echo "$projects" | while IFS= read -r project; do
    projectName=$(echo "$project" | jq -r '.name')
    repositories=$(echo "$project" | jq -r '.repositories[]')

    # Display project name
    echo "Projects: $projectName"

    # Loop through each repository
    echo "$repositories" | while IFS= read -r repository; do
        repoName=$(echo "$repository" | jq -r '.name')
        repoUrl=$(echo "$repository" | jq -r '.url')

        # Display repository name and URL
        echo "  Repository: $repoName - $repoUrl"
    done
done
