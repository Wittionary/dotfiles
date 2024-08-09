# is $env:git set?
if (Test-Path $env:git) {
    Write-Output "`$env:git is `'$env:git`'"
} else {
    throw "`'$env:git`' is not a valid path"
    exit 1
}

# is "dotfiles" repo in it?
if (Test-Path "$env:git\dotfiles") {
    Write-Output "'dotfiles' repo is present"
} else {
    throw "'dotfiles' repo is not present"
    exit 1
}

# is this setup-windows.ps1 script presently being run from that location?
Write-Output $PSCommandPath
if ($PSCommandPath -like "$env:git\dotfiles\*") {
    Write-Output "Script is running from the repo"
} else {
    throw "Script is not running from the repo"
    exit 1
}

# enumerate all _setup.ps1 scripts
# run them

# give a pretty output of what ran successfully and what didn't