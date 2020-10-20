# Returns if current user is running the shell with elevated permissions
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Returns a shortened version of the current working directory
function Get-ShortenedDirectory {
    param(
        $Directory = (Get-Location).Path,
        $TrailingFolderCount = 3
    )

    $SplitDirectory = ($Directory).Split("\")

    # If the path is long, shorten it
    if ($SplitDirectory.Count -gt ($TrailingFolderCount + 1)) {
        for ($i = ($SplitDirectory.count - $TrailingFolderCount); $i -lt ($SplitDirectory.count); $i++) {
            $TrailingFolders += "\$($SplitDirectory[$i])"
        }
    
        $ShortenedDirectory = $SplitDirectory[0] + "\..." + $TrailingFolders 
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