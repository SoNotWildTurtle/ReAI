function Prompt-EnvVariables {
    param(
        [string[]]$Variables = @(
            'OPENAI_API_KEY',
            'OPENAI_MAX_RPM',
            'OPENAI_RATE_LIMIT'
        )
    )
    foreach ($var in $Variables) {
        $current = [Environment]::GetEnvironmentVariable($var, 'Process')
        if ([string]::IsNullOrWhiteSpace($current)) {
            $value = Read-Host "Enter value for $var (leave blank to skip)"
            if ($value) {
                ${env:$var} = $value
                [Environment]::SetEnvironmentVariable($var, $value, 'Process')
                if ($var -eq 'OPENAI_API_KEY') { $global:OpenAIKey = $value }
            }
        }
    }
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Ensure-Module {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Version
    )
    if (-not (Get-Module -ListAvailable -Name $Name)) {
        try {
            if ($Version) {
                Install-Module -Name $Name -RequiredVersion $Version -Force -AllowClobber -Scope CurrentUser -SkipPublisherCheck
            } else {
                Install-Module -Name $Name -Force -AllowClobber -Scope CurrentUser -SkipPublisherCheck
            }
        } catch {
            Write-Warning "Failed to install module ${Name}: $_"
        }
    }
}

function Test-PowerShellVersion {
    if (-not (Get-Command Show-WarningBox -ErrorAction SilentlyContinue)) {
        function Show-WarningBox { param([string]$Message) ; Write-Warning $Message }
    }
    $cur = $PSVersionTable.PSVersion
    if ($IsWindows -and $cur.Major -lt 5) {
        Show-WarningBox "PowerShell 5.1 or newer required. Current: $cur"
        return $false
    }
    elseif (-not $IsWindows -and $cur.Major -lt 7) {
        Show-WarningBox "PowerShell 7 or newer recommended. Current: $cur"
        return $false
    }
    return $true
}

function Setup-ReAIEnvironment {
    if (Get-Command Show-InfoBox -ErrorAction SilentlyContinue) {
        Show-InfoBox -Message 'Initializing environment...'
    }
    Test-PowerShellVersion | Out-Null

    foreach ($dir in @(
            $global:ReportsDir,
            $global:ChatLogsDir,
            $global:ScriptsDir,
            $global:ModulesDir,
            (Join-Path $global:WorkDir 'notes'),
            (Join-Path $global:WorkDir 'data'),
            (Join-Path $global:WorkDir 'cache')
        )) {
        Ensure-Directory -Path $dir
    }

    # Install required modules if missing
    Ensure-Module -Name 'PowerHTML'
    Ensure-Module -Name 'Pester' -Version '5.3.1'
    if (Get-Command Test-ScriptDependencies -ErrorAction SilentlyContinue) {
        Test-ScriptDependencies | Out-Null
    }

    if (Get-Command Show-InfoBox -ErrorAction SilentlyContinue) {
        Show-InfoBox -Message 'Checking environment variables...'
    }
    Prompt-EnvVariables

    if (Get-Command Show-InfoBox -ErrorAction SilentlyContinue) {
        Show-InfoBox -Message 'Ensuring encryption key...'
    }
    if (Get-Command Get-EncryptionKey -ErrorAction SilentlyContinue) {
        Get-EncryptionKey | Out-Null
    }

    if (Get-Command Show-InfoBox -ErrorAction SilentlyContinue) {
        Show-InfoBox -Message 'Verifying state file...'
    }
    # Create default state file if needed
    if (-not (Test-Path $global:StateFile)) {
        $defaultState = [PSCustomObject]@{
            goals      = @()
            inProgress = @()
            completed  = @()
            iterations = 0
            versions   = @()
            secure     = $false
        }
        $defaultState | ConvertTo-Json -Depth 5 | Set-Content $global:StateFile
    }
    if (Get-Command Show-InfoBox -ErrorAction SilentlyContinue) {
        Show-InfoBox -Message 'Environment setup complete.' -Color Cyan
    }
}

Export-ModuleMember -Function Prompt-EnvVariables, Setup-ReAIEnvironment, Test-PowerShellVersion

