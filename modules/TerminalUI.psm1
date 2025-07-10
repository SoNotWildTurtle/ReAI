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
        '3' = @{ Name = 'Open Terminal'; Action = { Open-ReAITerminal } }
        '4' = @{ Name = 'Monitor Service'; Action = { Monitor-ReAI } }
        '5' = @{ Name = 'List Goals'; Action = { List-ReAIGoals } }
        '6' = @{ Name = 'Add Goal'; Action = { $g = Read-Host 'Enter goal'; if($g){ Add-ReAIGoal -Goal $g } } }
        '7' = @{ Name = 'Complete Goal'; Action = { $g = Read-Host 'Goal to complete'; if($g){ Complete-ReAIGoal -Goal $g } } }
        '8' = @{ Name = 'Analyze Goals'; Action = { Analyze-ReAIGoals } }
        '9' = @{ Name = 'Run Tests'; Action = { Invoke-TestSuite -RunAll } }
        '10' = @{ Name = 'Exit'; Action = { return $true } }
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
