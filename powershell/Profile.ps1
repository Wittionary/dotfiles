<#
REQUIREMENTS:
Is located in $PsHome
Environment variable "git" is set to the path where you clone your git repos
You've cloned the "dotfiles" repo into your git path

See this resource for details:
https://devblogs.microsoft.com/scripting/understanding-the-six-powershell-profiles/
#>
Clear-Host
# https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Basic&text=dotfiles
# DOTFILES
$Toast = "
d8888b.  .d88b.  d888888b d88888b d888888b db      d88888b .d8888. 
88  ``8D .8P  Y8. ``~~88~~`` 88'       ``88'   88      88'     88'  YP 
88   88 88    88    88    88ooo      88    88      88ooooo ``8bo.   
88   88 88    88    88    88~~~      88    88      88~~~~~   ``Y8b.    
88  .8D ``8b  d8'    88    88        .88.   88booo. 88.     db   8D  
Y8888D'  ``Y88P'     YP    YP      Y888888P Y88888P Y88888P ``8888Y'                                                                    
"
#Write-Host $Toast

try {
    $Functions = Get-ChildItem -Path "$ENV:git\dotfiles\powershell\*.ps1" | Where-Object {$_.Name -ne "Profile.ps1"}
    foreach ($Function in $Functions) {
        Import-Module -Name $Function.FullName -Force
    }
    Set-Location -Path $ENV:git
} catch {
    Write-Error "Functions not imported. '`$ENV:git' value of '$ENV:git' is not valid."
}