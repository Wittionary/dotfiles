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
function Process-DailyNoteLEGACY {
    param (
        [datetime]
        $Date = $(Get-Date),

        [ValidateScript({Test-Path $_, "Daily note not found at $_"})]
        [String]
        $DailyNotePath = "$env:git\obsidian-vaults\notey-notes\daily notes\$($Date | Get-Date -Format yyyy-MM-dd) daily note.md"
    )
    $ClockFormatPattern = "\d{1,2}:\d{1,2}\s?-\s?\d{1,2}:\d{1,2}"
    $DurationFormatPattern = "\d{1,}\s?[hoursminute]+(\d{1,}\s?m[inutes]+)?"

    # Import today's daily note automagically instead of piping in the data
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
            $ClockFormat = $Section -match $ClockFormatPattern
            $DurationFormat = $Section -match $DurationFormatPattern
            # ^ Test data set for regex
            <#
            30m
            30minutes
            30 m
            30 minutes
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

    # Need to create one task object per line so it's easier to process via API later
    # Properties:
    # - title/description
    # - time entries (or at least one, big time entry that's been added up)
    # - completed yet (x or no x)

    $Tasks = @()
    foreach ($Line in $DailyNoteContent) {
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
        
        $Tasks += $Task
    }
    
    # Output to user
    Write-Host "`nThere are $($Tasks.Length) tasks for $($Date | Get-Date -Format dddd), $($Date | Get-Date -Format 'MMMM dd')"
    foreach ($Task in $Tasks) {
        if ($Task.Status -eq "complete") {
            $ForegroundColor = "Green"
        } elseif ($Task.Status -eq "incomplete") {
            $ForegroundColor = "Yellow"
        }
        
        Write-Host "$($Task.Title) --> " -NoNewline
        Write-Host "$($Task.CumulativeTime.Hours) hours $($Task.CumulativeTime.Minutes) minutes" -ForegroundColor $ForegroundColor -NoNewline
        Write-Host "    (TICKET: $($Task.AcceloTicket); NOTES: $($Task.Notes))"
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