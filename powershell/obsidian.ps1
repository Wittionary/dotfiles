<#
DESCRIPTION:
Holds Obsidian-specific helpers (e.g. Process-DailyNote)
and dependent functions (e.g. Calculate-TimeElapsed)
#>


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
        $ReturnDatetimeObject = $false,

        [Boolean]
        $Rounded = $true # by default, round up or down based off of the programmed rules
    )
    $CumulativeTime = $null
    $ClockFormatPattern = "\d{1,2}:\d{1,2}\s?-\s?\d{1,2}:\d{1,2}"
    $DurationFormatPattern = "\d{1,}\s?[hoursminute]+(\d{1,}\s?m[inutes]+)?"

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
        if ($Session -match $ClockFormatPattern) {
            # When there's a trailing delimiter, don't throw an error. Just ignore that empty "session"
            if ($null -eq $Session -or $Session -eq "") {
                break
            }
            $RawStartTime = $Session.Split("-")[0].Trim()
            $RawEndTime = $Session.Split("-")[1].Trim()

            $StartTime = Get-Date -Hour ($RawStartTime.Split(":")[0]) -Minute ($RawStartTime.Split(":")[1])
            $EndTime = Get-Date -Hour ($RawEndTime.Split(":")[0]) -Minute ($RawEndTime.Split(":")[1])

            $ElapsedSession = $EndTime - $StartTime
            # Round the elapsed session UP or DOWN based off of how JH does it
            # <=18m             == 15 mins
            # >18m, <=33m       == 30 mins
            # >33m, <=48m       == 45 mins
            # >48m              == 60 mins
            $RoundedMinutes = 0
            if ($ElapsedSession.Minutes -le 3) {
                # round to 0
                $RoundedMinutes = 0
            } elseif (($ElapsedSession.Minutes -gt 3) -and ($ElapsedSession.Minutes -le 18)) {
                # round to 15
                $RoundedMinutes = 15
            } elseif (($ElapsedSession.Minutes -gt 18) -and ($ElapsedSession.Minutes -le 33)) {
                # round to 30
                $RoundedMinutes = 30
            } elseif (($ElapsedSession.Minutes -gt 33) -and ($ElapsedSession.Minutes -le 48)) {
                # round to 45
                $RoundedMinutes = 45
            } elseif ($ElapsedSession.Minutes -gt 48) {
                # round to 60
                $RoundedMinutes = 60
            } else {
                Write-Error "Something is catastrophically wrong.`n`t`$ElapsedSession.Minutes: $($ElapsedSession.Minutes)"
            }
            $RoundedSession = New-TimeSpan -Days $ElapsedSession.Days -Hours $ElapsedSession.Hours -Minutes $RoundedMinutes

            $CumulativeTime += $ElapsedSession
            $CumulativeRoundedTime += $RoundedSession
        } elseif ($Session -match $DurationFormatPattern) {
            #Write-Host "SESSION $Session matches DURATIONFORMAT"
            $ElapsedSession = Calculate-TimeDuration -RawSession $Session -Rounded $false
            $CumulativeTime += $ElapsedSession

            $RoundedSession = Calculate-TimeDuration -RawSession $Session
            $CumulativeRoundedTime += $RoundedSession
        }
    }

    if ($ReturnDatetimeObject -eq $false) {
        if ($CumulativeTime.Days -eq 0) {
            return "$($CumulativeRoundedTime.Hours) hours $($CumulativeRoundedTime.Minutes) minutes"
        } else {
            return "$($CumulativeRoundedTime.Days) days $($CumulativeRoundedTime.Hours) hours $($CumulativeRoundedTime.Minutes) minutes"
        }
    } else {
        if ($Rounded) {
            return $CumulativeRoundedTime
        } else {
            return $CumulativeTime
        }
        
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
        $RawSession,

        [Boolean]
        $Rounded = $true
    )
    $Hours = 0
    $Minutes = 0

    # Should be receiving it all as one string (e.g. 1hr; 35m; 1h47m)
    # Start out supporting only hours and minutes
    if ($RawSession -match "\d{1,}\s?h") {
        [int]$Hours = $Matches.Values.Split("h").Trim()[0]
    }
    if ($RawSession -match "\d{1,}\s?m") {
        [int]$Minutes = $Matches.Values.Split("m").Trim()[0]
    }

    if ($Rounded) {
        # Round the duration session UP or DOWN based off of how JH does it
        # <=18m             == 15 mins
        # >18m, <=33m       == 30 mins
        # >33m, <=48m       == 45 mins
        # >48m              == 60 mins
        $RoundedMinutes = 0
        if ($Minutes -le 3) {
            # round to 0
            $RoundedMinutes = 0
        } elseif (($Minutes -gt 3) -and ($Minutes -le 18)) {
            # round to 15
            $RoundedMinutes = 15
        } elseif (($Minutes -gt 18) -and ($Minutes -le 33)) {
            # round to 30
            $RoundedMinutes = 30
        } elseif (($Minutes -gt 33) -and ($Minutes -le 48)) {
            # round to 45
            $RoundedMinutes = 45
        } elseif ($Minutes -gt 48) {
            # round to 60
            $RoundedMinutes = 60
        } else {
            Write-Error "Something is catastrophically wrong.`n`t`$Minutes: $($Minutes)"
        }

        $Minutes = $RoundedMinutes
    }
    
    $TimeDuration = New-TimeSpan -Hours $Hours -Minutes $Minutes
    #Write-Host "TIME DURATION: $TimeDuration"
    return $TimeDuration
}

