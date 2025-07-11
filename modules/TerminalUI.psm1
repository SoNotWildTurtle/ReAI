function Show-ReAIMenu {
    $logo = @'
 ____  _____ ___ 
|  _ \| ____|_ _|
| |_) |  _|  | | 
|  _ <| |___ | | 
|_| \_\_____|___|
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
Export-ModuleMember -Function Show-ReAIMenu
