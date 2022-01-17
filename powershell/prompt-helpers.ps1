
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
