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



# How Dare You gif
function hdyg {
    $GifURL = "https://media.giphy.com/media/U1aN4HTfJ2SmgB2BBK/giphy.gif"
    $GifURL | Set-Clipboard
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
        # When there's a trailing delimiter, don't throw an error. Just ignore that empty "session"
        if ($null -eq $Session -or $Session -eq "") {
            break
        }
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
        [datetime]
        $Date = $(Get-Date),

        [ValidateScript({Test-Path $_, "Daily note not found at $_"})]
        [String]
        $DailyNotePath = "$env:git\obsidian-vaults\notey-notes\daily notes\$($Date | Get-Date -Format yyyy-MM-dd) daily note.md"
    )

    # Import today's daily note automagically instead of piping in the data
    if (!(Test-Path -Path "$env:git\obsidian-vaults\notey-notes\")) {
        return "Obsidian vault not found."
    }
    $DailyNoteContent = Get-Content $DailyNotePath

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
            $ForegroundColor = "White"

            # If a time has already been registered as entered, add a visual indicator that's the case
            if ($Line -match "-\s\[\s\]") {
                $Line = $Line.Replace("- [ ] ","")
                $ForegroundColor = "Green"
            } elseif ($Line -match "-\s\[x\]") {
                $Line = $Line.Replace("- [x] ","")
                $ForegroundColor = "Yellow"
            }

            Write-Host "$Line --> " -NoNewline
            Write-Host "$($ElapsedTime.Hours) hours $($ElapsedTime.Minutes) minutes" -ForegroundColor $ForegroundColor
        }
    }
}