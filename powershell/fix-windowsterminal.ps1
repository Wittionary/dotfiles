# Fix Windows Terminal elevation prompt bug
# Source: https://github.com/microsoft/terminal/issues/4217#issuecomment-712545620
function Fix-WindowsTerminal { # Using an unapproved verb; come at me, bro.
    Add-AppxPackage -Register 'C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.3.2651.0_x64__8wekyb3d8bbwe\AppxManifest.xml' -DisableDevelopmentMode
}