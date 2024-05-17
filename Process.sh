#!/bin/bash

# Path to the JSON file
JSON_FILE="Projects.json"

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is required but not installed. Please install jq and try again."
    exit 1
fi

# Check if the JSON file exists
if [[ ! -f "$JSON_FILE" ]]; then
    echo "JSON file $JSON_FILE not found!"
    exit 1
fi

# Read and process the JSON file
jq -r '.projects[] | .repositories[] | .url' "$JSON_FILE" | while read -r repo_url; do
    echo "Cloning $repo_url..."
    git clone "$repo_url"
done
