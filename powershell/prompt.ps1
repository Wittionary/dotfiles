# Prompt coloring
$PromptTextColor = "Black"
$PromptBackgroundColor1 = "Yellow"
$PromptBackgroundColor2 = "Magenta"
$PromptBackgroundColor3 = "Blue"
$Section1 = @{NoNewLine = $true; ForegroundColor = $PromptTextColor; BackgroundColor = $PromptBackgroundColor1}
$Section2 = @{NoNewLine = $true; ForegroundColor = $PromptTextColor; BackgroundColor = $PromptBackgroundColor2}
$Section3 = @{NoNewLine = $true; ForegroundColor = $PromptTextColor; BackgroundColor = $PromptBackgroundColor3}
$Section4 = @{NoNewLine = $true; ForegroundColor = $PromptBackgroundColor3; BackgroundColor = $PromptTextColor}

function prompt {
    
    $realLASTEXITCODE = $LASTEXITCODE # This preserves our true lastexitcode
    $Time = (Get-Date -Format HH:mm).ToString()
    
    # Window Title
    if (Test-Administrator) {
        # Use different username if elevated
        $Host.UI.RawUI.WindowTitle = "✨ $(Get-LastCommandInfo)"
    } else {
        $Host.UI.RawUI.WindowTitle = Get-LastCommandInfo
    }
    

    # Username and hostname OR time and git branch

    if (Test-IsGitRepo) {
        Write-Host " $Time" @Section1

        $GitBranch = Get-GitCheckedOutBranch
        # for long branch names
        if ($GitBranch.Length -gt 26) {
            # TODO: if "/" then...
            # assumes a "/" in branch name
            $Temp1 = $GitBranch.Split("/")[0]
            $Temp2 = $GitBranch.Split("/")[1].Substring(0,5)
            $Temp3 = $GitBranch.Split("/")[1].Substring((($GitBranch.Split("/")[1].Length) - 5),5) # start count from near the end of the string

            $GitBranch = "$Temp1/$Temp2..$Temp3"
            # TODO: else shorten it
        }
        Write-Host " $GitBranch($(Get-GitNumberOfBranches))" @Section2
    } else {
        Write-Host " $ENV:USERNAME" @Section1
        Write-Host " $ENV:COMPUTERNAME" @Section2
    }
    

    # Color for PS sessions
    if ($null -ne $s) {
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ") " -NoNewline -ForegroundColor DarkGray
    }

    # Filepath
    Write-Host " " @Section3
    Write-Host $($(Get-ShortenedDirectory) -replace ($env:USERPROFILE).Replace('\', '\\'), "~") @Section3
    Write-Host "`u{25B6}" @Section4

    $global:LASTEXITCODE = $realLASTEXITCODE

    return " "
}