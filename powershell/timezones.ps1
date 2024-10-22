function tz {
    param (
        [Parameter(Mandatory=$true, ParameterSetName="DateTimeSet", ValueFromPipeline=$true)]
        [datetime]$Datetime,

        [Parameter(Mandatory=$true, ParameterSetName="StringSet", ValueFromPipeline=$true)]
        [string]$Time
    )

    $DatetimeTemp = $null
    if ($PSCmdlet.ParameterSetName -eq "StringSet") {
        $formats = @("hhtt", "htt", "hh:mmt", "HH:mm", "HHmm")
        
        foreach ($format in $formats) {
            try {
                $DatetimeTemp = [datetime]::ParseExact($Time, $format, $null)
                Write-Host "$DatetimeTemp"
                break
            } catch {
                continue
            }
        }
        if (-not $DatetimeTemp) {
            throw "Invalid time format. Supported formats are: 2pm, 2:30pm, 14:30, 1430"
        }
    }
    $Datetime = $DatetimeTemp

    $Timezones = @(
        @{ name = "Pacific Standard Time"; displayname = "PST"; enabled = $true } # -8
        @{ name = "Mountain Standard Time"; displayname = "MST"; enabled = $true } # -7
        @{ name = "Central Standard Time"; displayname = "CST"; enabled = $true } # -6
        @{ name = "Eastern Standard Time"; displayname = "EST"; enabled = $true } # -5
        @{ name = "Atlantic Standard Time"; displayname = "AST"; enabled = $false } # -4
        @{ name = "UTC"; displayname = "UTC"; enabled = $false } # +0
        @{ name = "GMT Standard Time"; displayname = "GMT"; enabled = $false } # +0
        @{ name = "W. Europe Standard Time"; displayname = "WEST"; enabled = $false } # +1 - London
        @{ name = "Central European Standard Time"; displayname = "CEST"; enabled = $false } # +1
        @{ name = "E. Europe Standard Time"; displayname = "EEST"; enabled = $false } # +2
    )

    $Results = @()
    foreach ($Timezone in $Timezones) {
        if ($Timezone.enabled -eq $true) {
            
            $ConvertedTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($Datetime, [System.TimeZoneInfo]::Local.Id, $Timezone.name)
            $Results += [pscustomobject]@{
                TimeZone = $Timezone.name
                Time     = $ConvertedTime
            }
        }
    }

    return $Results
}