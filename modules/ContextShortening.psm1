function Identify-Context {
    param([string]$Text)
    if (-not (Test-SecureNetworkAccess) -or [string]::IsNullOrWhiteSpace($OpenAIKey)) {
        return (Local-ExtractKeywords -Text $Text).Split(',')
    }
    if (-not (Test-SecureNetworkAccess)) { return @() }
    $keywords = Invoke-GPT -Messages @(
        @{role='system'; content='Extract the main keywords from the text as a comma separated list'}
        @{role='user'; content=$Text}
    ) -Max 150
    return $keywords -split '\s*,\s*'
}

function Get-ContextSummary {
    param(
        [string]$Query,
        [switch]$Tor
    )
    if (-not (Test-SecureNetworkAccess)) { return '' }
    $results = Search-Web -Query $Query -Engine google -Tor:$Tor
    $snippets = @()
    foreach ($r in $results) {
        $summary = Get-UrlSummary $r.url
        if ($summary) { $snippets += $summary }
    }
    $joined = $snippets -join "`n"
    if (-not $joined) { return '' }
    if ([string]::IsNullOrWhiteSpace($OpenAIKey)) {
        return Local-SummarizeText -Text $joined -MaxSentences 5
    }
    $context = Invoke-GPT -Messages @(
        @{role='system'; content='Provide a concise overview of the following search snippets:'}
        @{role='user'; content=$joined}
    ) -Max 400
    return $context
}

function Condense-Context {
    param([string]$Text)
    if (-not (Test-SecureNetworkAccess) -or [string]::IsNullOrWhiteSpace($OpenAIKey)) {
        return Local-SummarizeText -Text $Text -MaxSentences 5
    }
    if (-not (Test-SecureNetworkAccess)) { return '' }
    $summary = Invoke-GPT -Messages @(
        @{role='system'; content='Summarize the text in under 200 words:'}
        @{role='user'; content=$Text}
    ) -Max 300
    return $summary
}

function Get-CondensedContext {
    param([string]$Text,[switch]$Tor)
    $keywords = (Identify-Context -Text $Text) -join ' '
    $context = Get-ContextSummary -Query $keywords -Tor:$Tor
    if (-not $context) { $context = Condense-Context -Text $Text }
    else { $context = Condense-Context -Text ($context + "`n" + $Text) }
    return $context
}

Export-ModuleMember -Function Identify-Context,Get-ContextSummary,Condense-Context,Get-CondensedContext
