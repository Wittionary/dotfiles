# Returns if current user is running the shell with elevated permissions
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Return the git branch that's currently checked out, if any
function Get-GitCheckedOutBranch {
    $CheckedOutBranch = $null
    $Branches = git branch --list
    $CheckedOutBranch = $Branches | Where-Object { $_ -match "\*" }
    # Get rid of asterisk
    $CheckedOutBranch = $CheckedOutBranch.Remove(0, 2)

    return $CheckedOutBranch
}

# Return the number of local branches
function Get-GitNumberOfBranches {
    $Branches = git branch --list
    $NumberOfBranches = $Branches.Count

    return $NumberOfBranches
}

# Returns if the current working directory is a git repo or subdir of a repo
function Test-IsGitRepo {
    # If in a child folder of $ENV:git, it *should* be a git repo
    if ($pwd.path -match "$($env:git.Replace("\","\\"))\\") {
        return $true
    }
    return $false
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

# Sync your current Domain Controller and then sync to Azure
function Sync-ToAzure {
    param(
        # This may not always be the DC you're connect to in ADUC via MMC
        $DomainController = (Get-ADDomainController).Hostname,

        [Parameter(Mandatory=$true)]
        $AzureSyncServer,

        $PatienceInterval = 5
    )

    Write-Host "Syncing to $DomainController"
    Invoke-Command $DomainController -ScriptBlock {repadmin /syncall}
    Write-Host "Waiting for $PatienceInterval seconds"
    Start-Sleep -s $PatienceInterval
    # May need to Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass
    Invoke-Command $AzureSyncServer -FilePath "\\$AzureSyncServer\D$\scripts\sync-adconnect.ps1"
}

# Start a PSsession with the on-prem Exchange server
function Connect-OnPremExchange {
    param(
        $ExchangeServerFQDN,

        $PrivilegedCreds = (Get-Credential)
    )
    #$PrivilegedCreds = ConvertTo-SecureString $PrivilegedCreds
    $OnPremExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$ExchangeServerFQDN/PowerShell/" -Authentication Kerberos -Credential $PrivilegedCreds
    Import-PSSession $OnPremExchangeSession -DisableNameChecking
}

# End a PSsession with the on-prem Exchange server
function Disconnect-OnPremExchange {
    Remove-PSSession $OnPremExchangeSession
}

# Git aliases
function g {
    param (
        [Parameter(Position=0)]
        $CommandSequence = "s",

        [Parameter(Position=1)]
        $String = ""
    )
    
    if ($CommandSequence -eq "s") {
        & git status -sb
    } elseif ($CommandSequence -eq "b") {
        & git branch --list
    } elseif ($CommandSequence -eq "p") {
        & git pull
    } elseif ($CommandSequence -eq "can") {
        # Commit all now; maybe add auto-push later
        & git add .
        $CommitMessage = "Commit All @ $(Get-Date -Format "MM-dd-yyyy HH:mm:ss")"
        & git commit -am $CommitMessage
    } elseif ($CommandSequence -eq "ca") {
        # Commit all with message
        & git add .
        $CommitMessage = $String
        & git commit -am $CommitMessage
    } elseif ($CommandSequence -eq "pp") {
        # Push
        & git push --progress
    }
}

# How Dare You gif
function hdyg {
    $GifURL = "https://media.giphy.com/media/U1aN4HTfJ2SmgB2BBK/giphy.gif"
    $GifURL | Set-Clipboard
}

# Fix Windows Terminal elevation prompt bug
# Source: https://github.com/microsoft/terminal/issues/4217#issuecomment-712545620
function Fix-WindowsTerminal { # Using an unapproved verb; come at me, bro.
    Add-AppxPackage -Register 'C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.3.2651.0_x64__8wekyb3d8bbwe\AppxManifest.xml' -DisableDevelopmentMode
}

# NATO alphabet
function nato {
    param (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true
        )]
        $Word = ""
    )
    $PhoneticAlphabet = @{a="alpha"; b="bravo"; c="charlie"; d="delta"; e="echo"; f="foxtrot";
                g="golf"; h="hotel"; i="india"; j="juliett"; k="kilo"; l="lima";
                m="mike"; n="november"; o="oscar"; p="papa"; q="quebec"; r="romeo";
                s="sierra"; t="tango"; u="uniform"; v="victor"; w="whiskey"; x="x-ray";
                y="yankee"; z="zulu"; '0'="zero"; '1'="wun"; '2'="too"; '3'="tree"; '4'="fow-er"; '5'="fife";
                '6'="six"; '7'="sev-en"; '8'="ait"; '9'="nin-er"; '.'="decimal"; '-'="dash"}

    if ($Word -ne "") {
        $Letters = $Word.ToCharArray()
        foreach ($Letter in $Letters) {
            Write-Host $PhoneticAlphabet[$($Letter.ToString())]
        }
    } else {
        $PhoneticAlphabet = $PhoneticAlphabet.GetEnumerator() | Sort-Object Name
        $PhoneticAlphabet
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

# Assumes 24-hour time format
function Calculate-ElapsedTime {
    param (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            Mandatory = $true
        )]
        [string]
        $RawSessions,

        [Boolean]
        $ReturnDatetimeObject = $false

    )
    $CumulativeTime = $null

    # Split into multiple sessions depending on the delimiter
    if (($RawSessions -match ",") -and ($RawSessions -match ";")) {
        Write-Error "Delimiter unclear. Pick either comma or semi-colon."
    } elseif ($RawSessions -match ",") {
        $Sessions = ($RawSessions -split ",").Trim()
    } elseif ($RawSessions -match ";") {
        $Sessions = ($RawSessions -split ";").Trim()
    } else {
        # No delimiter found
        $Sessions = $RawSessions.Trim()
    }
    
    # Parse and add up each individual session
    foreach ($Session in $Sessions) {
        $Session = $Session.Trim()
        $RawStartTime = $Session.Split("-")[0].Trim()
        $RawEndTime = $Session.Split("-")[1].Trim()

        $StartTime = Get-Date -Hour ($RawStartTime.Split(":")[0]) -Minute ($RawStartTime.Split(":")[1])
        $EndTime = Get-Date -Hour ($RawEndTime.Split(":")[0]) -Minute ($RawEndTime.Split(":")[1])

        $ElapsedSession = $EndTime - $StartTime
        #Write-Host "Elapsed session: $ElapsedSession"
        $CumulativeTime += $ElapsedSession
    }

    if ($ReturnDatetimeObject -eq $false) {
        return "$($CumulativeTime.Days) days`n$($CumulativeTime.Hours) hours`n$($CumulativeTime.Minutes) minutes"
    } else {
        return $CumulativeTime
    }
}

# Terraform alias
New-Alias -Name "tf" -Value "terraform.exe" -Description "Saves on 'terraform' keystrokes"