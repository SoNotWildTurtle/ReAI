function Test-Windows10 {
    if (-not $IsWindows) { return $false }
    $ver = [Environment]::OSVersion.Version
    return ($ver.Major -ge 10)
}

function Start-ReAIService {
    if (-not $IsWindows) { Write-Warning 'Service management is Windows-only.'; return }
    if (-not (Test-Windows10)) { Write-Warning "Windows 10 or later required."; return }
function Start-ReAIService {
    if (-not (Test-AdminPrivileges)) { Write-Warning 'Administrator privileges required.'; return }
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Start-Service -Name $ServiceName
        Write-Host "Service '$ServiceName' started."
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

function Open-ReAITerminal {
    if ($global:ReAITerminal -and -not $global:ReAITerminal.HasExited) {
        Write-Host 'ReAI terminal already open.'
        return $global:ReAITerminal
    }
    $path = $LogFile
    if (-not $path) { $path = $global:LogFile }
    if (-not (Test-Path $path)) { New-Item -ItemType File -Path $path | Out-Null }
    $exe = if (Test-Path (Join-Path $PSHOME 'pwsh')) { Join-Path $PSHOME 'pwsh' } else { Join-Path $PSHOME 'powershell.exe' }
    if ($IsWindows) {
        $proc = Start-Process -FilePath $exe -ArgumentList '-NoExit','-Command', "Get-Content -Path \"$path\" -Wait" -WindowStyle Normal -PassThru
    } else {
        $proc = Start-Process -FilePath $exe -ArgumentList '-NoExit','-Command', "Get-Content -Path \"$path\" -Wait" -PassThru
    }
    $proc = Start-Process -FilePath $exe -ArgumentList '-NoExit','-Command', "Get-Content -Path \"$path\" -Wait" -WindowStyle Normal -PassThru
    if (-not (Test-Path $LogFile)) { New-Item -ItemType File -Path $LogFile | Out-Null }
    $exe = if (Test-Path (Join-Path $PSHOME 'pwsh')) { Join-Path $PSHOME 'pwsh' } else { Join-Path $PSHOME 'powershell.exe' }
    $proc = Start-Process -FilePath $exe -ArgumentList '-NoExit','-Command', "Get-Content -Path \"$LogFile\" -Wait" -WindowStyle Normal -PassThru
    $global:ReAITerminal = $proc
    return $proc
}

function Close-ReAITerminal {
    if ($global:ReAITerminal -and -not $global:ReAITerminal.HasExited) {
        $global:ReAITerminal | Stop-Process
    }
    $global:ReAITerminal = $null
}

function Monitor-ReAI {
    if (-not $IsWindows) { Write-Warning 'Service monitoring is Windows-only.'; return }
    Write-Host 'Monitoring service. Press Ctrl+C to exit.'
    while ($true) {
        $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -ne 'Running') {
            Write-Host 'Service stopped. Attempting restart...'
            Start-ReAIService
            if ($global:ReAITerminal -and $global:ReAITerminal.HasExited) { $global:ReAITerminal = $null }
            if (-not $global:ReAITerminal) { Open-ReAITerminal | Out-Null }
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

Export-ModuleMember -Function Start-ReAIService,Stop-ReAIService,Restart-ReAIService,Open-ReAITerminal,Close-ReAITerminal,Monitor-ReAI,Get-ReAIServiceStatus
Export-ModuleMember -Function Start-ReAIService,Stop-ReAIService,Open-ReAITerminal,Close-ReAITerminal,Monitor-ReAI,Get-ReAIServiceStatus