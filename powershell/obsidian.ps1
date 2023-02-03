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
        $ReturnDatetimeObject = $false

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
            $CumulativeTime += $ElapsedSession
        } elseif ($Session -match $DurationFormatPattern) {
            $ElapsedSession = Calculate-TimeDuration -RawSession $Session
            $CumulativeTime += $ElapsedSession
        }
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
        [int]$Hours = $Matches.Values.Split("h").Trim()[0]
    }
    if ($RawSession -match "\d{1,}\s?m") {
        [int]$Minutes = $Matches.Values.Split("m").Trim()[0]
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
    $ClockFormatPattern = "\d{1,2}:\d{1,2}\s?-\s?\d{1,2}:\d{1,2}"
    $DurationFormatPattern = "\d{1,}\s?[hoursminue]+(\d{1,}\s?m[inutes]+)?"
    $TaskIncompletePattern = "-\s\[\s\]"
    $TaskCompletePattern = "-\s\[x\]"
    $NotesPattern = "\(.*\)$"
    
    Clear-Host
    
    # Import today's daily note automagically instead of piping in the data
    $DailyNoteContent = Get-Content $DailyNotePath

    # Only include lines with a time entry
    $DailyNoteContent = $DailyNoteContent | Where-Object {($_ -match $ClockFormatPattern) -or ($_ -match $DurationFormatPattern)}

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
        $Task.CumulativeTime = Calculate-TimeElapsed -RawSessions $Task.RawSessions -ReturnDatetimeObject $true

        # Determine which Accelo ticket it might go towards
        $Task.AcceloTicket = Get-AcceloTicketOptions -Description "$($Task.Title) $($Task.Notes)"
        
        
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
    Write-Host "$($Task.CumulativeTime.Hours) hours $($Task.CumulativeTime.Minutes) minutes" -ForegroundColor $ForegroundColor -NoNewline
    Write-Host "    (TICKET: $($Task.AcceloTicket); NOTES: $($Task.Notes))"
}