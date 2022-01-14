# For smart insert section
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

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
function Calculate-TimeElapsed {
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
        $CumulativeTime += $ElapsedSession
    }

    if ($ReturnDatetimeObject -eq $false) {
        if ($CumulativeTime.Days -eq 0) {
            return "$($CumulativeTime.Hours) hours $($CumulativeTime.Minutes) minutes"
        } else {
            return "$($CumulativeTime.Days) days $($CumulativeTime.Hours) hours $($CumulativeTime.Minutes) minutes"
        }
    } else {
        return $CumulativeTime
    }
}

# Extract time duration from string
function Calculate-TimeDuration {
    param (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            Mandatory = $true
        )]
        [string]
        $RawSession
    )
    $Hours = 0
    $Minutes = 0

    # Should be receiving it all as one string (e.g. 1hr; 35m; 1h47m)
    # Start out supporting only hours and minutes
    if ($RawSession -match "\d{1,}\s?h") {
        [int]$Hours = $Matches.Values.Split(" ")[0]
    }
    if ($RawSession -match "\d{1,}\s?m") {
        [int]$Minutes = $Matches.Values.Split(" ")[0]
    }

    $TimeDuration = New-TimeSpan -Hours $Hours -Minutes $Minutes
    return $TimeDuration
}

# Turn recorded daily note work sessions into sums of time per task/project
function Process-DailyNote {
    param (
        [ValidateScript({Test-Path $_, "Daily note not found at $_"})]
        [String]
        $TodaysDailyNotePath = "$env:git\obsidian-vaults\notey-notes\daily notes\$(Get-Date -Format yyyy-MM-dd) daily note.md"
    )

    # Import today's daily note automagically instead of piping in the data
    if (!(Test-Path -Path "$env:git\obsidian-vaults\notey-notes\")) {
        return "Obsidian vault not found."
    }
    $DailyNoteContent = Get-Content $TodaysDailyNotePath

    # Only include lines with a checkbox
    $DailyNoteContent = $DailyNoteContent | Where-Object {($_ -match "-\s\[\s\]") -or ($_ -match "-\s\[x\]")}
    foreach ($Line in $DailyNoteContent) {
        $WorkSessionExists = $false
        # Get the raw sessions from each line and pass to Calculate-TimeElapsed
        $Sections = $Line.Trim().Split(" ")
        $RawSessions = ""
        foreach ($Section in $Sections) {
            # Does line have at least one session in "hh:mm-hh:mm" format or "h hour m minute" format
            $ClockFormat = $Section -match "\d{1,2}:\d{1,2}\s?-\s?\d{1,2}:\d{1,2}"
            $DurationFormat = $Section -match "\d{1,}\s?h([a-z\s]*\d{1,}\s?m[a-z]*)?"
            # ^ Test data set for regex
            <#
            1h
            1hour
            1 hour
            1 h 35 m
            1h35m
            1hr35min
            1 hr 35 min
            1 hour 35 minutes
            #>
            $WorkSessionExists = $ClockFormat -or $DurationFormat
            #Write-Host "Section: $($Section)`nMatches: $($Matches)"
            if ($WorkSessionExists) {
                $RawSessions = "$RawSessions$Section"
                #Write-Host "$Section -> $RawSessions"
            }
        }
        if (($null -ne $RawSessions) -and ($RawSessions -ne "")) {
            $ElapsedTime = Calculate-TimeElapsed -RawSessions $RawSessions -ReturnDatetimeObject $true
            $Line = $Line.Replace("- [ ] ","")
            $Line = $Line.Replace("- [x] ","")
            Write-Host "$Line --> " -NoNewline
            Write-Host "$($ElapsedTime.Hours) hours $($ElapsedTime.Minutes) minutes" -ForegroundColor Green
        }
    }
}

# Terraform alias
New-Alias -Name "tf" -Value "terraform.exe" -Description "Saves on 'terraform' keystrokes"
# Tail alias
function tail {
    param (
        [ValidateScript({Test-Path $_, "File not found at $_"})]
        [Parameter(
            Mandatory=$true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [String]
        $Path,

        [Parameter(
            Position = 1
        )]
        [Int32]
        $Count = 10
    )
    
    Get-Content -Path $Path -Tail $Count
}


# Smart Insert/Delete
# "The next four key handlers are designed to make entering matched quotes
# parens, and braces a nicer experience.  I'd like to include functions
# in the module that do this, but this implementation still isn't as smart
# as ReSharper, so I'm just providing it as a sample."
# Source: https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1?WT.mc_id=-blog-scottha
Set-PSReadLineKeyHandler -Key '"',"'" `
                         -BriefDescription SmartInsertQuote `
                         -LongDescription "Insert paired quotes if not already on a quote" `
                         -ScriptBlock {
    param($key, $arg)

    $quote = $key.KeyChar

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    # If text is selected, just quote it without any smarts
    if ($selectionStart -ne -1)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
        return
    }

    $ast = $null
    $tokens = $null
    $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$parseErrors, [ref]$null)

    function FindToken
    {
        param($tokens, $cursor)

        foreach ($token in $tokens)
        {
            if ($cursor -lt $token.Extent.StartOffset) { continue }
            if ($cursor -lt $token.Extent.EndOffset) {
                $result = $token
                $token = $token -as [StringExpandableToken]
                if ($token) {
                    $nested = FindToken $token.NestedTokens $cursor
                    if ($nested) { $result = $nested }
                }

                return $result
            }
        }
        return $null
    }

    $token = FindToken $tokens $cursor

    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
        # If we're at the start of the string, assume we're inserting a new string
        if ($token.Extent.StartOffset -eq $cursor) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }

        # If we're at the end of the string, move over the closing quote if present.
        if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
            return
        }
    }

    if ($null -eq $token -or
        $token.Kind -eq [TokenKind]::RParen -or $token.Kind -eq [TokenKind]::RCurly -or $token.Kind -eq [TokenKind]::RBracket) {
        if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
            # Odd number of quotes before the cursor, insert a single quote
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
        }
        else {
            # Insert matching quotes, move cursor to be in between the quotes
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        }
        return
    }

    # If cursor is at the start of a token, enclose it in quotes.
    if ($token.Extent.StartOffset -eq $cursor) {
        if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier -or 
            $token.Kind -eq [TokenKind]::Variable -or $token.TokenFlags.hasFlag([TokenFlags]::Keyword)) {
            $end = $token.Extent.EndOffset
            $len = $end - $cursor
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len, $quote + $line.SubString($cursor, $len) + $quote)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
            return
        }
    }

    # We failed to be smart, so just insert a single quote
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
}

Set-PSReadLineKeyHandler -Key '(','{','[' `
                         -BriefDescription InsertPairedBraces `
                         -LongDescription "Insert matching braces" `
                         -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar)
    {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    
    if ($selectionStart -ne -1)
    {
      # Text is selected, wrap it in brackets
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $key.KeyChar + $line.SubString($selectionStart, $selectionLength) + $closeChar)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    } else {
      # No text is selected, insert a pair
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
}

Set-PSReadLineKeyHandler -Key ')',']','}' `
                         -BriefDescription SmartCloseBraces `
                         -LongDescription "Insert closing brace or skip" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadLineKeyHandler -Key Backspace `
                         -BriefDescription SmartBackspace `
                         -LongDescription "Delete previous character or matching quotes/parens/braces" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0)
    {
        $toMatch = $null
        if ($cursor -lt $line.Length)
        {
            switch ($line[$cursor])
            {
                <#case#> '"' { $toMatch = '"'; break }
                <#case#> "'" { $toMatch = "'"; break }
                <#case#> ')' { $toMatch = '('; break }
                <#case#> ']' { $toMatch = '['; break }
                <#case#> '}' { $toMatch = '{'; break }
            }
        }

        if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}
#endregion Smart Insert/Delete