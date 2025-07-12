function Compress-Text {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [int]$MaxWords = 100
    )
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

Export-ModuleMember -Function Compress-Text,Compress-Conversation
