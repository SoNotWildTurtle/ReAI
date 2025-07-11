<#
Setup script for ReAI project
Installs required PowerShell modules and prepares directory structure.
#>
param()

$WorkDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path $WorkDir -Parent
$ModulesDir = Join-Path $RootDir 'modules'
$ScriptsDir = Join-Path $RootDir 'scripts'
$ReportsDir = Join-Path $RootDir 'reports'

foreach ($dir in @($ModulesDir, $ScriptsDir, $ReportsDir)) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
}

$ErrorActionPreference = 'Stop'
try {
    Install-Module -Name PowerHTML -Force -AllowClobber -Scope CurrentUser
    Install-Module -Name Pester -RequiredVersion 5.3.1 -Force -AllowClobber -Scope CurrentUser -SkipPublisherCheck
    Write-Host 'Required modules installed.'
} catch {
    Write-Error "Failed to install required modules: $_"
    exit 1
}

Write-Host 'Setup completed.'

