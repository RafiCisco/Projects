
#!/bin/bash

# Variables
ORG_NAME="RafiCisco"  # Replace with your actual organization name
REPOS=("RepoA1" "RepoA2")
ADMIN_TEAM="Admin"
DEV_TEAM="dev"
GITHUB_TOKEN="${GITHUB_TOKEN}"  # Replace with your GitHub personal access token

# Function to check if a team exists
check_team_exists() {
  TEAM_NAME=$1
  echo "Checking if team $TEAM_NAME exists..."
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/orgs/$ORG_NAME/teams/$TEAM_NAME)
  if [ "$RESPONSE" -eq 200 ]; then
    echo "Team $TEAM_NAME exists."
    return 0
  else
    echo "Team $TEAM_NAME does not exist."
    return 1
  fi
}

# Function to create a team
create_team() {
  TEAM_NAME=$1
  echo "Creating team: $TEAM_NAME"
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/orgs/$ORG_NAME/teams -d '{"name":"'"$TEAM_NAME"'", "privacy":"closed"}')
  if [ "$RESPONSE" -eq 201 ]; then
    echo "Team $TEAM_NAME created successfully."
  else
    echo "Failed to create team $TEAM_NAME. Response code: $RESPONSE"
  fi
}

# Function to assign team to repo with specific permission
assign_team_to_repo() {
  TEAM_NAME=$1
  REPO_NAME=$2
  PERMISSION=$3
  echo "Assigning team $TEAM_NAME to repo $REPO_NAME with $PERMISSION permissions"
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/orgs/$ORG_NAME/teams/$TEAM_NAME/repos/$ORG_NAME/$REPO_NAME -d '{"permission":"'"$PERMISSION"'"}')
  if [ "$RESPONSE" -eq 204 ]; then
    echo "Team $TEAM_NAME assigned to repo $REPO_NAME with $PERMISSION permissions successfully."
  else
    echo "Failed to assign team $TEAM_NAME to repo $REPO_NAME. Response code: $RESPONSE"
  fi
}

# Check and create admin team if it doesn't exist
if ! check_team_exists $ADMIN_TEAM; then
  create_team $ADMIN_TEAM
fi

# Check and create dev team if it doesn't exist
if ! check_team_exists $DEV_TEAM; then
  create_team $DEV_TEAM
fi

# Assign permissions to repos
for REPO_NAME in "${REPOS[@]}"; do
  assign_team_to_repo $ADMIN_TEAM $REPO_NAME "admin"
  assign_team_to_repo $DEV_TEAM $REPO_NAME "push"
done

echo "Setup complete."