# Turn recorded daily note work sessions into sums of time per task/project
function Process-DailyNote {
    param (
        [datetime]
        $Date = $(Get-Date),

        [ValidateScript({Test-Path $_, "Daily note not found at $_"})]
        [String]
        $DailyNotePath = "$env:git\obsidian-vaults\notey-notes\daily notes\$($Date | Get-Date -Format yyyy-MM-dd) daily note.md",

        [bool]
        $Debug = $false
    ) 
    $ClockFormatPattern = "\d{1,2}:\d{1,2}\s?-\s?\d{1,2}:\d{1,2}"
    $DurationFormatPattern = "\d{1,}\s?[hoursminue]+(\d{1,}\s?m[inutes]+)?"
    $TaskIncompletePattern = "-\s\[\s\]"
    $TaskCompletePattern = "-\s\[x\]"
    $NotesPattern = "\(.*\)$"
    
    Clear-Host
    
    # See if note path exists
    if (!(Test-Path $DailyNotePath)) {
        Write-Host "Daily note not found at path:`n`n$DailyNotePath`n`nWas a note made on this day?"
        break
    }
    # Import today's daily note automagically instead of piping in the data
    $DailyNoteContent = Get-Content $DailyNotePath
    if ($Debug) { Write-Host "DailyNoteContent raw:`n$DailyNoteContent"}

    # Only include lines that are a task
    $DailyNoteContent = $DailyNoteContent | Where-Object {($_ -match $TaskIncompletePattern) -or ($_ -match $TaskCompletePattern)}
    # Only include lines that have a time entry
    $DailyNoteContent = $DailyNoteContent | Where-Object {($_ -match $ClockFormatPattern) -or ($_ -match $DurationFormatPattern)}
    if ($Debug) { Write-Host "DailyNoteContent matched:`n$DailyNoteContent"}

    $Tasks = @()
    foreach ($Line in $DailyNoteContent) {
        $Task = Parse-DailyNoteLine -Line $Line
        $Tasks += $Task
    }
    
    # Output to user
    Write-Host "`nThere are " -NoNewLine
    Write-Host "$($Tasks.Length)" -ForegroundColor Cyan -NoNewline
    Write-Host " tasks for $($Date | Get-Date -Format dddd), $($Date | Get-Date -Format 'MMMM dd')"
    foreach ($Task in $Tasks) {
        if ($Debug) { Write-Host "Task: $($Task.Title)"}
        Display-DailyNoteTask -Task $Task
    }
    
}

