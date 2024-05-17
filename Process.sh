#!/bin/bash

# Check if the JSON file exists
if [ ! -f Projects.json ]; then
    echo "Projects.json file not found!"
    exit 1
fi

# Use jq to parse the JSON and print the project names and repository details
jq -r '
    .projects[] | 
    .name as $projectName | 
    .repositories[] | 
    "Project: \($projectName), Repository: \(.name), URL: \(.url)"
' Projects.json
