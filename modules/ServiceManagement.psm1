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
    if ($global:ReAITerminal -and -not $global:ReAITerminal.HasExited) {
        Write-Host 'ReAI terminal already open.'
        return $global:ReAITerminal
    }
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

Export-ModuleMember -Function Start-ReAIService,Stop-ReAIService,Open-ReAITerminal,Close-ReAITerminal,Monitor-ReAI,Get-ReAIServiceStatus
