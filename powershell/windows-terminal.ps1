# Fix Windows Terminal elevation prompt bug
# Source: https://github.com/microsoft/terminal/issues/4217#issuecomment-712545620
function Fix-WindowsTerminal { # Using an unapproved verb; come at me, bro.
    Add-AppxPackage -Register 'C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.3.2651.0_x64__8wekyb3d8bbwe\AppxManifest.xml' -DisableDevelopmentMode
}

# Return a hex color code deterministically based off a string
function Get-Color {
    param (
        [Parameter(
            Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true
        )]
        [string]
        $String = "witt"
    )
    $StringToColorize = $String.ToLower().Trim() -replace "[^a-zA-Z\d]", "-"
    $StringHash = Abs($StringToColorize.GetHashCode())
    $StringHash = ($StringHash * 1).ToString()

    $Colors = @()
    $Colors += $StringHash.Substring(0,3) # Red
    $Colors += $StringHash.Substring(3,3) # Green
    $Colors += $StringHash.Substring(6,3) # Blue
    $Randomizers = $StringHash.Substring(9,($StringHash.Length - 10))

    foreach ($Color in $Colors) {
        # Must be <= 255
        # Must be > 70
    }

    Write-Host $Colors
    
}