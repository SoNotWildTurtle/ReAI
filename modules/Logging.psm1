function Write-ReAILog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] [$Level] $Message"
    $path = $LogFile
    if (-not $path) { $path = $global:LogFile }
    if ($path) {
        try { Add-Content -Path $path -Value $line } catch { Write-Warning "Failed to write log: $_" }
    } else {
        Write-Warning 'Log file path not defined.'
    }
    Write-Host $line
}

function Protect-ReAILog {
    if (Test-Path $global:LogFile) {
        Protect-File -Path $global:LogFile | Out-Null
        $global:LogFile = "$global:LogFile.enc"
    }
}

Export-ModuleMember -Function Write-ReAILog,Protect-ReAILog
