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
    if (-not (Test-AdminPrivileges)) { Write-Warning 'Administrator privileges required.'; return }
    if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $ServiceName
        Write-Host "Service '$ServiceName' stopped."
    } else {
        Write-Warning "Service '$ServiceName' not installed."
    }
}

function Open-ReAITerminal {
    if (-not (Test-Path $LogFile)) { New-Item -ItemType File -Path $LogFile | Out-Null }
    $proc = Start-Process -FilePath $PSHOME\powershell.exe -ArgumentList '-NoExit','-Command', "Get-Content -Path \"$LogFile\" -Wait" -WindowStyle Normal -PassThru
    $global:ReAITerminal = $proc
    return $proc
}

function Monitor-ReAI {
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
