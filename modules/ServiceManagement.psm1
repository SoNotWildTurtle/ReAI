function Test-Windows10 {
    if (-not $IsWindows) { return $false }
    $ver = [Environment]::OSVersion.Version
    return ($ver.Major -ge 10)
}

function Install-ReAIService {
    if (-not $IsWindows) { Write-Warning 'Service installation is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning "Windows 10 or later required."; return }
    if (-not (Test-AdminPrivileges)) { Write-Warning 'Administrator privileges required.'; return }
    $existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Removing existing service '$ServiceName'..."
        sc.exe delete $ServiceName | Out-Null
        Start-Sleep -Seconds 2
    }
    Write-Host "Installing service '$ServiceName'..."
    New-Service -Name $ServiceName -BinaryPathName $ServicePath -DisplayName "MINC Research AI Agent" -StartupType Automatic -Description "Self-evolving autonomous research AI agent" | Out-Null
    Write-Host "Service installed."
}

function Start-ReAIService {
    if (-not $IsWindows) { Write-Warning 'Service management is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning "Windows 10 or later required."; return }
    if (-not (Test-AdminPrivileges)) { Write-Warning 'Administrator privileges required.'; return }
    $svcConfig = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'" -ErrorAction SilentlyContinue
    if (-not $svcConfig) {
        Write-Host "Service '$ServiceName' not installed. Installing..."
        Install-ReAIService
        $svcConfig = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'" -ErrorAction SilentlyContinue
        if (-not $svcConfig) { Write-Warning "Failed to install service '$ServiceName'."; return }
    } elseif ($svcConfig.PathName -ne $ServicePath) {
        Write-Host "Service path mismatch. Reinstalling..."
        Install-ReAIService
    }
    Start-Service -Name $ServiceName
    Start-Sleep -Seconds 2
    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Host "Service '$ServiceName' started."
    } else {
        Write-Warning "Failed to start service '$ServiceName'."
    }
}

function Stop-ReAIService {
    if (-not $IsWindows) { Write-Warning 'Service management is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning "Windows 10 or later required."; return }
    if (-not (Test-AdminPrivileges)) { Write-Warning 'Administrator privileges required.'; return }
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $ServiceName
        Write-Host "Service '$ServiceName' stopped."
    } else {
        Write-Warning "Service '$ServiceName' not installed."
    }
}

function Restart-ReAIService {
    if (-not $IsWindows) { Write-Warning 'Service management is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning "Windows 10 or later required."; return }
    Stop-ReAIService
    Start-ReAIService
}

function View-ReAILog {
    $path = $global:LogFile
    if (-not (Test-Path $path)) { New-Item -ItemType File -Path $path | Out-Null }
    Write-Host "Viewing log at $path. Press Ctrl+C to exit." -ForegroundColor Cyan
    Get-Content -Path $path -Wait
}

function Monitor-ReAI {
    if (-not $IsWindows) { Write-Warning 'Service monitoring is Windows-only.'; return }
    Write-Host 'Monitoring service. Press Ctrl+C to exit.'
    while ($true) {
        $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -ne 'Running') {
            Write-Host 'Service stopped. Attempting restart...'
            Start-ReAIService
        }
        Start-Sleep -Seconds 5
    }
}

# Query current service status
function Get-ReAIServiceStatus {
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        (Get-Service -Name $ServiceName).Status
    } else {
        'NotInstalled'
    }
}

# Register a user logon task so the log-view terminal opens each time the
# machine comes online. Provides a second startup method beyond the service
# itself and keeps the terminal available for interaction.
function Register-ReAIStartup {
    if (-not $IsWindows) { Write-Warning 'Startup registration is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning 'Windows 10 or later required.'; return }
    $pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
    if (-not $pwsh) { $pwsh = (Get-Command powershell.exe -ErrorAction SilentlyContinue).Source }
    $cmd = "`"$pwsh`" -NoLogo -NoProfile -File `"$global:WorkDir\$global:ScriptName`" -ViewLog"
    $regPath = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run'
    New-Item -Path $regPath -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path $regPath -Name 'ReAI_LogTerminal' -Value $cmd -Force
    Write-Host "Startup registry entry 'ReAI_LogTerminal' added."
}

function Unregister-ReAIStartup {
    if (-not $IsWindows) { return }
    $regPath = 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run'
    Remove-ItemProperty -Path $regPath -Name 'ReAI_LogTerminal' -ErrorAction SilentlyContinue
    Write-Host "Startup registry entry removed."
}

Export-ModuleMember -Function Install-ReAIService,Start-ReAIService,Stop-ReAIService,Restart-ReAIService,View-ReAILog,Monitor-ReAI,Get-ReAIServiceStatus,Register-ReAIStartup,Unregister-ReAIStartup
