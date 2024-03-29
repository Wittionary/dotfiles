
# Returns if current user is running the shell with elevated permissions
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}


# Returns a shortened version of the current working directory
function Get-ShortenedDirectory {
    param(
        $Directory = (Get-Location).Path,
        $TrailingFolderCount = 2
    )

    $SplitDirectory = ($Directory).Split("\")

    # If the path is long, shorten it
    if ($SplitDirectory.Count -gt ($TrailingFolderCount + 1)) {
        for ($i = ($SplitDirectory.count - $TrailingFolderCount); $i -lt ($SplitDirectory.count); $i++) {
            $TrailingFolders += "\$($SplitDirectory[$i])"
        }
        
        if ($SplitDirectory[0] -eq "C:"){
            $ShortenedDirectory = ".." + $TrailingFolders
        } else {
            $ShortenedDirectory = $SplitDirectory[0] + "\..." + $TrailingFolders
        }
        
        return $ShortenedDirectory
    } else {
        # It's short enough already
        return $Directory
    }
}

# Return info about the last command ran for the prompt
function Get-LastCommandInfo {
    $Command = (Get-History -Count 1).CommandLine

    if ($Command.Length -gt 20) {
        $Command = $Command.Substring(0, 20)
        $Command = "$Command..."
    }

    return $Command
}

# See if environment variables are set
function Test-EnvVariables {
    $Variables = @('$env:ESPANSO_CONFIG_DIR', '$env:git')

    foreach ($Variable in $Variables) {
        if ($null -eq $Variable) {
            Write-Error "The variable $Variable is `$null."
        }
    }
}