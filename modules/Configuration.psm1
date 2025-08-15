function Export-ReAIConfig {
    [CmdletBinding()]
    param(
        [string]$Path = (Join-Path $global:WorkDir 'reai_config.json')
    )
    $config = [PSCustomObject]@{
        State  = $global:State
        Env    = @{
            OPENAI_API_KEY   = $env:OPENAI_API_KEY
            OPENAI_MAX_RPM   = $env:OPENAI_MAX_RPM
            OPENAI_RATE_LIMIT= $env:OPENAI_RATE_LIMIT
            REAI_ENC_KEY     = $env:REAI_ENC_KEY
        }
    }
    $config | ConvertTo-Json -Depth 5 | Set-Content $Path
    Write-Host "Configuration exported to $Path" -ForegroundColor Green
}

function Import-ReAIConfig {
    [CmdletBinding()]
    param(
        [string]$Path = (Join-Path $global:WorkDir 'reai_config.json')
    )
    if (-not (Test-Path $Path)) { Write-Warning "Config file not found: $Path"; return }
    $json = Get-Content $Path -Raw | ConvertFrom-Json
    $global:State = [PSCustomObject]$json.State
    foreach ($key in $json.Env.PSObject.Properties.Name) {
        $val = $json.Env.$key
        if ($val) { Set-Item -Path "Env:$key" -Value $val }
    }
    Save-State
    Write-Host "Configuration imported from $Path" -ForegroundColor Green
}

Export-ModuleMember -Function Export-ReAIConfig,Import-ReAIConfig
