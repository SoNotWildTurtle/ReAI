# Cache GPT responses to minimize API usage
$script:CacheFile = Join-Path $global:WorkDir 'cache/gpt_cache.json'
$script:Cache = @{}

function Load-GPTCache {
    if (Test-Path $script:CacheFile) {
        try {
            $script:Cache = Get-Content $script:CacheFile -Raw | ConvertFrom-Json
        } catch { $script:Cache = @{} }
    } else {
        $script:Cache = @{}
    }
}

function Save-GPTCache {
    $dir = Split-Path $script:CacheFile
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $script:Cache | ConvertTo-Json -Depth 5 | Set-Content $script:CacheFile
}

function Get-CachedGPTResponse {
    param([array]$Messages)
    $key = (ConvertTo-Json $Messages -Depth 10 | Get-FileHash -Algorithm SHA256).Hash
    if ($script:Cache.ContainsKey($key)) { return $script:Cache[$key] }
    return $null
}

function Set-CachedGPTResponse {
    param([array]$Messages,[string]$Response)
    $key = (ConvertTo-Json $Messages -Depth 10 | Get-FileHash -Algorithm SHA256).Hash
    $script:Cache[$key] = $Response
    Save-GPTCache
}

function Clear-GPTCache {
    $script:Cache = @{}
    if (Test-Path $script:CacheFile) { Remove-Item $script:CacheFile -Force }
}

Load-GPTCache

Export-ModuleMember -Function Get-CachedGPTResponse,Set-CachedGPTResponse,Load-GPTCache,Clear-GPTCache
