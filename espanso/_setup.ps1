$SettingsOriginal = "$env:USERPROFILE\AppData\Roaming\espanso"

if (Test-Path $SettingsOriginal) {
    Move-Item -Path $SettingsOriginal -Destination "${SettingsOriginal}.bak" -Verbose
}
New-Item -Path $SettingsOriginal -ItemType SymbolicLink -Value $env:git\dotfiles\espanso

# restart espanso?