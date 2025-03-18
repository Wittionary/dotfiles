# Git aliases
function g {
    param (
        [Parameter(Position=0)]
        $CommandSequence = "s",

        [Parameter(Position=1)]
        $String = ""
    )
    
    if ($CommandSequence -eq "s") {
        & git status -sb
    } elseif ($CommandSequence -eq "b") {
        & git branch --list
    } elseif ($CommandSequence -eq "p") {
        & git pull
    } elseif ($CommandSequence -eq "cm") {
        # Commit with a message
        $CommitMessage = $String
        & git commit -m $CommitMessage
    } elseif ($CommandSequence -eq "can") {
        # Commit all now; maybe add auto-push later
        & git add .
        $CommitMessage = "Commit All @ $(Get-Date -Format "MM-dd-yyyy HH:mm:ss")"
        & git commit -am $CommitMessage
    } elseif ($CommandSequence -eq "ca") {
        # Commit all with message
        & git add .
        $CommitMessage = $String
        & git commit -am $CommitMessage
    } elseif ($CommandSequence -eq "cu") {
        # Undo that last commit
        Write-Host "StackOverflow link is in clipboard" -ForegroundColor Yellow
        Set-Clipboard "https://stackoverflow.com/questions/927358/how-do-i-undo-the-most-recent-local-commits-in-git"
        #Write-Host "git commit 'undo'" -ForegroundColor Blue
        #& git reset HEAD~1
    } elseif ($CommandSequence -eq "pp") {
        # Push
        & git push --progress
    } elseif ($CommandSequence -eq "l") {
        # Recent commits
        & git log -3
    } elseif ($CommandSequence -eq "ll") {
        # All of the commits
        & git log
    } elseif ($CommandSequence -eq "ch") {
        # Checkout
        if ($String -ne "") {
            git checkout $String
        } else {
            # TODO: test for existance of fzf
            & git checkout $(
                    git branch --list | 
                    Where-Object {$_ -notmatch "\*"} | # everything but the currently selected branch
                    ForEach-Object {$_.trim()} | fzf --height 25% --layout=reverse
                )
        }
    }
}

# ---------- May want to split the following into their own prompt-git.ps1 module instead
# Return the git branch that's currently checked out, if any
function Get-GitCheckedOutBranch {
    $CheckedOutBranch = $null
    $Branches = git branch --list
    $CheckedOutBranch = $Branches | Where-Object { $_ -match "\*" }
    # Get rid of asterisk
    $CheckedOutBranch = $CheckedOutBranch.Remove(0, 2)

    return $CheckedOutBranch
}

# Return the number of local branches
function Get-GitNumberOfBranches {
    $Branches = git branch --list
    $NumberOfBranches = $Branches.Count

    return $NumberOfBranches
}

# Returns if the current working directory is a git repo or subdir of a repo
function Test-IsGitRepo {
    # If in a child folder of $ENV:git, it *should* be a git repo
    if ($pwd.path -match "$($env:git.Replace("\","\\"))\\") {
        return $true
    }
    return $false
}