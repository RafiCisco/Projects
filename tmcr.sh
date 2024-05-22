#!/bin/bash

# Variables
GITHUB_ORG="RafiCisco"
#GITHUB_TOKEN="GH_TOKEN" # Repository token
GITHUB_TOKEN="GH_PAT" # PAT


# Define repositories and their corresponding teams and permissions
declare -A repos_teams=(
  ["RepoA1"]="admin:admin dev:write"
  ["RepoA2"]="admin:admin dev:write"
  ["RepoA3"]="admin:admin dev:write"
  ["RepoA4"]="admin:admin dev:write"
  ["RepoA5"]="admin:admin dev:write"
  ["RepoB1"]="admin:admin dev:write"
  ["RepoB2"]="admin:admin dev:write"
  ["RepoB3"]="admin:admin dev:write"
  ["RepoB4"]="admin:admin dev:write"
)

# Define projects and their corresponding repositories
declare -A projects_repos=(
  ["Project_A"]="RepoA1 RepoA2 RepoA3 RepoA4 RepoA5"
  ["Project_B"]="RepoB1 RepoB2 RepoB3 RepoB4"
)

# Function to create a team
create_team() {
  local team_name=$1
  local team_description=$2

  # Clear the GH_TOKEN environment variable if set
unset GH_TOKEN

if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Installing..."
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
    sudo apt-add-repository https://cli.github.com/packages
    sudo apt update
    sudo apt install gh
fi

# Authenticate with GitHub using GitHub CLI
echo "Authenticating with GitHub..."
gh auth login --with-token << EOF
$GITHUB_TOKEN
EOF

# Check if authentication was successful
if [ $? -eq 0 ]; then
    echo "Authentication successful."
else
    echo "Failed to authenticate with GitHub."
fi




# Authenticate with GitHub
#gh auth login --with-token <<<"$GITHUB_TOKEN"

# Create a GitHub team using the GitHub API directly
gh api "/orgs/$GITHUB_ORG/teams" -X POST -F name="$team_name" -F description="$team_description"

# Create a GitHub team
#gh api --silent -X POST "/orgs/$GITHUB_ORG/teams" -d "{\"name\":\"$team_name\", \"description\":\"$team_description\"}"

  if [ $? -ne 0 ]; then
    echo "Failed to create team."
    exit 1
  else
    echo "Team created: $team_name"
  fi
}

# Function to add a team to a repository with a specific permission
add_team_to_repo() {
  local team_slug=$1
  local repo_name=$2
  local permission=$3

  echo "Adding team $team_slug to repository $repo_name with $permission permission..."

  github teams add-repo --org $GITHUB_ORG --team "$team_slug" --repo "$repo_name" --permission "$permission"

  if [ $? -ne 0 ]; then
    echo "Failed to add team to repository."
    exit 1
  else
    echo "Team $team_slug added to repository $repo_name with $permission permission."
  fi
}

# Function to create a project
create_project() {
  local project_name=$1

  echo "Creating project $project_name..."

  github gh api -X POST orgs/$GITHUB_ORG/projects -F name="$project_name"

  if [ $? -ne 0 ]; then
    echo "Failed to create project."
    exit 1
  else
    echo "Project created: $project_name"
  fi
}

# Function to add repositories to a project
add_repos_to_project() {
  local project_name=$1
  shift
  local repos=("$@")

  echo "Adding repositories ${repos[*]} to project $project_name..."

  for repo in "${repos[@]}"; do
    github projects create-column --project "$project_name" --name "$repo"
    if [ $? -ne 0 ]; then
      echo "Failed to add repository $repo to project."
      exit 1
    else
      echo "Repository $repo added to project $project_name."
    fi
  done
}

# Main script
for team_name in "${!repos_teams[@]}"; do
  create_team "$team_name" "${repos_teams[$team_name]}"
done

for team_slug in "${!repos_teams[@]}"; do
  for repo_permission in ${repos_teams[$team_slug]}; do
    IFS=':' read -r -a repo_permission_arr <<< "$repo_permission"
    repo_name="${repo_permission_arr[0]}"
    permission="${repo_permission_arr[1]}"
    add_team_to_repo "$team_slug" "$repo_name" "$permission"
  done
done

for project_name in "${!projects_repos[@]}"; do
  create_project "$project_name"
  add_repos_to_project "$project_name" ${projects_repos[$project_name]}
done

echo "All teams created, assigned to repositories, and projects created."
