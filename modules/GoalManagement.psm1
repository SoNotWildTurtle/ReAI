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

function Remove-ReAIGoal {
    param([string]$Goal)
    if (-not $Goal) { Write-Warning 'No goal provided.'; return }
    if ($State.goals -contains $Goal) {
        $State.goals = $State.goals | Where-Object { $_ -ne $Goal }
        Save-State
        Write-Host "Goal removed: $Goal"
    } else {
        Write-Warning "Goal not found: $Goal"
    }
}

function Start-ReAIGoal {
    param([string]$Goal)
    if (-not $Goal) { Write-Warning 'No goal provided.'; return }
    if ($State.goals -contains $Goal) {
        $State.goals = $State.goals | Where-Object { $_ -ne $Goal }
        if (-not $State.inProgress) { $State | Add-Member -Name inProgress -Value @() -MemberType NoteProperty }
        $State.inProgress += $Goal
        Save-State
        Write-Host "Goal started: $Goal"
    } elseif ($State.inProgress -contains $Goal) {
        Write-Host 'Goal already in progress.'
    } else {
        Write-Warning "Goal not found: $Goal"
    }
}

function Pause-ReAIGoal {
    param([string]$Goal)
    if (-not $Goal) { Write-Warning 'No goal provided.'; return }
    if ($State.inProgress -contains $Goal) {
        $State.inProgress = $State.inProgress | Where-Object { $_ -ne $Goal }
        $State.goals += $Goal
        Save-State
        Write-Host "Goal paused: $Goal"
    } else {
        Write-Warning "Goal not in progress: $Goal"
    }
}

function Show-WarningBox {
    param([string]$Message)
    $pad = 2
    $width = $Message.Length + ($pad * 2)
    $border = '+' + ('-' * $width) + '+'
    Write-Host $border -ForegroundColor Yellow
    Write-Host ('|' + (' ' * $pad) + $Message + (' ' * $pad) + '|') -ForegroundColor Yellow
    Write-Host $border -ForegroundColor Yellow
}

function List-ReAIGoals {
    if (-not $State.goals -or $State.goals.Count -eq 0) {
        Show-WarningBox 'No current goals'
    } else {
        Write-Host 'Active Goals:' -ForegroundColor Cyan
        foreach ($g in $State.goals) { Write-Host "- $g" }
    }
    if ($State.inProgress -and $State.inProgress.Count -gt 0) {
        Write-Host 'In Progress:' -ForegroundColor Cyan
        foreach ($g in $State.inProgress) { Write-Host "- $g" }
    }
    if ($State.completed -and $State.completed.Count -gt 0) {
        Write-Host 'Completed Goals:' -ForegroundColor Cyan
        foreach ($g in $State.completed) { Write-Host "- $g" }
    }
}

Export-ModuleMember -Function Add-ReAIGoal,Complete-ReAIGoal,List-ReAIGoals,Remove-ReAIGoal,Start-ReAIGoal,Pause-ReAIGoal
