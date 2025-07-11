function Invoke-GPT {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$Messages,
        [int]$Max = 1500,
        [int]$MaxRetries = 3,
        [int]$RetryDelay = 5
    )
    if (-not (Test-SecureNetworkAccess)) { return $null }
    if ([string]::IsNullOrWhiteSpace($OpenAIKey)) {
        Write-Warning "OpenAI API key is not set. Please set the `$OpenAIKey variable."
        return $null
    }
    $body = @{ model = $Model; messages = $Messages; max_tokens = $Max; temperature = 0.7 }
    $headers = @{ Authorization = "Bearer $OpenAIKey"; "Content-Type" = "application/json" }
    $attempt = 0
    $lastError = $null
    while ($attempt -lt $MaxRetries) {
        try {
            $attempt++
            $apiUrl = if ($global:OpenAIEndpoint) { "$($global:OpenAIEndpoint)/v1/chat/completions" } else { "https://api.openai.com/v1/chat/completions" }
            $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body ($body | ConvertTo-Json -Depth 10) -ErrorAction Stop
            return $response.choices[0].message.content
        } catch {
            $lastError = $_.Exception
            if ($_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
                $errorDetails = $null
                try {
                    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                    $reader.BaseStream.Position = 0
                    $reader.DiscardBufferedData()
                    $errorResponse = $reader.ReadToEnd() | ConvertFrom-Json -ErrorAction SilentlyContinue
                    if ($errorResponse) {
                        $errorDetails = $errorResponse.error.message
                        Write-Warning "API Error ($statusCode): $errorDetails"
                        if ($errorResponse.error.code -eq 'insufficient_quota') {
                            Write-Error "OpenAI API quota exceeded. Please check your billing details."
                            return $null
                        }
                    }
                } catch {
                    Write-Warning "API Error ($statusCode): $($_.Exception.Message)"
                }
                if ($statusCode -eq 429 -or $statusCode -ge 500) {
                    $retryAfter = $_.Exception.Response.Headers['Retry-After']
                    $waitTime = if ($retryAfter) { [int]$retryAfter } else { $RetryDelay * $attempt }
                    Write-Warning "Rate limited. Waiting $waitTime seconds before retry (attempt $attempt/$MaxRetries)..."
                    Start-Sleep -Seconds $waitTime
                    continue
                }
            }
            Write-Warning "API call failed (attempt $attempt/$MaxRetries): $($_.Exception.Message)"
            if ($attempt -lt $MaxRetries) { Start-Sleep -Seconds ($RetryDelay * $attempt) }
        }
    }
    Write-Error "Failed to complete API call after $MaxRetries attempts. Last error: $($lastError.Message)"
    return $null
}

function Search-DuckDuckGo {
    param([string]$Query,[switch]$Tor)
    if (-not (Test-SecureNetworkAccess)) { return @() }
    $results = @()
    try {
        $uri = "https://html.duckduckgo.com/html?q=$([uri]::EscapeDataString($Query))"
        if ($Tor) {
            $html = & curl -s -x socks5h://127.0.0.1:9050 $uri
        } else {
            $html = Invoke-RestMethod -Uri $uri -ErrorAction Stop
        }
        $doc = ConvertFrom-Html -Content $html
        $nodes = $doc.SelectNodes("//a[contains(@class,'result__a')]") | Select-Object -First 3
        foreach ($node in $nodes) {
            $results += @{ title = $node.InnerText; url = $node.GetAttributeValue('href','') }
        }
    } catch {
        Write-Warning "DuckDuckGo search failed: $_"
    }
    return $results
}

function Search-Google {
    param([string]$Query,[switch]$Tor)
    if (-not (Test-SecureNetworkAccess)) { return @() }
    $results = @()
    try {
        $uri = "https://www.google.com/search?q=$([uri]::EscapeDataString($Query))&num=5"
        $headers = @{ 'User-Agent' = 'Mozilla/5.0' }
        if ($Tor) {
            $html = & curl -s -x socks5h://127.0.0.1:9050 -A "Mozilla/5.0" $uri
        } else {
            $html = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction Stop
        }
        $doc = ConvertFrom-Html -Content $html
        $nodes = $doc.SelectNodes("//div[contains(@class,'g')]//a[1]") | Select-Object -First 3
        foreach ($node in $nodes) {
            $href = $node.GetAttributeValue('href','')
            if ($href -match '^/url\?') {
                try {
                    $query = [System.Web.HttpUtility]::ParseQueryString($href.Substring(5))
                    $href = $query['q']
                } catch {}
            }
            $results += @{ title = $node.InnerText.Trim(); url = $href }
        }
    } catch {
        Write-Warning "Google search failed: $_"
    }
    return $results
}

function Search-Scholar {
    param([string]$Query)
    if (-not (Test-SecureNetworkAccess)) { return @() }
    $results = @()
    try {
        $uri = "https://scholar.google.com/scholar?q=$([uri]::EscapeDataString($Query))"
        $headers = @{ 'User-Agent' = 'Mozilla/5.0' }
        $html = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction Stop
        $doc = ConvertFrom-Html -Content $html
        $nodes = $doc.SelectNodes("//h3[@class='gs_rt']/a") | Select-Object -First 3
        foreach ($node in $nodes) {
            $results += @{ title = $node.InnerText.Trim(); url = $node.GetAttributeValue('href','') }
        }
    } catch {
        Write-Warning "Scholar search failed: $_"
    }
    return $results
}

function Search-ArXiv {
    param([string]$Query)
    if (-not (Test-SecureNetworkAccess)) { return @() }
    $results = @()
    try {
        $uri = "http://export.arxiv.org/api/query?search_query=all:$([uri]::EscapeDataString($Query))&start=0&max_results=3"
        $feed = Invoke-RestMethod -Uri $uri -Headers @{ 'User-Agent' = 'Mozilla/5.0' } -ErrorAction Stop
        if ($feed.feed.entry) {
            foreach ($entry in @($feed.feed.entry)) {
                $results += @{ title = $entry.title.'#text'; url = $entry.id.'#text' }
            }
        }
    } catch {
        Write-Warning "arXiv search failed: $_"
    }
    return $results
}

function Search-Web {
    param(
        [string]$Query,
        [ValidateSet('duckduckgo','google','scholar','arxiv')]$Engine = 'duckduckgo',
        [switch]$Tor
    )
    if (-not (Test-SecureNetworkAccess)) { return @() }
    switch ($Engine) {
        'google' { return Search-Google -Query $Query -Tor:$Tor }
        'duckduckgo' { return Search-DuckDuckGo -Query $Query -Tor:$Tor }
        'scholar' { return Search-Scholar -Query $Query }
        'arxiv' { return Search-ArXiv -Query $Query }
    }
}

function Get-UrlSummary {
    param([string]$Url)
    if (-not (Test-SecureNetworkAccess)) { return "" }
    try {
        $resp = Invoke-RestMethod -Uri $Url -TimeoutSec 8
        $doc  = ConvertFrom-Html -Content $resp.Content
        $paragraphs = $doc.SelectNodes("//p") | Select-Object -First 3
        $text = ($paragraphs | ForEach-Object { $_.InnerText.Trim() }) -join " `n"
        return Invoke-GPT -Messages @(
            @{role='system'; content='Summarize this snippet:'},
            @{role='user';   content=$text}
        ) -Max 1000
    } catch {
        Write-Warning "URL summarization failed: $_"
        return ""
    }
}
