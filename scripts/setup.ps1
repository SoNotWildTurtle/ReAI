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
$modules = @(
    @{ Name = 'PowerHTML'; Version = $null },
    @{ Name = 'Pester';    Version = '5.3.1' }
)
foreach ($m in $modules) {
    try {
        if ($m.Version) {
            Install-Module -Name $m.Name -RequiredVersion $m.Version -Force -AllowClobber -Scope CurrentUser -SkipPublisherCheck -ErrorAction Stop
        } else {
            Install-Module -Name $m.Name -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
        }
        Write-Host "Installed module $($m.Name)."
    } catch {
        Write-Warning "Could not install module $($m.Name): $_"
    }
}

Write-Host 'Setup completed. Some features may be unavailable if modules failed to install.'

