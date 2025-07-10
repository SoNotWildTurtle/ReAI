function Add-ReAIGoal {
    param([string]$Goal)
    if (-not $Goal) { Write-Warning 'No goal provided.'; return }
    $State.goals += $Goal
    Save-State
    Write-Host "Goal added: $Goal"
}

function Complete-ReAIGoal {
    param([string]$Goal)
    if (-not $Goal) { Write-Warning 'No goal provided.'; return }
    if ($State.goals -contains $Goal) {
        $State.goals = $State.goals | Where-Object { $_ -ne $Goal }
    }
    $State.completed += $Goal
    Save-State
    Write-Host "Goal completed: $Goal"
}

function List-ReAIGoals {
    Write-Host 'Active Goals:' -ForegroundColor Cyan
    foreach ($g in $State.goals) { Write-Host "- $g" }
    Write-Host 'Completed Goals:' -ForegroundColor Cyan
    foreach ($g in $State.completed) { Write-Host "- $g" }
}
