function Process-GitRepo {
    param (
        [string]$dir
    )
    Write-Output "Processing Git repository in: $dir"
    Push-Location $dir

    # Run the commands to track all remote branches not currently tracked
    git branch -r | Select-String -Pattern '\->' -NotMatch | ForEach-Object {
        $remote = $_ -replace '\x1B\[[0-9;]*[a-zA-Z]', ''
        $branchName = $remote -replace '^origin/', ''
        try {
            git branch --track $branchName $remote 2>$null
        }
        catch {
            Write-Output "Branch already exists: $branchName"
        }
    }

    # Fetch all remote branches
    Write-Output "Fetching all remote branches in: $dir"
    try {
        git fetch --all
    }
    catch {
        Write-Output "Failed to fetch updates from remote."
    }

    # Pull updates from all remote branches
    Write-Output "Pulling all remote branches in: $dir"
    try {
        git pull --all
    }
    catch {
        Write-Output "Failed to pull updates from remote."
    }

    Pop-Location
}

# Find all directories containing a .git folder and process each one
Get-ChildItem -Path . -Filter '.git' -Recurse -Directory | ForEach-Object {
    $repoDir = $_.DirectoryName
    Write-Output "Found .git in $repoDir"
    Process-GitRepo -dir $repoDir
}
