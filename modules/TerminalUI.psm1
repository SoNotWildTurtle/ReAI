function Show-InfoBox {
    param(
        [string]$Message,
        [ConsoleColor]$Color = 'Green'
    )
    $pad = 2
    $width = $Message.Length + ($pad * 2)
    $border = '+' + ('-' * $width) + '+'
    Write-Host $border -ForegroundColor $Color
    Write-Host ('|' + (' ' * $pad) + $Message + (' ' * $pad) + '|') -ForegroundColor $Color
    Write-Host $border -ForegroundColor $Color
}

function Show-WarningBox {
    param([string]$Message)
    Show-InfoBox -Message $Message -Color 'Yellow'
}

function Show-ReAIMenu {
    $logo = @'
 ____  _____     _     _    _
|  _ \|  ___|   / \   | |__| |
| |.) | .|__   / . \  | -. - |
|  _ <|  ___| /  _  \ |  /\  |
|_| \_|_____|/__/ \__\|_|  |_|
'@
    Write-Host $logo -ForegroundColor Cyan
    $sections = @(
        @{Title='Service Tasks'; Items=@(
            @{Name='Start Service'; Action={Start-ReAIService}; Description='Launch the Reah background service'},
            @{Name='Stop Service'; Action={Stop-ReAIService}; Description='Stop the running service'},
            @{Name='Service Status'; Action={$s=Get-ReAIServiceStatus; Write-Host "Status: $s"}; Description='Show if the service is active'},
            @{Name='Monitor Service'; Action={Monitor-ReAI}; Description='Restart service automatically if it stops'},
            @{Name='Open Terminal'; Action={Open-ReAITerminal}; Description='Open a window tailing the log file'},
            @{Name='Close Terminal'; Action={Close-ReAITerminal}; Description='Close the log-tail terminal window'}
        )},
        @{Title='Goal Tasks'; Items=@(
            @{Name='List Goals'; Action={List-ReAIGoals}; Description='Display active and completed goals'},
            @{Name='Add Goal'; Action={$g=Read-Host 'Enter goal'; if($g){Add-ReAIGoal -Goal $g}}; Description='Add a new goal to the list'},
            @{Name='Complete Goal'; Action={$g=Read-Host 'Goal to complete'; if($g){Complete-ReAIGoal -Goal $g}}; Description='Mark a goal as finished'},
            @{Name='Analyze Goals'; Action={Analyze-ReAIGoals}; Description='Generate subgoals using GPT'},
            @{Name='Process Goal'; Action={$g=Read-Host 'Goal to process'; if($g){Invoke-GoalProcessing -Goal $g}}; Description='Run the research pipeline for a goal'},
            @{Name='Process All Goals'; Action={foreach($g in $State.goals){Invoke-GoalProcessing -Goal $g}}; Description='Process every goal sequentially'}
        )},
        @{Title='Research & Context'; Items=@(
            @{Name='Research Topic'; Action={$t=Read-Host 'Topic'; if($t){Invoke-Research -Topic $t}}; Description='Create research report and business plan'},
            @{Name='Context Summary'; Action={$t=Read-Host 'Text or topic'; if($t){Get-CondensedContext -Text $t | Write-Host}}; Description='Condense Google results into short summary'},
            @{Name='Compress Text'; Action={$t=Read-Host 'Text'; if($t){Compress-Text -Text $t | Write-Host}}; Description='Summarize provided text'},
            @{Name='Summarize History'; Action={Summarize-History | Write-Host}; Description='Compress log history for context'}
        )},
        @{Title='Chatbot'; Items=@(
            @{Name='Chat with ReAI'; Action={Start-ReAIChat}; Description='Interactive conversation with the assistant'}
        )},
        @{Title='Network & Security'; Items=@(
            @{Name='Start Port Forwarding'; Action={Start-PortForwarding -LocalPort $PortForwarding.LocalPort -RemoteHost $PortForwarding.RemoteHost -RemotePort $PortForwarding.RemotePort}; Description='Proxy OpenAI traffic through local port'},
            @{Name='Stop Port Forwarding'; Action={Stop-PortForwarding}; Description='Disable the port forwarding proxy'},
            @{Name='Enable Secure Mode'; Action={Enable-SecureMode}; Description='Block external network access'},
            @{Name='Disable Secure Mode'; Action={Disable-SecureMode}; Description='Restore normal network access'}
        )},
        @{Title='Maintenance'; Items=@(
            @{Name='Run Tests'; Action={Invoke-TestSuite -RunAll}; Description='Execute the automated test suite'},
            @{Name='Self Refactor'; Action={Update-ScriptCode}; Description='Attempt GPT-driven refactor'},
            @{Name='Save Integrity Profile'; Action={Save-IntegrityProfile}; Description='Record script hashes for tamper detection'},
            @{Name='Verify Integrity'; Action={Test-Integrity}; Description='Compare hashes to ensure files are intact'},
            @{Name='Configure Tokens'; Action={Prompt-EnvVariables}; Description='Interactively set environment variables'},
            @{Name='Protect Logs'; Action={Protect-ReAILog}; Description='Compress and encrypt the log file'},
            @{Name='Protect Reports'; Action={Protect-Reports}; Description='Encrypt all markdown reports'}
        )}
    )
    if (-not $State.goals -or $State.goals.Count -eq 0) {
        Show-WarningBox 'No current goals'
    }
    $options = @{}
    $num = 1
    foreach($sec in $sections){
        foreach($item in $sec.Items){
            $options[$num.ToString()] = $item + @{Section=$sec.Title}
            $num++
        }
    }
    $options[$num.ToString()] = @{Name='Exit'; Action={return $true}; Section=''}
    do {
        Write-Host "`n== Reah Menu ==" -ForegroundColor Yellow
        $current=''
        foreach($key in $options.Keys | Sort-Object {[int]$_}){
            $sec=$options[$key].Section
            if($sec -ne $current -and $sec){ Write-Host "`n[$sec]" -ForegroundColor Cyan; $current=$sec }
            $item=$options[$key]
            Write-Host " $key) $($item.Name) - $($item.Description)"
        }
        $choice = Read-Host 'Select option'
        if ($options[$choice]) {
            $exit = & $options[$choice].Action
            if (-not $exit) { Read-Host 'Press Enter to continue' | Out-Null }
=======
function Show-ReAIMenu {
    $logo = @'
 ____  _____     _     _    _
|  _ \|  ___|   / \   | |__| |
| |.) | .|__   / . \  | ™v ™ |
|  _ <|  ___| /  _  \ |  /\  |
|_| \_|_____|/__/ \__\|_|  |_|
'@
    Write-Host $logo -ForegroundColor Cyan
    $options = @{
        '1' = @{ Name = 'Start Service'; Action = { Start-ReAIService } }
        '2' = @{ Name = 'Stop Service'; Action = { Stop-ReAIService } }
        '3' = @{ Name = 'Service Status'; Action = { $s = Get-ReAIServiceStatus; Write-Host "Status: $s" } }
        '4' = @{ Name = 'Open Terminal'; Action = { Open-ReAITerminal } }
        '5' = @{ Name = 'Close Terminal'; Action = { Close-ReAITerminal } }
        '6' = @{ Name = 'Monitor Service'; Action = { Monitor-ReAI } }
        '7'  = @{ Name = 'List Goals'; Action = { List-ReAIGoals } }
        '8'  = @{ Name = 'Add Goal'; Action = { $g = Read-Host 'Enter goal'; if($g){ Add-ReAIGoal -Goal $g } } }
        '9'  = @{ Name = 'Complete Goal'; Action = { $g = Read-Host 'Goal to complete'; if($g){ Complete-ReAIGoal -Goal $g } } }
        '10' = @{ Name = 'Analyze Goals'; Action = { Analyze-ReAIGoals } }
        '11' = @{ Name = 'Start Port Forwarding'; Action = { Start-PortForwarding -LocalPort $PortForwarding.LocalPort -RemoteHost $PortForwarding.RemoteHost -RemotePort $PortForwarding.RemotePort } }
        '12' = @{ Name = 'Stop Port Forwarding'; Action = { Stop-PortForwarding } }
        '13' = @{ Name = 'Self Refactor'; Action = { Update-ScriptCode } }
        '14' = @{ Name = 'Run Tests'; Action = { Invoke-TestSuite -RunAll } }
        '15' = @{ Name = 'Process All Goals'; Action = { foreach($g in $State.goals){ Invoke-GoalProcessing -Goal $g } } }
        '16' = @{ Name = 'Process Goal'; Action = { $g = Read-Host 'Goal to process'; if($g){ Invoke-GoalProcessing -Goal $g } } }
        '17' = @{ Name = 'Research Topic'; Action = { $t = Read-Host 'Topic to research'; if($t){ Invoke-Research -Topic $t } } }
        '18' = @{ Name = 'Context Summary'; Action = { $t = Read-Host 'Text or topic'; if($t){ Get-CondensedContext -Text $t | Write-Host } } }
        '19' = @{ Name = 'Compress Text'; Action = { $t = Read-Host 'Text to compress'; if($t){ Compress-Text -Text $t | Write-Host } } }
        '20' = @{ Name = 'Enable Secure Mode'; Action = { Enable-SecureMode } }
        '21' = @{ Name = 'Disable Secure Mode'; Action = { Disable-SecureMode } }
        '22' = @{ Name = 'Save Integrity Profile'; Action = { Save-IntegrityProfile } }
        '23' = @{ Name = 'Verify Integrity'; Action = { Test-Integrity } }
        '24' = @{ Name = 'Summarize History'; Action = { Summarize-History | Write-Host } }
        '25' = @{ Name = 'Exit'; Action = { return $true } }
    }
    do {
        Write-Host "`n== ReAI Menu ==" -ForegroundColor Yellow
        foreach ($key in $options.Keys) { Write-Host " $key) $($options[$key].Name)" }
        $choice = Read-Host 'Select option'
        if ($options[$choice]) {
            $exit = & $options[$choice].Action
        } else {
            Write-Warning 'Invalid selection.'
        }
    } until ($exit)
}

Export-ModuleMember -Function Show-ReAIMenu,Show-InfoBox,Show-WarningBox

Export-ModuleMember -Function Show-ReAIMenu