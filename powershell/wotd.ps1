# Word of the Day
function Get-WordOfTheDay {
    param (
        [Parameter(Position=0)]
        [Alias("DefinitionDetail")]
        [ValidateSet("Long", "Short", "All")]
        $DefinitionLength = "All" # long | short | all
    )
    $WordnikApiKey = "$env:WordnikApiKey"

    $Headers = @{"Accept" = "application/json"}
    $Response = Invoke-WebRequest -Uri "https://api.wordnik.com/v4/words.json/wordOfTheDay?api_key=$WordnikApiKey" -Headers $Headers -Method Get -ErrorAction Stop | ConvertFrom-Json
    $Word = $Response.Word
    $Definitions = $Response.Definitions

    if ($DefinitionLength -eq "Long") {
        $Definitions = $Definitions | Sort-Object Text -Descending | Select-Object -First 1
    } elseif ($DefinitionLength -eq "Short") {
        $Definitions = $Definitions | Sort-Object Text -Descending | Select-Object -Last 1
    } else {
        # $DefinitionLength -eq "All"
        # and do nothing
    }

    # If figlet is installed on WSL, give me a BIG word
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        $TempWord = wsl -- figlet $Word
        if ($?) {
            #$Word = $null
            foreach ($Line in $TempWord) {
                $BigWord += " $($PSStyle.Bold)$($PSStyle.Background.Blue)$Line$($PSStyle.Reset)`n"
            }
        } else {
            Write-Error "figlet not installed on WSL"
        }
    }

    $Word = " $($PSStyle.Bold)$($PSStyle.Background.Blue)$Word$($PSStyle.Reset)"
    Write-Host "$BigWord $Word"
    foreach ($Definition in $Definitions) {
        $PartOfSpeech = "$($PSStyle.Italic)$($Definition.partOfSpeech)$($PSStyle.ItalicOff)"
        $Text = "$($Definition.text)"
        Write-Host "`t($PartOfSpeech)`t$Text"
    }
    $PartOfSpeech = "$($PSStyle.Foreground.Blue)$($Response.note)$($PSStyle.Reset)"
    Write-Host "`t$PartOfSpeech"
}