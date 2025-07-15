# Simple local text processing helpers

function Local-SummarizeText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [int]$MaxSentences = 3
    )
    $sentences = $Text -split '(?<=[.!?])\s+'
    if ($sentences.Count -eq 0) { return $Text }
    $take = [Math]::Min($MaxSentences, $sentences.Count)
    ($sentences[0..($take-1)] -join ' ').Trim()
}

function Local-ExtractKeywords {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [int]$Count = 5
    )
    $words = $Text.ToLower() -split '\W+'
    $freq = @{}
    foreach ($w in $words) {
        if ($w.Length -lt 4) { continue }
        if ($freq.ContainsKey($w)) { $freq[$w]++ } else { $freq[$w] = 1 }
    }
    $top = $freq.GetEnumerator() | Sort-Object -Property Value -Descending | Select-Object -First $Count
    ($top | ForEach-Object { $_.Key }) -join ', '
}

Export-ModuleMember -Function Local-SummarizeText,Local-ExtractKeywords
