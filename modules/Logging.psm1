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
        $attempt = 0
        while ($attempt -lt 5) {
            try {
                $fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
                $sw = New-Object System.IO.StreamWriter($fs)
                $sw.WriteLine($line)
                $sw.Close(); $fs.Close()
                break
            } catch {
                $attempt++
                if ($attempt -ge 5) { Write-Warning "Failed to write log: $_" }
                Start-Sleep -Milliseconds 100
            }
        }
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
