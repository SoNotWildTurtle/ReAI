function Write-ReAILog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')][string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] [$Level] $Message"
    try {
        Add-Content -Path $LogFile -Value $line
    } catch {
        Write-Warning "Failed to write log: $_"
    }
    Write-Host $line
}

Export-ModuleMember -Function Write-ReAILog
