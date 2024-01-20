<#
REQUIREMENTS:
Is located in $PsHome
Environment variable "git" is set to the path where you clone your git repos
You've cloned the "dotfiles" repo into your git path

See this resource for details:
https://devblogs.microsoft.com/scripting/understanding-the-six-powershell-profiles/
#>
Clear-Host

Set-Location -Path $ENV:git
Test-EnvVariables
#Get-WordOfTheDay