function Get-AcceloTicketOptions{
    param (
        [Parameter(
            Mandatory=$true,
            Position=0
        )]
        [string]
        $Description
    )

    switch -Regex ($Description) {
        "training" { return "training"; break} # Internal - Professional Dev/Training
        "learning" { return "training"; break}
        "webinar" { return "training"; break}
        "meeting" { return "internal meeting"; break} # Internal Meetings
        "do not bill" { return "internal projects"; break} # Internal Projects
        "dnb" { return "internal projects"; break}
        "DNB" { return "internal projects"; break}
        # Internal - PreSales
        Default {return "unknown"}
    }
}

function Parse-DailyNoteLine{
    param (
        [Parameter(
            Mandatory=$true,
            Position=0
        )]
        [string]
        $Line
    )

    $Task = @{}
        # Get task status
        if ($Line -match $TaskIncompletePattern) {
            $Task.Status = "incomplete"
        } elseif ($Line -match $TaskCompletePattern) {
            $Task.Status = "complete"
        }
        #Write-Host "STATUS: $($Task.Status)"

        # Remove that part from line
        # zzz abcdefg 1234 -> abcdefg 1234
        $Line = $Line.Substring(($Matches.0).Length + 1, $Line.Length - ($Matches.0).Length - 1).Trim()

        # Get end-of-line notes/tags
        if ($Line -match $NotesPattern) {
            $Line = $Line.Substring(0, $Line.length - ($Matches.0).Length)
            $Notes = $Matches.0
            # Remove parentheses
            $Notes = $Notes.Substring(1, ($Notes.Length) - 2)
            $Task.Notes = $Notes
            
        }

        # Get the time entries section
        if ($Line -match $ClockFormatPattern -or $Line -match $DurationFormatPattern) {
            #Write-Host "LINE: $Line"
            $Sessions = $Line.Substring($Line.IndexOf($Matches.0), ($Line.Length - $Line.IndexOf($Matches.0))).Trim()
            #Write-Host "SESSIONS: $Sessions"
            $Task.RawSessions = $Sessions
            
            # Get the title/description section
            $Task.Title = $Line.Substring(0, $Line.IndexOf($Matches.0)).Trim()
            #Write-Host "TITLE: $($Task.Title)"
        }

        # Add up the time of the sessions
        $Task.CumulativeTime = Calculate-TimeElapsed -RawSessions $Task.RawSessions -ReturnDatetimeObject $true -Rounded $false
        #Write-Host "CUMULATIVE TIME: $($Task.CumulativeTime)"
        $Task.CumulativeRoundedTime = Calculate-TimeElapsed -RawSessions $Task.RawSessions -ReturnDatetimeObject $true
        #Write-Host "CUMULATIVE ROUNDED TIME: $($Task.CumulativeRoundedTime)"

        # Determine whether net gain
        $Task.RoundedMinutesOffset = Calculate-RoundedMinutesNet -RawSessions $Task.RawSessions

        # Determine which Accelo ticket it might go towards
        $Task.AcceloTicket = Get-AcceloTicketOptions -Description "$($Task.Title) $($Task.Notes)"
        
        # Get "Client" property from linked notes
        if ($Task.Title -match "\[\[") {
            $Task.Client = Get-NotePropertyValue -NotePath $(Get-NoteLocation -NoteName $($Task.Title))
        } else {
            # it's an un-linked note and probably internal
            #$Task.Client = "internal"
            $Task.Client = "unknown"
        }
        
        
        return $Task
}

