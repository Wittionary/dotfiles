#Requires -modules Microsoft.PowerShell.PSResourceGet
# Install-Module Microsoft.PowerShell.PSResourceGet -confirm $false; Import-Module Microsoft.PowerShell.PSResourceGet

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
if ($(Get-PSResourceRepository).Name -notcontains "dotfiles") {
    # Register self as a PSResourceRepository
    Register-PSResourceRepository -Name dotfiles -Uri "$env:git\dotfiles\powershell\" -Trusted 
    # Publish scripts/modules
    Publish-PSResource -Path "C:\Users\qwert\Documents\git\dotfiles\powershell\wotd.ps1"
}

# Install all modules in the powershell directory
try {
    Find-PSResource -Repository dotfiles -Tag wordnik | Install-PSResource
    
    $Functions = Get-ChildItem -Path "$ENV:git\dotfiles\powershell\*.ps1" | Where-Object {$_.Name -ne "profile.ps1"}
    foreach ($Function in $Functions) {
        Install-Module -Name $Function.FullName -Force
    }
} catch {
    Write-Error "Functions not imported. '`$ENV:git' value of '$ENV:git' is not valid."
}