#!/bin/bash

# Function to process each Git repository
process_git_repo() {
    local dir=$1
    echo "Processing Git repository in: $dir"
    pushd "$dir" > /dev/null

    # Run the commands to track all remote branches not currently tracked
    git branch -r | grep -v '\->' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | while read remote; do
        git branch --track "${remote#origin/}" "$remote" 2>/dev/null || echo "Branch already exists: ${remote#origin/}"
    done

    # Fetch all remote branches
    echo "Fetching all remote branches in: $dir"
    git fetch --all || echo "Failed to fetch updates from remote."

    # Pull updates from all remote branches
    echo "Pulling all remote branches in: $dir"
    git pull --all || echo "Failed to pull updates from remote."

    popd > /dev/null
}

export -f process_git_repo

# Find all directories containing a .git folder and process each one
find . -type d -name ".git" | while read gitdir; do
    repo_dir="$(dirname "$gitdir")"
    echo "Found .git in $repo_dir"
    process_git_repo "$repo_dir"
done