function Display-DailyNoteTask{
    param (
        [Parameter(
            Mandatory=$true,
            Position=0
        )]
        $Task
    )

    if ($Task.Status -eq "complete") {
        $ForegroundColor = "Green"
    } elseif ($Task.Status -eq "incomplete") {
        $ForegroundColor = "Yellow"
    }
    
    Write-Host "$($Task.Title) --> " -NoNewline
    #Write-Host "$($Task.CumulativeTime.Hours) hours $($Task.CumulativeTime.Minutes) minutes " -ForegroundColor Blue -NoNewline
    Write-Host "$($Task.CumulativeRoundedTime.Hours) hours $($Task.CumulativeRoundedTime.Minutes) minutes " -ForegroundColor $ForegroundColor -NoNewline
    if ($Task.RoundedMinutesOffset -ge 0) {
        Write-Host "$($PSStyle.Italic)+$($Task.RoundedMinutesOffset)$($PSStyle.ItalicOff) " -ForegroundColor Blue -NoNewline
    } else {
        # it's negative
        Write-Host "$($PSStyle.Italic)$($Task.RoundedMinutesOffset)$($PSStyle.ItalicOff) " -ForegroundColor Red -NoNewline
    }

    # Ticket/task details
    Write-Host "        (CLIENT: " -NoNewline
    if (("unknown" -eq $Task.Client) -or ("" -eq $Task.Client)) {
        # client is not confirmed
        Write-Host "$($Task.Client)" -ForegroundColor Yellow -NoNewline
    } else {
        Write-Host "$($Task.Client)" -NoNewline # Why is this color always being inherited?
    }
    Write-Host ";)"
    
}

function Calculate-RoundedMinutesNet {
    param (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            Mandatory = $true
        )]
        [string]
        $RawSessions
    )

    $CumulativeTime = Calculate-TimeElapsed -RawSessions $RawSessions -ReturnDatetimeObject $true -Rounded $false
    $CumulativeRoundedTime = Calculate-TimeElapsed -RawSessions $RawSessions -ReturnDatetimeObject $true -Rounded $true
    $NetGainOrLoss = $CumulativeRoundedTime - $CumulativeTime
    $NetGainOrLoss = $NetGainOrLoss.Minutes + 1 # off by one

    return $NetGainOrLoss
}

# returns the value of a specified key within a specified note
function Get-NotePropertyValue {
    param (
        [ValidateScript({Test-Path $_, "Note not found at $_"})]
        [String]
        $NotePath = "",

        [regex]
        $Property = "\*\*Client\*\* ::",
        
        [bool]
        $Debug = $false
    )
    
    if ($NotePath -eq "") {
        return "no client found"
    }

    $Content = Get-Content $NotePath
    $Result = $Content -match $Property

    if (($null -eq $Result) -or ("" -eq $Result)) {
        #throw "No value for the property `'$Property`'"
        return ""
    }

    $Value = $Result.split("::")[1].trim()
    if ($Debug) {Write-Host "VALUE OF PROPERTY `'$Property`': $Value"}
    return $Value
}

# return filepath of a note given it's in the format "[[note]]"
function Get-NoteLocation {
    param (
        [ValidateScript({Test-Path $_, "Note not found at $_"})]
        [String]
        $VaultLocation = "$env:git\obsidian-vaults\notey-notes\",

        [String] # make required
        $NoteName,
        
        [bool]
        $Debug = $false
    )
    $NoteName = $NoteName.Replace("[[","").Replace("]]","")
    $NotePath = Get-Item -Path "$VaultLocation\*\${NoteName}.md"

    if ($null -eq $NotePath) {
        $NotePath = Get-Item -Path "$VaultLocation\${NoteName}.md"
    } elseif ($null -eq $NotePath) {
        $NotePath = Get-Item -Path "$VaultLocation\*\*\${NoteName}.md"
    }
    if ($Debug) {Write-Host "NOTEPATH: $NotePath"}

    return $NotePath.FullName
}

function Get-AcceloToken {
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Basic $($(Get-Content -Path "./powershell/accelo.config").split("basictoken:")[1].trim())")

    $response = Invoke-RestMethod 'https://provisionsgroup.api.accelo.com/oauth2/v0/token?grant_type=client_credentials&scope=read(all)' -Method 'POST' -Headers $headers
    
    return $response #| ConvertTo-Json
}