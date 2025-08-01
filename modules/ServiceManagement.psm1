function Test-Windows10 {
    if (-not $IsWindows) { return $false }
    $ver = [Environment]::OSVersion.Version
    return ($ver.Major -ge 10)
}

function Start-ReAIService {
    if (-not $IsWindows) { Write-Warning 'Service management is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning "Windows 10 or later required."; return }
    if (-not (Test-AdminPrivileges)) { Write-Warning 'Administrator privileges required.'; return }
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Start-Service -Name $ServiceName
        Write-Host "Service '$ServiceName' started."
        Ensure-ReAITerminal
    } else {
        Write-Warning "Service '$ServiceName' not installed."
    }
}

function Stop-ReAIService {
    if (-not $IsWindows) { Write-Warning 'Service management is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning "Windows 10 or later required."; return }
    if (-not (Test-AdminPrivileges)) { Write-Warning 'Administrator privileges required.'; return }
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $ServiceName
        Write-Host "Service '$ServiceName' stopped."
        Close-ReAITerminal
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
        if ($svc -and $svc.Status -eq 'Running') {
            Ensure-ReAITerminal
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

function Open-ReAITerminal {
    $pidFile = Join-Path $global:WorkDir 'terminal.pid'
    if (Test-Path $pidFile) {
        $pid = Get-Content $pidFile
        if (Get-Process -Id $pid -ErrorAction SilentlyContinue) {
            Write-Host "Terminal already open (PID $pid)." -ForegroundColor Cyan
            return
        }
        Remove-Item $pidFile -Force
    }
    if ($IsWindows) {
        $ps = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }
        $args = "-NoExit -NoProfile -Command `\"Get-Content -Path '$global:LogFile' -Wait`\""
        $proc = Start-Process -FilePath $ps -ArgumentList $args -PassThru
    } else {
        $shell = $env:SHELL; if (-not $shell) { $shell = '/bin/bash' }
        $args = "-c \"tail -f '$global:LogFile'\""
        $proc = Start-Process -FilePath $shell -ArgumentList $args -PassThru
    }
    if ($proc) {
        $proc.Id | Out-File $pidFile -Force
        Write-Host "Terminal opened (PID $($proc.Id))." -ForegroundColor Cyan
    }
}

function Close-ReAITerminal {
    $pidFile = Join-Path $global:WorkDir 'terminal.pid'
    if (Test-Path $pidFile) {
        $pid = Get-Content $pidFile
        if (Get-Process -Id $pid -ErrorAction SilentlyContinue) {
            Stop-Process -Id $pid -Force
            Write-Host 'Terminal closed.' -ForegroundColor Cyan
        }
        Remove-Item $pidFile -Force
    } else {
        Write-Host 'No terminal to close.' -ForegroundColor Yellow
    }
}

function Ensure-ReAITerminal {
    $pidFile = Join-Path $global:WorkDir 'terminal.pid'
    if (Test-Path $pidFile) {
        $pid = Get-Content $pidFile
        if (Get-Process -Id $pid -ErrorAction SilentlyContinue) { return }
        Remove-Item $pidFile -Force
    }
    Open-ReAITerminal
}

Export-ModuleMember -Function Start-ReAIService,Stop-ReAIService,Restart-ReAIService,View-ReAILog,Monitor-ReAI,Get-ReAIServiceStatus,Open-ReAITerminal,Close-ReAITerminal,Ensure-ReAITerminal
