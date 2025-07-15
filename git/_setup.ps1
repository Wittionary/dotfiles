# setup global defaults
$GithubPrivateEmail = "wittionary@users.noreply.github.com"
$Name = "Witt Allen"

if ($(git config --global user.email) -ne $GithubPrivateEmail) {
    git config --global user.email $GithubPrivateEmail
    Write-Host "git config --global user.email -> $(git config --global user.email)"
}

if ($(git config --global user.name) -ne $Name) {
    git config --global user.name $Name
    Write-Host "git config --global user.name -> $(git config --global user.name)"
}

if ($(git config --global push.autoSetupRemote) -ne "true") {
    git config --global push.autoSetupRemote "true"
    Write-Host "git config --global push.autoSetupRemote -> $(git config --global push.autoSetupRemote)"
}
