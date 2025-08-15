# Single command to install dependencies and start ReAI service
param([switch]$StartOnly)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path $ScriptDir -Parent
$MainScript = Join-Path $Root 'ReAI.ps1'

if (-not $StartOnly) {
    Write-Host 'Running setup...' -ForegroundColor Cyan
    try {
        & "$ScriptDir/setup.ps1"
    } catch {
        Write-Warning "Setup failed: $_"
    }
}

Write-Host 'Configuring environment variables...' -ForegroundColor Cyan
try {
    & $MainScript -ConfigureTokens
} catch {
    Write-Warning "Token configuration failed: $_"
}

Write-Host 'Installing and starting service...' -ForegroundColor Cyan
try {
    & $MainScript -InstallService
} catch {
    Write-Warning "Service installation failed: $_"
    Write-Host 'Launching ReAI directly...' -ForegroundColor Cyan
    & $MainScript
    exit
}

Write-Host 'Registering startup entry...' -ForegroundColor Cyan
try {
    & $MainScript -RegisterStartup
} catch {
    Write-Warning "Startup registration failed: $_"
}

Write-Host 'Viewing log...' -ForegroundColor Cyan
try {
    & $MainScript -ViewLog
} catch {
    Write-Warning "Failed to view log: $_"
}
