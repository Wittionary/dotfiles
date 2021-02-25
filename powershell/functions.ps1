# Returns if current user is running the shell with elevated permissions
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Return the git branch that's currently checked out, if any
function Get-GitCheckedOutBranch {
    $CheckedOutBranch = $null
    $Branches = git branch --list
    $CheckedOutBranch = $Branches | Where-Object { $_ -match "\*" }
    # Get rid of asterisk
    $CheckedOutBranch = $CheckedOutBranch.Remove(0, 2)

    return $CheckedOutBranch
}

# Returns if the current working directory is a git repo or subdir of a repo
function Test-IsGitRepo {
    $SplitRepoPath = $pwd.Path.Split("\")

    $AssembledPath = ""
    foreach ($Folder in $SplitRepoPath) {
        $AssembledPath += "$Folder\"
        $GitFolder = Get-ChildItem -Path $AssembledPath -Hidden -Name ".git"

        if ($GitFolder) {
            return $true
        }
    }

    return $false
}

# Returns a shortened version of the current working directory
function Get-ShortenedDirectory {
    param(
        $Directory = (Get-Location).Path,
        $TrailingFolderCount = 2
    )

    $SplitDirectory = ($Directory).Split("\")

    # If the path is long, shorten it
    if ($SplitDirectory.Count -gt ($TrailingFolderCount + 1)) {
        for ($i = ($SplitDirectory.count - $TrailingFolderCount); $i -lt ($SplitDirectory.count); $i++) {
            $TrailingFolders += "\$($SplitDirectory[$i])"
        }
        
        if ($SplitDirectory[0] -eq "C:"){
            $ShortenedDirectory = ".." + $TrailingFolders
        } else {
            $ShortenedDirectory = $SplitDirectory[0] + "\..." + $TrailingFolders
        }
        
        return $ShortenedDirectory
    } else {
        # It's short enough already
        return $Directory
    }
}

# Sync your current Domain Controller and then sync to Azure
function Sync-ToAzure {
    param(
        # This may not always be the DC you're connect to in ADUC via MMC
        $DomainController = (Get-ADDomainController).Hostname,

        [Parameter(Mandatory=$true)]
        $AzureSyncServer,

        $PatienceInterval = 5
    )

    Write-Host "Syncing to $DomainController"
    Invoke-Command $DomainController -ScriptBlock {repadmin /syncall}
    Write-Host "Waiting for $PatienceInterval seconds"
    Start-Sleep -s $PatienceInterval
    # May need to Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
    Invoke-Command $AzureSyncServer -FilePath "\\$AzureSyncServer\D$\scripts\sync-adconnect.ps1"
}

# Start a PSsession with the on-prem Exchange server
function Connect-OnPremExchange {
    param(
        $ExchangeServerFQDN,

        $PrivilegedCreds = (Get-Credential)
    )
    #$PrivilegedCreds = ConvertTo-SecureString $PrivilegedCreds
    $OnPremExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServerFQDN/PowerShell/" -Authentication Kerberos -Credential $PrivilegedCreds
    Import-PSSession $OnPremExchangeSession -DisableNameChecking
}

# End a PSsession with the on-prem Exchange server
function Disconnect-OnPremExchange {
    Remove-PSSession $OnPremExchangeSession
}

# Unlock privileged account
function ul {
    param (
        [Parameter(Position=0)]
        $CommandSequence = "dc"
    )
    if ($CommandSequence -eq "dc") {
        Get-ADUser pvl_dchristy | Unlock-ADAccount
    } elseif ($CommandSequence -eq "lt") {
        Get-ADUser pvl_ltomlin | Unlock-ADAccount
    } elseif ($CommandSequence -eq "lm") {
        Get-ADUser pvl_lmajors | Unlock-ADAccount
    }
}

# Git aliases
function g {
    param (
        [Parameter(Position=0)]
        $CommandSequence = "s"
    )
    if ($CommandSequence -eq "s") {
        & git status -sb
    } elseif ($CommandSequence -eq "b") {
        & git branch --list
    } elseif ($CommandSequence -eq "p") {
        & git pull
    } elseif ($CommandSequence -eq "can") {
        # Commit all now; maybe add auto-push later
        & git add .
        $CommitMessage = "Commit All @ $(Get-Date -Format "MM-dd-yyyy HH:mm:ss")"
        & git commit -am $CommitMessage
    } elseif ($CommandSequence -eq "pp") {
        # Push
        & git push
    }
}

# How Dare You gif
function hdyg {
    $GifURL = "https://media.giphy.com/media/U1aN4HTfJ2SmgB2BBK/giphy.gif"
    $GifURL | Set-Clipboard
}