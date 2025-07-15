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
            Write-Warning "Failed to install module $Name: $_"
        }
    }
}

function Setup-ReAIEnvironment {
    # Ensure basic folders exist
    foreach ($dir in @(
            $global:ReportsDir,
            $global:ChatLogsDir,
            $global:ScriptsDir,
            $global:ModulesDir,
            (Join-Path $global:WorkDir 'notes'),
            (Join-Path $global:WorkDir 'data')
        )) {
        Ensure-Directory -Path $dir
    }

    # Install required modules if missing
    Ensure-Module -Name 'PowerHTML'
    Ensure-Module -Name 'Pester' -Version '5.3.1'

    # Prompt for any missing environment variables
    Prompt-EnvVariables

    # Ensure encryption key exists
    if (Get-Command Get-EncryptionKey -ErrorAction SilentlyContinue) {
        Get-EncryptionKey | Out-Null
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
}

Export-ModuleMember -Function Prompt-EnvVariables, Setup-ReAIEnvironment

