# Single command to install dependencies and start ReAI service
param([switch]$StartOnly)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path $ScriptDir -Parent
$MainScript = Join-Path $Root 'ReAI.ps1'

if (-not $StartOnly) {
    Write-Host 'Running setup...' -ForegroundColor Cyan
    & "$ScriptDir/setup.ps1"
}

Write-Host 'Configuring environment variables...' -ForegroundColor Cyan
& $MainScript -ConfigureTokens

Write-Host 'Installing and starting service...' -ForegroundColor Cyan
& $MainScript -InstallService

Write-Host 'Viewing log...' -ForegroundColor Cyan
& $MainScript -ViewLog
