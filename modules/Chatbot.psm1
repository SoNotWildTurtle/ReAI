$script:ChatLogsDir = $global:ChatLogsDir
if (-not $script:ChatLogsDir) {
    $script:ChatLogsDir = Join-Path $PSScriptRoot '../chat_logs'
}
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
        [switch]$UseGPT,
        [string]$Mood
    )
    if (Get-Command Verify-TerminalSession -ErrorAction SilentlyContinue) { Verify-TerminalSession | Out-Null }
    if ($Mood) { Set-ReahMood -Mood $Mood }
    Train-ReahModel
    $log = New-ChatLog
    Write-ReAILog -Message "Chat started: $log" -Level 'INFO'
    Write-Host $Greeting -ForegroundColor Cyan
    Write-Host "Current mood: $(Get-ReahMood)" -ForegroundColor DarkGray
    Write-Host "Type 'exit' to quit." -ForegroundColor DarkGray
    $history = @()
    if ($UseGPT) { $history += @{role='system';content=(Get-MoodSystemPrompt)} }
    while ($true) {
        $input = Read-Host 'You'
        if ($input -eq 'exit') { break }
        if ($input.StartsWith('!')) {
            Add-Content -Path $log -Value "Command: $input"
            Invoke-ChatCommand -Input $input | Out-Null
            if ($UseGPT) { $history[0].content = Get-MoodSystemPrompt }
            continue
        }
        $rawInput = $input
        if (Get-Command Sanitize-Prompt -ErrorAction SilentlyContinue) {
            $sanitized = Sanitize-Prompt -Text $input
            if (-not $sanitized) {
                Add-Content -Path $log -Value "Rejected: $rawInput"
                Write-Host 'Input rejected for security reasons.' -ForegroundColor Yellow
                continue
            }
            $input = $sanitized
        }
        Add-Content -Path $log -Value "You: $input"
        Update-ReahCorpus -Line $input
        Train-ReahModel
        if ($UseGPT) {
            $history += @{role='user';content=$input}
            $reply = Invoke-GPT -Messages $history
            if ($reply) { $history += @{role='assistant';content=$reply} }
        } else {
            switch (Get-ReahMood) {
                'functional' { $reply = (Get-ReahResponse -Prompt $input); if ($reply) { $reply = ($reply -split '[.!?]')[0] } }
                default { $reply = Get-ReahResponse -Prompt $input }
            }
        }
        Update-ReahCorpus -Line $reply
        Train-ReahModel
        if (-not $reply) { $reply = '...' }
        Add-Content -Path $log -Value "Reah: $reply"
        Write-Host "Reah: $reply" -ForegroundColor Green
    }
    Write-ReAILog -Message "Chat ended" -Level 'INFO'
}

function Invoke-ChatCommand {
    param([string]$Input)
    $parts = $Input.Substring(1).Split(' ',2)
    $cmd = $parts[0].ToLower()
    $arg = if ($parts.Count -gt 1) { $parts[1] } else { $null }
    switch ($cmd) {
        'help' {
            Show-ChatHelp
        }
        'listgoals' {
            List-ReAIGoals
        }
        'research' {
            if ($arg) { Invoke-Research -Topic $arg } else { Write-Host 'Usage: !research <topic>' -ForegroundColor Yellow }
        }
        'mood' {
            if ($arg -and $arg.ToLower() -in @('friendly','functional')) {
                Set-ReahMood -Mood $arg.ToLower() | Out-Null
                Write-Host "Mood switched to $arg" -ForegroundColor Cyan
            } else {
                Write-Host 'Usage: !mood <friendly|functional>' -ForegroundColor Yellow
            }
        }
        default {
            Write-Host "Unknown command: $cmd" -ForegroundColor Yellow
            return $false
        }
    }
    return $true
}

function Show-ChatHelp {
    Write-Host 'Chat commands:' -ForegroundColor Cyan
    Write-Host '!help       - show this help'
    Write-Host '!listgoals  - display current goals'
    Write-Host '!research <topic> - run research workflow'
    Write-Host '!mood <friendly|functional> - switch Reah\'s tone'
}

Export-ModuleMember -Function Start-ReAIChat, Invoke-ChatCommand
