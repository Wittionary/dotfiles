<#
REQUIREMENTS:
Is located in $PsHome
Environment variable "git" is set to the path where you clone your git repos
You've cloned the "dotfiles" repo into your git path

See this resource for details:
https://devblogs.microsoft.com/scripting/understanding-the-six-powershell-profiles/
#>
Clear-Host

try {
    $Functions = Get-ChildItem -Path "$ENV:git\dotfiles\powershell\*.ps1" | Where-Object {$_.Name -ne "profile.ps1"}
    foreach ($Function in $Functions) {
        Import-Module -Name $Function.FullName -Force
    }
    Set-Location -Path $ENV:git
    Test-EnvVariables
    Get-WordOfTheDay
} catch {
    Write-Error "Functions not imported. '`$ENV:git' value of '$ENV:git' is not valid."
}