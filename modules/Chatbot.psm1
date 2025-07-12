$script:ChatLogsDir = Join-Path $PSScriptRoot '../chat_logs'
if (-not (Test-Path $script:ChatLogsDir)) {
    New-Item -ItemType Directory -Path $script:ChatLogsDir | Out-Null
}

function New-ChatLog {
    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    Join-Path $script:ChatLogsDir "chat_$ts.txt"
}

function Start-ReAIChat {
    [CmdletBinding()]
    param(
        [string]$Greeting = "Hello, I'm Reah. Let's explore together!",
        [switch]$UseGPT
    )
    Train-ReahModel
    $log = New-ChatLog
    Write-ReAILog -Message "Chat started: $log" -Level 'INFO'
    Write-Host $Greeting -ForegroundColor Cyan
    Write-Host "Type 'exit' to quit." -ForegroundColor DarkGray
    $history = @()
    while ($true) {
        $input = Read-Host 'You'
        if ($input -eq 'exit') { break }
        Add-Content -Path $log -Value "You: $input"
        Update-ReahCorpus -Line $input
        if ($UseGPT) {
            $history += @{role='user';content=$input}
            $reply = Invoke-GPT -Messages $history
            if ($reply) { $history += @{role='assistant';content=$reply} }
        } else {
            $reply = Get-ReahResponse -Prompt $input
            Update-ReahCorpus -Line $reply
        }
        if (-not $reply) { $reply = '...' }
        Add-Content -Path $log -Value "Reah: $reply"
        Write-Host "Reah: $reply" -ForegroundColor Green
    }
    Write-ReAILog -Message "Chat ended" -Level 'INFO'
}

Export-ModuleMember -Function Start-ReAIChat
