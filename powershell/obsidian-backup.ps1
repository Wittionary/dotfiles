# Backup Obsidian vaults to my git repo that's already setup
# Uses git aliases. Might not be best practice or leave as readable in future.
function obsidian-backup {
    param (
        [ValidateScript({Test-Path $_, "Vaults folder not found at $_"})]
        $VaultLocation = "$env:git\obsidian-vaults\"
    )
    
    $WorkingDirectory = Get-Location
    Set-Location -Path $VaultLocation
    # Same as 'g can' alias
    & git add .
    $CommitMessage = "Commit All @ $(Get-Date -Format "MM-dd-yyyy HH:mm:ss")"
    & git commit -am $CommitMessage
    # Same as 'g pp' alias
    & git push --progress
    
    Set-Location -Path $WorkingDirectory

}