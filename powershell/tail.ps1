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