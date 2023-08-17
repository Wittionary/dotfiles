$SettingsOriginal = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $SettingsOriginal) {
    Move-Item -Path $SettingsOriginal -Destination "${SettingsOriginal}.bak" -Verbose
}
New-Item -Path $SettingsOriginal -ItemType SymbolicLink -Value $env:git\dotfiles\windows-terminal\settings.json