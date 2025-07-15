function Compress-Text {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [int]$MaxWords = 100
    )
    if (-not (Test-SecureNetworkAccess) -or [string]::IsNullOrWhiteSpace($OpenAIKey)) {
        return Local-SummarizeText -Text $Text -MaxSentences 3
    }
    if (-not (Test-SecureNetworkAccess)) { return '' }
    $prompt = "Summarize the text in under $MaxWords words"
    $result = Invoke-GPT -Messages @(
        @{role='system'; content=$prompt}
        @{role='user'; content=$Text}
    ) -Max ($MaxWords * 4)
    return $result
}

function Compress-Conversation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string[]]$Messages,
        [int]$MaxWords = 200
    )
    $joined = $Messages -join "`n"
    return Compress-Text -Text $joined -MaxWords $MaxWords
}

function Save-CompressedText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Path,
        [int]$MaxWords = 150
    )
    $summary = Compress-Text -Text $Text -MaxWords $MaxWords
    Set-Content -Path $Path -Value $summary
    return $summary
}

Export-ModuleMember -Function Compress-Text,Compress-Conversation,Save-CompressedText
Export-ModuleMember -Function Compress-Text,Compress-Conversation