function Start-ScheduledShutdown {
    param (
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true
        )]
        [datetime]$Time
    )

    Start-Sleep -s $($($Time - $(Get-Date)).TotalSeconds - 60)
    Write-Output "Shutting down soon."
    Start-Sleep -s 60
    Write-Output "Shutting down now..."
    Stop-Computer -Force
}