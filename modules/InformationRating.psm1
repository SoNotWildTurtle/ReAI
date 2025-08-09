function Rate-Information {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Text
    )
    $prompt = "Rate the reliability of the following text on a scale of 1 (unreliable) to 5 (very reliable). Also classify the reliability as High, Medium or Low. Provide one short reason. Respond in the format 'Score:<number>; Category:<High|Medium|Low>; Reason:<text>'."
    $response = Invoke-GPT -Messages @(
        @{role='system'; content=$prompt},
        @{role='user'; content=$Text}
    ) -Max 150
    if (-not $response) { return [PSCustomObject]@{ Score = 0; Category='Unknown'; Reason = 'No response' } }
    $score = 0
    $cat = 'Unknown'
    $reason = ''
    if ($response -match '(?i)Score\s*[:=]\s*(\d)') { $score = [int]$matches[1] }
    if ($response -match '(?i)Category\s*[:=]\s*(\w+)') { $cat = $matches[1].Trim() }
    if ($response -match '(?i)Reason\s*[:=]\s*(.+)') { $reason = $matches[1].Trim() }
    [PSCustomObject]@{ Score = $score; Category = $cat; Reason = $reason }
}

Export-ModuleMember -Function Rate-Information
