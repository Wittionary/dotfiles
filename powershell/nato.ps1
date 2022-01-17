
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