# Install all modules in the powershell directory
try {
    $Functions = Get-ChildItem -Path "$ENV:git\dotfiles\powershell\*.ps1" | Where-Object {$_.Name -ne "profile.ps1"}
    foreach ($Function in $Functions) {
        Install-Module -Name $Function.FullName -Force
    }
} catch {
    Write-Error "Functions not imported. '`$ENV:git' value of '$ENV:git' is not valid."
}